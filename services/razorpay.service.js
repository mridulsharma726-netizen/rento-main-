/**
 * Razorpay Payment Service
 * Handles payment order creation and verification
 */

const crypto = require('crypto');
const Razorpay = require('razorpay');

const keyId = process.env.RAZORPAY_KEY_ID;
const keySecret = process.env.RAZORPAY_KEY_SECRET;

// Initialize Razorpay instance only when keys are configured.
const razorpay = keyId && keySecret
    ? new Razorpay({ key_id: keyId, key_secret: keySecret })
    : null;

/**
 * Create a Razorpay order for payment
 * @param {number} amount - Amount in rupees (will be converted to paise)
 * @param {string} currency - Currency code (default: INR)
 * @param {string} bookingId - Booking ID for reference
 * @returns {Promise<object>} Razorpay order object
 */
async function createOrder(amount, currency = 'INR', bookingId) {
    if (!razorpay) {
        throw new Error('Razorpay keys are not configured');
    }
    // Convert amount to paise (1 rupee = 100 paise)
    const amountInPaise = Math.round(amount * 100);
    
    const options = {
        amount: amountInPaise,
        currency: currency,
        receipt: bookingId || 'rento_' + Date.now(),
        notes: {
            bookingId: bookingId || 'unknown'
        }
    };

    try {
        const order = await razorpay.orders.create(options);
        console.log('Order created:', order.id);
        return order;
    } catch (error) {
        console.error('Razorpay createOrder error:', error);
        throw new Error('Failed to create payment order');
    }
}

/**
 * Verify Razorpay payment signature
 * @param {object} paymentData - Payment data from Razorpay webhook/client
 * @returns {boolean} True if signature is valid
 */
function verifyPaymentSignature(paymentData) {
    const { razorpay_order_id, razorpay_payment_id, razorpay_signature } = paymentData;

    if (!razorpay_order_id || !razorpay_payment_id || !razorpay_signature) {
        return false;
    }

    const secret = process.env.RAZORPAY_KEY_SECRET;
    if (!secret) {
        return false;
    }
    
    // Generate expected signature
    const generatedSignature = crypto
        .createHmac('sha256', secret)
        .update(razorpay_order_id + '|' + razorpay_payment_id)
        .digest('hex');

    return generatedSignature === razorpay_signature;
}

/**
 * Fetch payment details from Razorpay
 * @param {string} paymentId - Razorpay payment ID
 * @returns {Promise<object>} Payment details
 */
async function getPaymentDetails(paymentId) {
    if (!razorpay) {
        throw new Error('Razorpay keys are not configured');
    }
    try {
        const payment = await razorpay.payments.fetch(paymentId);
        return payment;
    } catch (error) {
        console.error('Razorpay getPaymentDetails error:', error);
        throw new Error('Failed to fetch payment details');
    }
}

/**
 * Refund a payment
 * @param {object} refundData - Refund details
 * @returns {Promise<object>} Refund object
 */
async function createRefund(refundData) {
    if (!razorpay) {
        throw new Error('Razorpay keys are not configured');
    }
    const { paymentId, amount, speed = 'normal' } = refundData;

    const options = {
        amount: amount,
        speed: speed
    };

    try {
        const refund = await razorpay.payments.refund(paymentId, options);
        return refund;
    } catch (error) {
        console.error('Razorpay createRefund error:', error);
        throw new Error('Failed to create refund');
    }
}

/**
 * Verify Razorpay webhook signature
 * @param {string} body - Raw request body
 * @param {string} signature - Signature from x-razorpay-signature header
 * @returns {boolean} True if signature is valid
 */
function validateWebhookSignature(body, signature) {
    if (!keySecret || !signature) return false;
    
    const expectedSignature = crypto
        .createHmac('sha256', keySecret)
        .update(body)
        .digest('hex');
        
    return expectedSignature === signature;
}

module.exports = {
    razorpay,
    createOrder,
    verifyPaymentSignature,
    getPaymentDetails,
    createRefund,
    validateWebhookSignature
};
