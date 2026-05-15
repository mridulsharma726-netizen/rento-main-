const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { verifyAdmin } = require('../middleware/auth');
const { logger } = require('../services/logger');
const { logAction } = require('../utils/auditLogger');

router.use(verifyAdmin);

/**
 * GET /api/admin/stats
 */
router.get('/stats', async (req, res) => {
    try {
        const [
            { count: totalUsers },
            { count: totalBookings },
            { count: totalPayments },
            { count: openDisputes }
        ] = await Promise.all([
            supabase.from('users').select('*', { count: 'exact', head: true }),
            supabase.from('bookings').select('*', { count: 'exact', head: true }),
            supabase.from('payments').select('*', { count: 'exact', head: true }),
            supabase.from('disputes').select('*', { count: 'exact', head: true }).eq('status', 'open')
        ]);
        
        res.json({
            success: true,
            data: { totalUsers, totalBookings, totalPayments, openDisputes }
        });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * GET /api/admin/users
 */
router.get('/users', async (req, res) => {
    try {
        const { role, is_banned, search, limit = 50, offset = 0 } = req.query;
        let query = supabase.from('users').select('*', { count: 'exact' });

        if (role) query = query.eq('role', role);
        if (is_banned !== undefined) query = query.eq('is_banned', is_banned === 'true');
        if (search) query = query.or(`name.ilike.%${search}%,email.ilike.%${search}%`);

        const { data: users, count, error } = await query
            .order('created_at', { ascending: false })
            .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

        if (error) throw error;
        res.json({ success: true, users, total: count });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * PUT /api/admin/users/:id/ban
 */
router.put('/users/:id/ban', async (req, res) => {
    try {
        const { ban } = req.body;
        const { data: user, error } = await supabase
            .from('users')
            .update({ is_banned: ban })
            .eq('id', req.params.id)
            .select()
            .single();

        if (error) throw error;
        
        await logAction({
            entity_type: 'User',
            entity_id: user.id,
            action: ban ? 'USER_BANNED' : 'USER_UNBANNED',
            new_value: ban,
            performed_by: req.user.uid,
            req
        });
        
        res.json({ success: true, message: `User ${ban ? 'banned' : 'unbanned'}` });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
