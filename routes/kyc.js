const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { updateTrustScore } = require('../utils/trustScore');
const { verifyToken, verifyAdmin } = require('../middleware/auth');
const upload = require('../middleware/upload');
const { logger } = require('../services/logger');

/**
 * POST /api/kyc/upload-id-proof
 */
router.post('/upload-id-proof', verifyToken, upload.single('kyc_image'), async (req, res) => {
    try {
        const { id_type, id_number, full_name } = req.body;
        let imageUrl = req.file ? `/uploads/${req.file.filename}` : req.body.id_proof_image;

        if (!imageUrl) return res.status(400).json({ error: 'ID proof required' });

        const { data: user } = await supabase.from('users').select('*').eq('id', req.user.uid).single();
        if (user.kyc_status === 'verified') return res.status(400).json({ error: 'Already verified' });

        const { data: kyc, error } = await supabase
            .from('kyc_submissions')
            .insert([{
                user_id: req.user.uid,
                id_type,
                id_number,
                image_url: imageUrl,
                status: 'pending'
            }])
            .select()
            .single();

        if (error) throw error;

        await supabase.from('users').update({
            kyc_status: 'pending',
            kyc_id_type: id_type,
            kyc_id_number: id_number,
            kyc_image_url: imageUrl,
            kyc_submitted_at: new Date().toISOString(),
            name: full_name || user.name
        }).eq('id', req.user.uid);

        res.status(201).json({ success: true, kyc });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * GET /api/kyc/status
 */
router.get('/status', verifyToken, async (req, res) => {
    try {
        const { data: user } = await supabase.from('users').select('kyc_status').eq('id', req.user.uid).single();
        const { data: documents } = await supabase.from('kyc_submissions').select('*').eq('user_id', req.user.uid).order('created_at', { ascending: false });

        res.json({ success: true, data: { kyc_status: user.kyc_status, documents } });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * PATCH /api/kyc/admin/verify/:id
 */
router.patch('/admin/verify/:id', verifyAdmin, async (req, res) => {
    try {
        const { status, notes } = req.body;
        const { data: kyc } = await supabase.from('kyc_submissions').select('*').eq('id', req.params.id).single();

        await supabase.from('kyc_submissions').update({
            status,
            rejection_reason: notes
        }).eq('id', req.params.id);

        await supabase.from('users').update({
            kyc_status: status,
            is_kyc_verified: status === 'verified'
        }).eq('id', kyc.user_id);

        if (status === 'verified') {
            await updateTrustScore(kyc.user_id, 'KYC_VERIFIED', kyc.id);
        }

        res.json({ success: true, message: `Status updated to ${status}` });
    } catch (err) {
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
