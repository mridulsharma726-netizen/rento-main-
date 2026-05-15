const { supabase } = require('../config/supabase');

/**
 * Send notification to a specific user
 * (Currently records to database, push notifications will be integrated with Supabase edge functions/external service)
 * @param {string} userId - Target user ID
 * @param {string} title - Notification title
 * @param {string} body - Notification body
 * @param {object} data - Extra payload data
 */
async function sendPushNotification(userId, title, body, data = {}) {
    try {
        // 1. Record in Database
        const { error: dbError } = await supabase
            .from('notifications')
            .insert({
                user_id: userId,
                title,
                message: body,
                payload: data,
                read: false
            });

        if (dbError) throw dbError;

        // 2. Fetch User for logging
        const { data: user, error: userError } = await supabase
            .from('users')
            .select('email, fcm_token')
            .eq('id', userId)
            .single();

        if (userError) {
            console.log(`[Notification] Database entry created, but could not fetch user info for userId: ${userId}`);
            return;
        }

        // 3. Log (Mocking real push for now)
        console.log(`[Notification Mock] Recorded for: ${user.email} | Title: ${title} | Body: ${body}`);
        
        // FUTURE: Trigger external push provider via FCM/OneSignal here
        
    } catch (error) {
        console.error('[Notification Service Error]:', error);
    }
}

module.exports = {
    sendPushNotification
};
