const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { verifyToken } = require('../middleware/auth');

/**
 * GET /api/notifications
 */
router.get('/', verifyToken, async (req, res) => {
    try {
        const { limit = 50, offset = 0 } = req.query;

        const { data: notifications, error, count } = await supabase
            .from('notifications')
            .select('*', { count: 'exact' })
            .eq('user_id', req.user.uid)
            .order('created_at', { ascending: false })
            .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

        if (error) throw error;

        const { count: unreadCount } = await supabase
            .from('notifications')
            .select('*', { count: 'exact', head: true })
            .eq('user_id', req.user.uid)
            .eq('read', false);

        res.json({
            success: true,
            data: {
                notifications,
                unread_count: unreadCount,
                count: notifications.length
            }
        });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * PUT /api/notifications/read-all
 */
router.put('/read-all', verifyToken, async (req, res) => {
    try {
        const { error } = await supabase
            .from('notifications')
            .update({ read: true })
            .eq('user_id', req.user.uid)
            .eq('read', false);

        if (error) throw error;
        res.json({ success: true, message: 'All read' });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
