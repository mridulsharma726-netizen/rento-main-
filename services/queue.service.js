const { Queue } = require('bullmq');
const IORedis = require('ioredis');
const { logger } = require('./logger');

const REDIS_URL = process.env.REDIS_URL || 'redis://127.0.0.1:6379';

const connection = new IORedis(REDIS_URL, {
    maxRetriesPerRequest: null,
});

connection.on('error', (err) => {
    logger.error('Redis Connection Error', { error: err.message });
});

connection.on('connect', () => {
    console.log('✅ Connected to Redis for BullMQ');
});

// Define Queues
const bookingQueue = new Queue('booking-queue', { 
    connection,
    defaultJobOptions: {
        attempts: 3,
        backoff: {
            type: 'exponential',
            delay: 1000,
        },
        removeOnComplete: true,
        removeOnFail: false,
    }
});

/**
 * Schedule a job to expire a booking
 * @param {string} bookingId 
 * @param {number} delayMs 
 */
const scheduleBookingExpiry = async (bookingId, delayMs) => {
    await bookingQueue.add(
        'expire-booking', 
        { bookingId }, 
        { delay: delayMs, jobId: `expire-${bookingId}` }
    );
    logger.info('Booking expiry scheduled', { bookingId, delayMs });
};

module.exports = {
    connection,
    bookingQueue,
    scheduleBookingExpiry
};
