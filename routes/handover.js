const express = require('express');
const router = express.Router();
const crypto = require('crypto');
const { supabase } = require('../config/supabase');
const { verifyToken } = require('../middleware/auth');
const { logger, logSecurityEvent } = require('../services/logger');

function generateSecureOTP() {
    return crypto.randomInt(100000, 999999).toString();
}

function hashOTP(otp, salt) {
    return crypto.createHmac('sha256', salt).update(otp).digest('hex');
}

function verifyOTPHash(otp, hashedOTP, salt) {
    return hashOTP(otp, salt) === hashedOTP;
}

/**
 * POST /api/handover/generate-otp
 */
router.post('/generate-otp', verifyToken, async (req, res) => {
    try {
        const { booking_id } = req.body;
        const { data: booking, error: fetchError } = await supabase
            .from('bookings')
            .select('*')
            .eq('id', booking_id)
            .single();

        if (fetchError || !booking) return res.status(404).json({ error: 'Booking not found' });
        if (booking.owner_id !== req.user.uid) return res.status(403).json({ error: 'Unauthorized' });
        if (booking.status !== 'paid') return res.status(400).json({ error: 'Must complete payment first' });

        const otpSalt = crypto.randomBytes(16).toString('hex');
        const otp = generateSecureOTP();
        const hashedOTP = hashOTP(otp, otpSalt);

        await supabase.from('bookings').update({
            otp: hashedOTP,
            otp_salt: otpSalt,
            otp_generated_at: new Date().toISOString()
        }).eq('id', booking_id);

        logger.info('OTP generated', { bookingId: booking_id });

        res.json({
            success: true,
            otp,
            otp_expires_in: '15 minutes',
            message: 'Share OTP with renter'
        });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * POST /api/handover/verify-otp
 */
router.post('/verify-otp', verifyToken, async (req, res) => {
    try {
        const { booking_id, otp } = req.body;
        const { data: booking, error: fetchError } = await supabase
            .from('bookings')
            .select('*')
            .eq('id', booking_id)
            .single();

        if (fetchError || !booking) return res.status(404).json({ error: 'Booking not found' });
        if (booking.status !== 'paid') return res.status(400).json({ error: 'Booking not paid' });

        const isValidOTP = verifyOTPHash(otp, booking.otp, booking.otp_salt);

        if (!isValidOTP) {
            return res.status(400).json({ error: 'Invalid OTP' });
        }

        // Activate rental
        await supabase.from('bookings').update({
            status: 'active',
            otp_verified_at: new Date().toISOString(),
            otp: null,
            otp_salt: null
        }).eq('id', booking_id);

        // Update product
        await supabase.from('products').update({
            status: 'rented'
        }).eq('id', booking.product_id);

        logger.info('Rental activated', { bookingId: booking_id });

        res.json({ success: true, message: 'Item picked up', status: 'active' });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
