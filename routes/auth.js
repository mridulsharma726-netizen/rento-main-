const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');

/**
 * POST /api/auth/register
 */
router.post('/register', async (req, res) => {
    try {
        const { name, email, password, phone } = req.body;

        if (!name || !email || !password) {
            return res.status(400).json({ error: 'Please enter all fields' });
        }

        const { data, error } = await supabase.auth.signUp({
            email,
            password,
            options: {
                data: { name, phone, role: 'user' }
            }
        });

        if (error) {
            return res.status(400).json({ error: error.message });
        }

        res.status(201).json({
            success: true,
            session: data.session,
            user: data.user
        });
    } catch (err) {
        console.error('Register error:', err);
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * POST /api/auth/login
 */
router.post('/login', async (req, res) => {
    try {
        const { email, password } = req.body;

        if (!email || !password) {
            return res.status(400).json({ error: 'Please enter all fields' });
        }

        const { data, error } = await supabase.auth.signInWithPassword({
            email,
            password
        });

        if (error) {
            return res.status(400).json({ error: 'Invalid credentials' });
        }

        // Fetch detailed user info from public.users
        const { data: userData } = await supabase
            .from('users')
            .select('*')
            .eq('id', data.user.id)
            .single();

        res.json({
            success: true,
            token: data.session.access_token,
            user: userData || data.user
        });
    } catch (err) {
        console.error('Login error:', err);
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * POST /api/auth/google
 * Handles Supabase/Google authentication tokens
 */
router.post('/google', async (req, res) => {
    try {
        const { idToken, accessToken } = req.body;

        if (!idToken) {
            return res.status(400).json({ error: 'ID Token is required' });
        }

        const { data, error } = await supabase.auth.signInWithIdToken({
            provider: 'google',
            token: idToken,
            access_token: accessToken
        });

        if (error) throw error;

        // Fetch user info
        const { data: userData } = await supabase
            .from('users')
            .select('*')
            .eq('id', data.user.id)
            .single();

        res.json({
            success: true,
            token: data.session.access_token,
            user: userData || data.user
        });
    } catch (err) {
        console.error('Google Auth Error:', err);
        res.status(400).json({ error: 'Invalid Google token' });
    }
});

module.exports = router;
