/**
 * Rate Limiter Middleware - Production Security
 */

const rateLimit = require('express-rate-limit');

// General API rate limiter
const generalLimiter = rateLimit({
    windowMs: 15 * 60 * 1000, // 15 minutes
    max: 100, // Limit each IP to 100 requests per windowMs
    message: {
        success: false,
        error: 'Too many requests, please try again later'
    },
    standardHeaders: true,
    legacyHeaders: false
});

// Strict limiter for payments (reduce abuse)
const paymentLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 10,
    message: {
        success: false,
        error: 'Payment attempts exceeded'
    }
});

// OTP limiter (prevent OTP spamming)
const otpLimiter = rateLimit({
    windowMs: 60 * 1000, // 1 minute
    max: 5,
    message: {
        success: false,
        error: 'Too many OTP requests'
    }
});

// Login/Auth limiter
const authLimiter = rateLimit({
    windowMs: 15 * 60 * 1000,
    max: 20,
    skipSuccessfulRequests: true,
    message: {
        success: false,
        error: 'Too many auth attempts'
    }
});

module.exports = {
    generalLimiter,
    paymentLimiter,
    otpLimiter,
    authLimiter
};
