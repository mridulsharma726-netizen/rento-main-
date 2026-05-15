const admin = require('firebase-admin');
const User = require('../models/User');

// Initialize Firebase Admin
try {
    if (!admin.apps.length) {
        const path = require('path');
        const fs = require('fs');
        const serviceAccountPath = path.join(__dirname, '../config/firebase-service-account.json');

        if (fs.existsSync(serviceAccountPath)) {
            const serviceAccount = require(serviceAccountPath);
            admin.initializeApp({
                credential: admin.credential.cert(serviceAccount)
            });
            console.log('✅ Firebase Admin initialized with service account.');
        } else {
            // Fallback for development (requires GOOGLE_APPLICATION_CREDENTIALS env or being on GCP)
            admin.initializeApp({
                credential: admin.credential.applicationDefault(),
            });
            console.log('📡 Firebase Admin initialized with default credentials.');
        }
    }
} catch (error) {
    console.warn('⚠️ Firebase Admin could not be initialized. Push notifications will be simulated.', error.message);
}

/**
 * Send push notification to a specific user
 * @param {string} userId - Target user ID
 * @param {string} title - Notification title
 * @param {string} body - Notification body
 * @param {object} data - Extra payload data
 */
async function sendPushNotification(userId, title, body, data = {}) {
    try {
        const user = await User.findById(userId);
        if (!user || !user.fcmToken) {
            console.log(`[Push Notification] Skipped for user ${userId}: No FCM token`);
            return;
        }

        const message = {
            notification: { title, body },
            data: {
                ...data,
                click_action: 'FLUTTER_NOTIFICATION_CLICK',
            },
            token: user.fcmToken
        };

        if (admin.apps.length) {
            const response = await admin.messaging().send(message);
            console.log(`[Push Notification] Sent successfully: ${response}`);
        } else {
            console.log(`[Push Notification Mock] To: ${user.email} | Title: ${title} | Body: ${body}`);
        }
    } catch (error) {
        console.error('[Push Notification] Error sending:', error);
    }
}

module.exports = {
    sendPushNotification
};
