const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { verifyToken, verifyAdmin } = require('../middleware/auth');

/**
 * GET /api/support
 */
router.get('/', verifyToken, async (req, res) => {
    try {
        const { data: tickets, error } = await supabase
            .from('support_tickets')
            .select('*')
            .eq('user_id', req.user.uid)
            .order('created_at', { ascending: false });

        if (error) throw error;
        res.json({ success: true, data: { messages: tickets } });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * POST /api/support
 */
router.post('/', verifyToken, async (req, res) => {
    try {
        const { message, priority } = req.body;
        if (!message) return res.status(400).json({ error: 'Message required' });

        const { data: ticket, error } = await supabase
            .from('support_tickets')
            .insert([{
                user_id: req.user.uid,
                message,
                priority: priority || 'low'
            }])
            .select()
            .single();

        if (error) throw error;
        res.status(201).json({ success: true, data: { ticket } });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * PATCH /api/support/:id
 */
router.patch('/:id', verifyAdmin, async (req, res) => {
    try {
        const { reply, status } = req.body;
        
        const { data: ticket, error: updateError } = await supabase
            .from('support_tickets')
            .update({ reply, status })
            .eq('id', req.params.id)
            .select()
            .single();

        if (updateError) throw updateError;

        if (reply) {
            await supabase.from('notifications').insert([{
                user_id: ticket.user_id,
                title: 'Support Reply',
                message: 'New reply to your ticket.',
                type: 'support',
                payload: { ticket_id: ticket.id }
            }]);
        }

        res.json({ success: true, ticket });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
