/**
 * Rento - P2P Rental Platform Backend
 * Main Server Entry Point
 */

require('dotenv').config();
const http = require('http');
const express = require('express');
const cors = require('cors');
const helmet = require('helmet');
const morgan = require('morgan');
const path = require('path');
const compression = require('compression');
const { initSocket } = require('./services/socket.service');
const { supabase } = require('./config/supabase');

// Routes
const authRouter = require('./routes/auth');
const productsRouter = require('./routes/products');
const bookingsRouter = require('./routes/bookings');
const kycRouter = require('./routes/kyc');
const profileRouter = require('./routes/profile');
const supportRouter = require('./routes/support');
const notificationsRouter = require('./routes/notifications');
const paymentsRouter = require('./routes/payments');
const ratingsRouter = require('./routes/ratings');
const handoverRouter = require('./routes/handover');
const returnRouter = require('./routes/return');
const chatRouter = require('./routes/chat');
const adminRouter = require('./routes/admin');

// Middleware
const { generalLimiter, authLimiter } = require('./middleware/rateLimiter');
const { errorHandler, notFoundHandler } = require('./middleware/errorHandler');

const app = express();
const PORT = process.env.PORT || 3000;
const loopbackOriginPattern =
    /^https?:\/\/(localhost|127\.0\.0\.1|0\.0\.0\.0|\[::1\])(:\d+)?$/;

// Gzip compression
app.use(compression());

// Security middleware
app.use(helmet({
    crossOriginResourcePolicy: false,
}));
const allowedOrigins = process.env.ALLOWED_ORIGINS?.split(',') || [];
app.use(cors({
    origin: (origin, callback) => {
        if (!origin) return callback(null, true);
        if (loopbackOriginPattern.test(origin)) return callback(null, true);
        if (allowedOrigins.includes(origin)) return callback(null, true);
        callback(new Error(`CORS: origin ${origin} not allowed`));
    },
    credentials: true
}));

// Body parser
app.use(express.json({ 
    limit: '10mb',
    verify: (req, res, buf) => {
        req.rawBody = buf.toString();
    }
}));
app.use(express.urlencoded({ extended: true, limit: '10mb' }));

// HTTP request logging
app.use(morgan('dev'));

// Serve static files
app.use('/uploads', express.static(path.join(__dirname, 'uploads')));

// Apply rate limiting
app.use('/api/', generalLimiter);
app.use('/api/auth', authLimiter);

// Health check endpoint
app.get('/api/health', async (req, res) => {
    let dbStatus = 'disconnected';
    try {
        const { error } = await supabase.from('users').select('id').limit(1);
        dbStatus = error ? 'error' : 'connected';
    } catch (e) {
        dbStatus = 'error';
    }
    
    let redisStatus = 'disconnected';
    try {
        const { connection } = require('./services/queue.service');
        redisStatus = connection.status === 'ready' ? 'connected' : connection.status;
    } catch (e) {
        redisStatus = 'not_configured';
    }

    res.json({
        success: true,
        data: {
            status: dbStatus === 'connected' ? 'ok' : 'degraded',
            timestamp: new Date().toISOString(),
            services: {
                supabase: dbStatus,
                redis: redisStatus,
            },
            uptime: process.uptime(),
            env: process.env.NODE_ENV || 'development'
        }
    });
});

// API Routes
app.use('/api/auth', authRouter);
app.use('/api/products', productsRouter);
app.use('/api/bookings', bookingsRouter);
app.use('/api/kyc', kycRouter);
app.use('/api/profile', profileRouter);
app.use('/api/support', supportRouter);
app.use('/api/notifications', notificationsRouter);
app.use('/api/payments', paymentsRouter);
app.use('/api/ratings', ratingsRouter);
app.use('/api/handover', handoverRouter);
app.use('/api/return', returnRouter);
app.use('/api/chat', chatRouter);
app.use('/api/admin', adminRouter);

// Error handling
app.use(notFoundHandler);
app.use(errorHandler);

// Start server
const startServer = async () => {
    try {
        const httpServer = http.createServer(app);
        initSocket(httpServer);

        // Start Background Workers
        const { startBookingWorker } = require('./workers/booking.worker');
        startBookingWorker();

        httpServer.listen(PORT, '0.0.0.0', () => {
            const addr = httpServer.address();
            const bind = typeof addr === 'string' ? `pipe ${addr}` : `port ${addr.port}`;
            console.log(`🚀 Rento API server running on ${bind} (Supabase)`);
        });
    } catch (error) {
        console.error('❌ Failed to start server:', error.message);
        process.exit(1);
    }
};

startServer();

module.exports = app;
