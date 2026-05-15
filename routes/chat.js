const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { verifyToken } = require('../middleware/auth');
const { getIO } = require('../services/socket.service');

/**
 * POST /api/chat/send
 */
router.post('/send', verifyToken, async (req, res) => {
    try {
        const { receiver_id, product_id, message: content } = req.body;
        const sender_id = req.user.uid;

        const { data: newMessage, error } = await supabase
            .from('messages')
            .insert([{
                sender_id,
                receiver_id,
                product_id: product_id || null,
                content
            }])
            .select()
            .single();

        if (error) throw error;

        // Socket.io real-time push
        const io = getIO();
        if (io) io.to(receiver_id).emit('new_message', newMessage);

        res.status(201).json({ success: true, message: newMessage });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * GET /api/chat/conversation/:otherUserId
 */
router.get('/conversation/:otherUserId', verifyToken, async (req, res) => {
    try {
        const uid = req.user.uid;
        const otherId = req.params.otherUserId;

        const { data: messages, error } = await supabase
            .from('messages')
            .select('*')
            .or(`and(sender_id.eq.${uid},receiver_id.eq.${otherId}),and(sender_id.eq.${otherId},receiver_id.eq.${uid})`)
            .order('created_at', { ascending: true });

        if (error) throw error;

        // Mark as read
        await supabase
            .from('messages')
            .update({ is_read: true })
            .match({ sender_id: otherId, receiver_id: uid, is_read: false });

        res.json({ success: true, messages });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * GET /api/chat/list
 */
router.get('/list', verifyToken, async (req, res) => {
    try {
        const uid = req.user.uid;

        // Complex aggregation replaced by SQL via Supabase RPC or raw query logic
        // For simplicity, we'll fetch latest messages and group them in JS for now,
        // but ideally this would be an RPC call in production.
        
        const { data: allMessages, error } = await supabase
            .from('messages')
            .select(`
                *,
                sender:users!messages_sender_id_fkey (id, name, profile_image),
                receiver:users!messages_receiver_id_fkey (id, name, profile_image)
            `)
            .or(`sender_id.eq.${uid},receiver_id.eq.${uid}`)
            .order('created_at', { ascending: false });

        if (error) throw error;

        const conversationsMap = new Map();
        allMessages.forEach(msg => {
            const otherUser = msg.sender_id === uid ? msg.receiver : msg.sender;
            if (!conversationsMap.has(otherUser.id)) {
                conversationsMap.set(otherUser.id, {
                    other_user: otherUser,
                    last_message: msg,
                    unread_count: 0
                });
            }
            if (!msg.is_read && msg.receiver_id === uid) {
                conversationsMap.get(otherUser.id).unread_count++;
            }
        });

        res.json({ success: true, conversations: Array.from(conversationsMap.values()) });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
