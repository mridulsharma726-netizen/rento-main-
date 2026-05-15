const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { verifyToken } = require('../middleware/auth');
const { logger } = require('../services/logger');

/**
 * GET /api/profile
 */
router.get('/', verifyToken, async (req, res) => {
    try {
        const { data: user, error } = await supabase
            .from('users')
            .select('*')
            .eq('id', req.user.uid)
            .single();

        if (error || !user) {
            return res.status(404).json({ error: 'User not found' });
        }
        res.json({ success: true, user });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * PUT /api/profile
 */
router.put('/', verifyToken, async (req, res) => {
    try {
        const { name, phone, email } = req.body;
        const updates = {};
        
        if (name) updates.name = name;
        if (phone) updates.phone = phone;
        if (email) updates.email = email;

        const { data: user, error } = await supabase
            .from('users')
            .update(updates)
            .eq('id', req.user.uid)
            .select()
            .single();

        if (error) return res.status(400).json({ error: error.message });

        res.json({ success: true, user, message: 'Profile updated' });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * PUT /api/profile/password
 */
router.put('/password', verifyToken, async (req, res) => {
    try {
        const { new_password } = req.body;
        if (!new_password || new_password.length < 6) {
            return res.status(400).json({ error: 'Password too short' });
        }

        const { error } = await supabase.auth.updateUser({ password: new_password });
        if (error) throw error;

        res.json({ success: true, message: 'Password updated' });
    } catch (error) {
        res.status(500).json({ error: error.message });
    }
});

/**
 * POST /api/profile/save-token
 */
router.post('/save-token', verifyToken, async (req, res) => {
    try {
        const { fcmToken } = req.body;
        await supabase.from('users').update({ fcm_token: fcmToken }).eq('id', req.user.uid);
        res.json({ success: true, message: 'Token saved' });
    } catch (error) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
