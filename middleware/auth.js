/**
 * Authentication Middleware
 * Verifies Supabase JWT token from request headers
 */

const { supabase } = require('../config/supabase');

async function verifyToken(req, res, next) {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({
            error: 'Unauthorized - No token provided',
            code: 'NO_TOKEN'
        });
    }

    const token = authHeader.split('Bearer ')[1];

    try {
        const { data: { user }, error } = await supabase.auth.getUser(token);
        
        if (error || !user) {
            return res.status(401).json({
                error: 'Unauthorized - Invalid token',
                code: 'INVALID_TOKEN'
            });
        }

        req.user = {
            uid: user.id,
            email: user.email
        };
        next();
    } catch (error) {
        console.error('Token verification error:', error.message);
        return res.status(401).json({
            error: 'Unauthorized - Invalid token',
            code: 'INVALID_TOKEN'
        });
    }
}

async function optionalAuth(req, res, next) {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        req.user = null;
        return next();
    }

    const token = authHeader.split('Bearer ')[1];

    try {
        const { data: { user } } = await supabase.auth.getUser(token);
        if (user) {
            req.user = {
                uid: user.id,
                email: user.email
            };
        } else {
            req.user = null;
        }
    } catch (error) {
        req.user = null;
    }

    next();
}

async function verifyAdmin(req, res, next) {
    const authHeader = req.headers.authorization;

    if (!authHeader || !authHeader.startsWith('Bearer ')) {
        return res.status(401).json({ error: 'Unauthorized', code: 'NO_TOKEN' });
    }

    const token = authHeader.split('Bearer ')[1];

    try {
        const { data: { user: authUser }, error: authError } = await supabase.auth.getUser(token);
        
        if (authError || !authUser) {
            return res.status(401).json({ error: 'Unauthorized', code: 'INVALID_TOKEN' });
        }

        // Fetch user from public.users table to check role
        const { data: user, error: dbError } = await supabase
            .from('users')
            .select('id, email, role')
            .eq('id', authUser.id)
            .single();

        if (dbError || !user || user.role !== 'admin') {
            return res.status(403).json({ error: 'Forbidden - Admin access only', code: 'ADMIN_ONLY' });
        }

        req.user = {
            uid: user.id,
            email: user.email,
            role: user.role
        };
        next();
    } catch (error) {
        return res.status(401).json({ error: 'Unauthorized', code: 'INVALID_TOKEN' });
    }
}

module.exports = {
    verifyToken,
    optionalAuth,
    verifyAdmin
};

