const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { updateTrustScore } = require('../utils/trustScore');
const { verifyToken } = require('../middleware/auth');
const { logger } = require('../services/logger');
const { scheduleBookingExpiry } = require('../services/queue.service');

const ACTIVE_BOOKING_STATUSES = ['requested', 'approved', 'paid', 'active', 'return_pending'];

async function notifyUser(userId, payload) {
    try {
        const { error } = await supabase.from('notifications').insert([{
            user_id: userId,
            title: payload.title,
            message: payload.body,
            type: payload.type,
            payload: payload.data || {}
        }]);
        if (error) throw error;
        
        // Push Notification skipped as per migration plan (Firebase removed)
    } catch (err) {
        console.error('Notification error:', err);
    }
}

/**
 * POST /api/bookings
 */
router.post('/', verifyToken, async (req, res) => {
    try {
        const { product_id, start_date, end_date } = req.body;
        const renterId = req.user.uid;

        if (!product_id || !start_date || !end_date) {
            return res.status(400).json({ error: 'Missing required fields' });
        }

        const startDate = new Date(start_date);
        const endDate = new Date(end_date);
        
        // Get product details
        const { data: product, error: prodError } = await supabase
            .from('products')
            .select('*')
            .eq('id', product_id)
            .single();

        if (prodError || !product) {
            return res.status(404).json({ error: 'Product not found', code: 'PRODUCT_NOT_FOUND' });
        }

        if (product.owner_id === renterId) {
            return res.status(400).json({ error: 'Cannot book your own product', code: 'OWN_PRODUCT' });
        }

        // Check for overlapping bookings
        const { data: overlapping, error: overlapError } = await supabase
            .from('bookings')
            .select('id')
            .eq('product_id', product_id)
            .in('status', ACTIVE_BOOKING_STATUSES)
            .or(`and(start_date.lte.${end_date},end_date.gte.${start_date})`);

        if (overlapError) throw overlapError;
        if (overlapping && overlapping.length > 0) {
            return res.status(400).json({ error: 'Product is already booked for these dates', code: 'DOUBLE_BOOKING' });
        }

        const days = Math.max(1, Math.ceil((endDate - startDate) / (1000 * 60 * 60 * 24)));
        const rentalAmount = product.price_per_day * days;
        const deposit = product.deposit || 0;
        const totalAmount = rentalAmount + deposit;

        const { data: booking, error: insertError } = await supabase
            .from('bookings')
            .insert([{
                product_id: product.id,
                product_title: product.title,
                renter_id: renterId,
                owner_id: product.owner_id,
                start_date: start_date,
                end_date: end_date,
                days,
                rental_amount: rentalAmount,
                deposit,
                total_amount: totalAmount,
                status: 'requested',
                payment_status: 'pending',
                commission_amount: Math.round(rentalAmount * 0.10)
            }])
            .select()
            .single();

        if (insertError) throw insertError;

        // Schedule auto-expiry
        await scheduleBookingExpiry(booking.id, 24 * 60 * 60 * 1000);

        await notifyUser(product.owner_id, {
            title: 'New Booking Request',
            body: `${product.title} has been requested for ${days} day(s).`,
            type: 'booking',
            data: { booking_id: booking.id, status: 'requested' }
        });

        res.status(201).json({ success: true, data: { booking } });
    } catch (error) {
        console.error('Create booking error:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * PUT /api/bookings/:id/approve
 */
router.put('/:id/approve', verifyToken, async (req, res) => {
    try {
        const { data: booking, error: fetchError } = await supabase
            .from('bookings')
            .select('*')
            .eq('id', req.params.id)
            .single();

        if (fetchError || !booking) {
            return res.status(404).json({ error: 'Booking not found' });
        }

        if (booking.owner_id !== req.user.uid) {
            return res.status(403).json({ error: 'Unauthorized' });
        }

        const expiresAt = new Date(Date.now() + 30 * 60 * 1000).toISOString();

        const { data: updatedBooking, error: updateError } = await supabase
            .from('bookings')
            .update({
                status: 'approved',
                approved_at: new Date().toISOString(),
                expires_at: expiresAt
            })
            .eq('id', req.params.id)
            .select()
            .single();

        if (updateError) throw updateError;

        await scheduleBookingExpiry(booking.id, 30 * 60 * 1000);

        await notifyUser(booking.renter_id, {
            title: 'Booking Approved',
            body: `Your request for "${booking.product_title}" was approved. Complete payment in 30 mins.`,
            type: 'booking',
            data: { booking_id: booking.id, status: 'approved' }
        });

        res.json({ success: true, data: { booking: updatedBooking } });
    } catch (error) {
        console.error('Approve booking error:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * GET /api/bookings/user
 */
router.get('/user', verifyToken, async (req, res) => {
    try {
        const { data: bookings, error } = await supabase
            .from('bookings')
            .select('*')
            .eq('renter_id', req.user.uid)
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.json({ success: true, data: { bookings, count: bookings.length } });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * GET /api/bookings/owner
 */
router.get('/owner', verifyToken, async (req, res) => {
    try {
        const { data: bookings, error } = await supabase
            .from('bookings')
            .select('*')
            .eq('owner_id', req.user.uid)
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.json({ success: true, data: { bookings, count: bookings.length } });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * GET /api/bookings/:id/details
 */
router.get('/:id/details', verifyToken, async (req, res) => {
    try {
        const { data: booking, error } = await supabase
            .from('bookings')
            .select('*')
            .eq('id', req.params.id)
            .single();

        if (error || !booking) {
            return res.status(404).json({ error: 'Booking not found' });
        }

        if (booking.renter_id !== req.user.uid && booking.owner_id !== req.user.uid) {
            return res.status(403).json({ error: 'Unauthorized' });
        }

        res.json({ success: true, data: { booking } });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
