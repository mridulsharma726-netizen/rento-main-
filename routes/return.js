const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { updateTrustScore } = require('../utils/trustScore');
const { verifyToken } = require('../middleware/auth');
const { logger } = require('../services/logger');

/**
 * POST /api/return/return-item
 */
router.post('/return-item', verifyToken, async (req, res) => {
    try {
        const { booking_id, return_images } = req.body;
        const { data: booking, error: fetchError } = await supabase
            .from('bookings')
            .select('*')
            .eq('id', booking_id)
            .single();

        if (fetchError || !booking) return res.status(404).json({ error: 'Booking not found' });
        if (booking.renter_id !== req.user.uid) return res.status(403).json({ error: 'Unauthorized' });
        if (booking.status !== 'active') return res.status(400).json({ error: 'Booking not active' });

        const now = new Date().toISOString();

        // Create return record
        const { data: returnData, error: returnError } = await supabase
            .from('returns')
            .insert([{
                booking_id: booking.id,
                product_id: booking.product_id,
                renter_id: req.user.uid,
                owner_id: booking.owner_id,
                return_images: return_images || [],
                status: 'return_pending',
                return_initiated_at: now
            }])
            .select()
            .single();

        if (returnError) throw returnError;

        // Update booking
        await supabase.from('bookings').update({
            status: 'return_pending',
            return_pending_at: now
        }).eq('id', booking.id);

        // Update product
        await supabase.from('products').update({
            status: 'return_pending'
        }).eq('id', booking.product_id);

        res.json({ success: true, return_id: returnData.id, message: 'Awaiting confirmation' });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * POST /api/return/confirm-return
 */
router.post('/confirm-return', verifyToken, async (req, res) => {
    try {
        const { booking_id, condition_notes, damage_observed, retain_deposit } = req.body;
        const { data: booking, error: fetchError } = await supabase
            .from('bookings')
            .select('*')
            .eq('id', booking_id)
            .single();

        if (fetchError || !booking) return res.status(404).json({ error: 'Booking not found' });
        if (booking.owner_id !== req.user.uid) return res.status(403).json({ error: 'Unauthorized' });

        const confirmedAt = new Date().toISOString();

        // Update booking
        await supabase.from('bookings').update({
            status: 'completed',
            return_confirmed_at: confirmedAt,
            condition_notes,
            damage_observed,
            deposit_retained: retain_deposit
        }).eq('id', booking.id);

        // Update product to available
        await supabase.from('products').update({
            status: 'available'
        }).eq('id', booking.product_id);

        // Update trust scores
        await updateTrustScore(booking.renter_id, 'BOOKING_COMPLETED', booking.id);
        await updateTrustScore(booking.owner_id, 'BOOKING_COMPLETED', booking.id);

        res.json({ success: true, status: 'completed' });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
