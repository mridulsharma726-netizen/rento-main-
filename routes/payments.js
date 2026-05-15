const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { verifyToken, verifyAdmin } = require('../middleware/auth');
const { logger } = require('../services/logger');
const { createOrder, verifyPaymentSignature, validateWebhookSignature } = require('../services/razorpay.service');

function markExpiredIfNeeded(booking) {
    if (
        booking.status === 'approved' &&
        booking.expires_at &&
        new Date(booking.expires_at).getTime() < Date.now()
    ) {
        return true;
    }
    return false;
}

/**
 * POST /api/payments/create-order
 */
router.post('/create-order', verifyToken, async (req, res) => {
    try {
        const { booking_id } = req.body;
        if (!booking_id) return res.status(400).json({ error: 'Booking ID required' });

        const { data: booking, error: fetchError } = await supabase
            .from('bookings')
            .select('*')
            .eq('id', booking_id)
            .single();

        if (fetchError || !booking) return res.status(404).json({ error: 'Booking not found' });
        if (booking.renter_id !== req.user.uid) return res.status(403).json({ error: 'Unauthorized' });

        if (markExpiredIfNeeded(booking)) {
            await supabase.from('bookings').update({ status: 'expired' }).eq('id', booking_id);
            return res.status(400).json({ error: 'Payment window expired' });
        }

        if (booking.status !== 'approved') return res.status(400).json({ error: 'Booking not approved' });

        const amount = booking.total_amount;
        const razorpayOrder = await createOrder(amount, 'INR', booking_id);

        await supabase.from('bookings').update({
            razorpay_order_id: razorpayOrder.id,
            order_id: razorpayOrder.id
        }).eq('id', booking_id);

        res.json({ 
            success: true,
            orderId: razorpayOrder.id,
            amount: razorpayOrder.amount,
            currency: razorpayOrder.currency,
            key_id: process.env.RAZORPAY_KEY_ID
        });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

/**
 * POST /api/payments/verify
 */
router.post('/verify', verifyToken, async (req, res) => {
    try {
        const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = req.body;

        const { data: booking, error: fetchError } = await supabase
            .from('bookings')
            .select('*')
            .eq('razorpay_order_id', razorpay_order_id)
            .single();

        if (fetchError || !booking) return res.status(404).json({ error: 'Booking not found' });

        const isSignatureValid = verifyPaymentSignature({
            razorpay_order_id,
            razorpay_payment_id,
            razorpay_signature
        });

        if (!isSignatureValid) return res.status(400).json({ error: 'Invalid signature' });

        await supabase.from('payments').insert([{
            booking_id: booking.id,
            razorpay_payment_id,
            razorpay_order_id,
            razorpay_signature,
            amount: booking.total_amount,
            status: 'completed'
        }]);

        const { data: updatedBooking } = await supabase
            .from('bookings')
            .update({
                status: 'paid',
                payment_status: 'paid',
                razorpay_payment_id,
                razorpay_signature
            })
            .eq('id', booking.id)
            .select()
            .single();

        res.json({ success: true, message: 'Payment verified', booking: updatedBooking });
    } catch (err) {
        res.status(500).json({ error: err.message });
    }
});

module.exports = router;
