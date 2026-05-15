/**
 * Request Validation Middleware - Production Security
 */

const { body, param, query, validationResult } = require('express-validator');
const sanitizeHtml = require('sanitize-html');

// Helper to check validation results
const validate = (req, res, next) => {
    const errors = validationResult(req);
    if (!errors.isEmpty()) {
        return res.status(400).json({
            success: false,
            error: 'Validation failed',
            details: errors.array().map(e => e.msg)
        });
    }
    next();
};

// Sanitize string inputs (prevent XSS)
const sanitize = (fields) => {
    return fields.map(field => {
        return body(field).trim().escape();
    });
};

// Product validation rules
const productValidation = [
    body('title').trim().notEmpty().withMessage('Title is required')
        .isLength({ max: 200 }).withMessage('Title too long')
        .customSanitizer(value => sanitizeHtml(value)),
    body('description').trim().notEmpty().withMessage('Description is required')
        .isLength({ max: 2000 }).withMessage('Description too long')
        .customSanitizer(value => sanitizeHtml(value)),
    body('price_per_day').isFloat({ min: 1 }).withMessage('Price must be positive'),
    body('deposit').optional().isFloat({ min: 0 }).withMessage('Deposit must be positive'),
    body('category').trim().notEmpty().withMessage('Category is required')
        .isLength({ max: 50 }).withMessage('Category too long')
        .matches(/^[a-zA-Z0-9 _-]+$/).withMessage('Invalid category format'),
    body('images').optional().isArray().withMessage('Images must be array'),
    validate
];

// Booking validation rules
const bookingValidation = [
    body('product_id').trim().notEmpty().withMessage('Product ID is required')
        .matches(/^[a-fA-F0-9]{24}$/).withMessage('Invalid product ID format'),
    body('start_date').isISO8601().withMessage('Invalid start date'),
    body('end_date').isISO8601().withMessage('Invalid end date')
        .custom((value, { req }) => {
            if (new Date(value) <= new Date(req.body.start_date)) {
                throw new Error('End date must be after start date');
            }
            return true;
        }),
    validate
];

// Payment verification rules
const paymentValidation = [
    body('booking_id').trim().notEmpty().withMessage('Booking ID is required'),
    body('razorpay_payment_id').trim().notEmpty().withMessage('Payment ID required'),
    body('razorpay_order_id').trim().notEmpty().withMessage('Order ID required'),
    body('razorpay_signature').trim().notEmpty().withMessage('Signature required'),
    validate
];

// OTP validation rules
const otpValidation = [
    body('booking_id').trim().notEmpty().withMessage('Booking ID is required')
        .matches(/^[a-fA-F0-9]{24}$/).withMessage('Invalid booking ID'),
    body('otp').optional().isLength({ min: 6, max: 6 }).withMessage('Invalid OTP')
        .isNumeric().withMessage('OTP must be numeric'),
    validate
];

// Rating validation rules
const ratingValidation = [
    body('booking_id').trim().notEmpty().withMessage('Booking ID is required'),
    body('rating').isInt({ min: 1, max: 5 }).withMessage('Rating must be 1-5'),
    body('review').optional().trim().isLength({ max: 500 }).withMessage('Review too long')
        .customSanitizer(value => value ? sanitizeHtml(value) : value),
    validate
];

// KYC validation rules
const kycValidation = [
    body('id_proof_image').notEmpty().withMessage('ID proof is required'),
    body('id_type').optional().trim().isLength({ max: 50 }).withMessage('Invalid ID type'),
    validate
];

// ID param validation
const idParamValidation = [
    param('id').trim().matches(/^[a-zA-Z0-9_]+$/).withMessage('Invalid ID format'),
    validate
];

// Handover validation rules
const handoverValidation = [
    body('booking_id').trim().notEmpty().withMessage('Booking ID is required')
        .matches(/^[a-fA-F0-9]{24}$/).withMessage('Invalid booking ID'),
    validate
];

// Return validation rules
const returnValidation = [
    body('booking_id').trim().notEmpty().withMessage('Booking ID is required'),
    body('return_images').optional().isArray().withMessage('Images must be array'),
    validate
];

// Confirm return validation
const confirmReturnValidation = [
    body('booking_id').trim().notEmpty().withMessage('Booking ID is required'),
    body('damage_observed').optional().isBoolean().withMessage('Invalid damage flag'),
    body('retain_deposit').optional().isBoolean().withMessage('Invalid retain flag'),
    body('condition_notes').optional().trim().isLength({ max: 500 }).withMessage('Notes too long'),
    validate
];

// Pagination validation
const paginationValidation = [
    query('limit').optional().isInt({ min: 1, max: 100 }).withMessage('Invalid limit'),
    query('offset').optional().isInt({ min: 0 }).withMessage('Invalid offset'),
    validate
];

module.exports = {
    validate,
    productValidation,
    bookingValidation,
    paymentValidation,
    otpValidation,
    ratingValidation,
    kycValidation,
    idParamValidation,
    paginationValidation,
    handoverValidation,
    returnValidation,
    confirmReturnValidation
};
