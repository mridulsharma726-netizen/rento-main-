const express = require('express');
const router = express.Router();
const { supabase } = require('../config/supabase');
const { verifyToken, optionalAuth } = require('../middleware/auth');
const upload = require('../middleware/upload');
const { logger } = require('../services/logger');

async function ensureVerifiedOwner(userId) {
    const { data: user, error } = await supabase
        .from('users')
        .select('kyc_status, is_kyc_verified, is_banned')
        .eq('id', userId)
        .single();

    if (error || !user) {
        return { ok: false, status: 404, body: { error: 'User not found', code: 'USER_NOT_FOUND' } };
    }
    if (user.is_banned) {
        return { ok: false, status: 403, body: { error: 'Account is banned', code: 'ACCOUNT_BANNED' } };
    }
    
    // Bypass for development if needed, but keeping logic consistent
    if (process.env.NODE_ENV === 'production') {
        if (!(user.is_kyc_verified || user.kyc_status === 'verified')) {
            return {
                ok: false,
                status: 403,
                body: {
                    error: 'Complete KYC verification before listing items',
                    code: 'KYC_REQUIRED'
                }
            };
        }
    }
    return { ok: true };
}

/**
 * POST /api/products
 * Create a new product listing
 */
router.post('/', verifyToken, upload.array('images', 5), async (req, res) => {
    logger.info('Product creation request received', { body: req.body, user: req.user.uid });
    try {
        const ownerCheck = await ensureVerifiedOwner(req.user.uid);
        if (!ownerCheck.ok) {
            return res.status(ownerCheck.status).json(ownerCheck.body);
        }

        const { title, description, price_per_day, deposit, category } = req.body;
        
        if (!title || !price_per_day) {
            return res.status(400).json({ error: 'Title and price per day are required' });
        }

        const pricePerDay = parseFloat(price_per_day);
        const securityDeposit = parseFloat(deposit) || 0;

        let imageUrls = [];
        if (req.files && req.files.length > 0) {
            imageUrls = req.files.map(file => `/uploads/${file.filename}`);
        } else if (req.body.images) {
            imageUrls = Array.isArray(req.body.images) ? req.body.images : [req.body.images];
        }

        const capitalize = (s) => s.charAt(0).toUpperCase() + s.slice(1).toLowerCase();
        const normalizedCategory = category ? capitalize(category.trim()) : 'Others';

        const { data: product, error } = await supabase
            .from('products')
            .insert([{
                title,
                description,
                price_per_day: pricePerDay,
                deposit: securityDeposit,
                category: normalizedCategory,
                images: imageUrls,
                owner_id: req.user.uid,
                status: 'available'
            }])
            .select()
            .single();

        if (error) throw error;

        res.status(201).json({ success: true, product });
    } catch (error) {
        console.error('Error creating product:', error);
        res.status(500).json({ error: error.message });
    }
});

/**
 * GET /api/products/my
 */
router.get('/my', verifyToken, async (req, res) => {
    try {
        const { limit = 50, offset = 0 } = req.query;

        const { data: products, error, count } = await supabase
            .from('products')
            .select('*', { count: 'exact' })
            .eq('owner_id', req.user.uid)
            .order('created_at', { ascending: false })
            .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

        if (error) throw error;

        res.json({ success: true, products, count });
    } catch (error) {
        console.error('Error fetching my products:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * GET /api/products
 */
router.get('/', optionalAuth, async (req, res) => {
    try {
        const { category, min_price, max_price, limit = 20, offset = 0 } = req.query;

        let query = supabase
            .from('products')
            .select('*', { count: 'exact' })
            .eq('status', 'available');
        
        if (category && category.toLowerCase() !== 'all') {
            const capitalize = (s) => s.charAt(0).toUpperCase() + s.slice(1).toLowerCase();
            query = query.eq('category', capitalize(category.trim()));
        }

        if (min_price) query = query.gte('price_per_day', parseFloat(min_price));
        if (max_price) query = query.lte('price_per_day', parseFloat(max_price));

        const { data: products, error, count } = await query
            .order('created_at', { ascending: false })
            .range(parseInt(offset), parseInt(offset) + parseInt(limit) - 1);

        if (error) throw error;

        res.json({ success: true, products, count });
    } catch (error) {
        console.error('Error fetching products:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * GET /api/products/:id
 */
router.get('/:id', optionalAuth, async (req, res) => {
    try {
        const { data: product, error } = await supabase
            .from('products')
            .select(`
                *,
                owner:users (
                    id, name, email, trust_score, is_kyc_verified, created_at
                )
            `)
            .eq('id', req.params.id)
            .single();

        if (error || !product) {
            return res.status(404).json({ error: 'Product not found', code: 'PRODUCT_NOT_FOUND' });
        }
        res.json({ success: true, product });
    } catch (error) {
        console.error('Error fetching product details:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * PUT /api/products/:id
 */
router.put('/:id', verifyToken, upload.array('images', 5), async (req, res) => {
    try {
        const ownerCheck = await ensureVerifiedOwner(req.user.uid);
        if (!ownerCheck.ok) {
            return res.status(ownerCheck.status).json(ownerCheck.body);
        }

        const { data: existingProduct } = await supabase
            .from('products')
            .select('owner_id')
            .eq('id', req.params.id)
            .single();

        if (!existingProduct) {
            return res.status(404).json({ error: 'Product not found', code: 'PRODUCT_NOT_FOUND' });
        }

        if (existingProduct.owner_id !== req.user.uid) {
            return res.status(403).json({ error: 'Only the owner can edit this product' });
        }

        const { title, description, price_per_day, deposit, category, status } = req.body;
        const updates = {};

        if (title) updates.title = title;
        if (description) updates.description = description;
        if (price_per_day) updates.price_per_day = parseFloat(price_per_day);
        if (deposit !== undefined) updates.deposit = parseFloat(deposit) || 0;
        if (category) {
            const capitalize = (s) => s.charAt(0).toUpperCase() + s.slice(1).toLowerCase();
            updates.category = capitalize(category.trim());
        }
        if (status) updates.status = status;

        if (req.files && req.files.length > 0) {
            updates.images = req.files.map(file => `/uploads/${file.filename}`);
        }

        const { data: product, error } = await supabase
            .from('products')
            .update(updates)
            .eq('id', req.params.id)
            .select()
            .single();

        if (error) throw error;

        logger.info('Product updated', { productId: req.params.id, userId: req.user.uid });
        res.json({ success: true, product, message: 'Product updated successfully' });
    } catch (error) {
        console.error('Error updating product:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

/**
 * DELETE /api/products/:id
 */
router.delete('/:id', verifyToken, async (req, res) => {
    try {
        const { data: product } = await supabase
            .from('products')
            .select('owner_id')
            .eq('id', req.params.id)
            .single();

        if (!product) {
            return res.status(404).json({ error: 'Product not found', code: 'PRODUCT_NOT_FOUND' });
        }

        if (product.owner_id !== req.user.uid) {
            return res.status(403).json({ error: 'Only the owner can delete this product' });
        }

        const { error } = await supabase
            .from('products')
            .delete()
            .eq('id', req.params.id);

        if (error) throw error;

        logger.info('Product deleted', { productId: req.params.id, userId: req.user.uid });
        res.json({ success: true, message: 'Product deleted successfully' });
    } catch (error) {
        console.error('Error deleting product:', error);
        res.status(500).json({ error: 'Server error' });
    }
});

module.exports = router;
