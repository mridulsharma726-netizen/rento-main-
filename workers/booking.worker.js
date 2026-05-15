const { Worker } = require('bullmq');
const { supabase } = require('../config/supabase');
const { connection } = require('../services/queue.service');
const { logger } = require('../services/logger');

/**
 * Booking Worker
 * Handles background tasks related to bookings using Supabase
 */
const startBookingWorker = () => {
    const worker = new Worker('booking-queue', async (job) => {
        const { bookingId } = job.data;
        
        logger.info(`Processing job ${job.name}`, { bookingId, jobId: job.id });

        if (job.name === 'expire-booking') {
            const { data: booking, error: fetchError } = await supabase
                .from('bookings')
                .select('*')
                .eq('id', bookingId)
                .single();
            
            if (fetchError || !booking) {
                logger.warn('Booking not found for expiry job', { bookingId });
                return;
            }

            if (['requested', 'approved'].includes(booking.status)) {
                await supabase
                    .from('bookings')
                    .update({ status: 'expired' })
                    .eq('id', bookingId);
                
                logger.info('Booking auto-expired via worker', { bookingId });
                
                // Note: Push notifications removed as per migration plan
            }
        }
    }, { connection });

    worker.on('completed', (job) => {
        logger.debug(`Job ${job.id} completed successfully`);
    });

    worker.on('failed', (job, err) => {
        logger.error(`Job ${job.id} failed`, { error: err.message });
    });

    console.log('👷 Booking Worker started (Supabase enabled)');
    return worker;
};

module.exports = { startBookingWorker };
