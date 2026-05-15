const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { updateTrustScore } = require('../utils/trustScore');
const { verifyToken, optionalAuth } = require('../middleware/auth');
const { logger } = require('../services/logger');

/**
 * POST /api/ratings/rate-user
 */
router.post('/rate-user', verifyToken, async (req, res) => {
    try {
        const { booking_id, rating, review } = req.body;
        const ratingValue = parseInt(rating);

        if (!booking_id || !ratingValue) {
            return res.status(400).json({ error: 'Missing fields' });
        }

        const { data: booking, error: fetchError } = await supabase
            .from('bookings')
            .select('*')
            .eq('id', booking_id)
            .single();

        if (fetchError || !booking) return res.status(404).json({ error: 'Booking not found' });
        if (booking.status !== 'completed') return res.status(400).json({ error: 'Booking not completed' });

        const isRenter = booking.renter_id === req.user.uid;
        const userToRate = isRenter ? booking.owner_id : booking.renter_id;

        // Insert rating
        const { data: ratingData, error: insertError } = await supabase
            .from('ratings')
            .insert([{
                booking_id: booking.id,
                rated_by: req.user.uid,
                rated_user: userToRate,
                stars: ratingValue,
                comment: review
            }])
            .select()
            .single();

        if (insertError) {
            if (insertError.code === '23505') return res.status(400).json({ error: 'Already rated' });
            throw insertError;
        }

        // Recalculate average
        const { data: allRatings } = await supabase
            .from('ratings')
            .select('stars')
            .eq('rated_user', userToRate);

        const count = allRatings.length;
        const avg = allRatings.reduce((sum, r) => sum + r.stars, 0) / count;

        await supabase
            .from('users')
            .update({
                rating: Math.round(avg * 10) / 10,
                total_ratings: count
            })
            .eq('id', userToRate);

        if (ratingValue >= 4) {
            await updateTrustScore(userToRate, 'GOOD_RATING', ratingData.id);
        }

        res.status(201).json({ success: true, rating: ratingData });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * GET /api/ratings/user/:userId
 */
router.get('/user/:userId', optionalAuth, async (req, res) => {
    try {
        const { data: ratings, error } = await supabase
            .from('ratings')
            .select('*')
            .eq('rated_user', req.params.userId)
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.json({ success: true, ratings });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
