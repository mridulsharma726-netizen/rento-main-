/**
 * Error Handler Middleware - Production Standardized Error Handling
 */

const { logger } = require('../services/logger');

// Global error handler
const errorHandler = (err, req, res, next) => {
    // Log error
    logger.error('Unhandled Error', {
        error: err.message,
        stack: err.stack,
        path: req.path,
        method: req.method
    });

    // Default error
    let statusCode = err.status || 500;
    let message = 'Internal Server Error';

    // Handle specific error types
    if (err.name === 'ValidationError') {
        statusCode = 400;
        message = 'Validation Error';
    } else if (err.name === 'UnauthorizedError') {
        statusCode = 401;
        message = 'Unauthorized';
    } else if (err.code === 'auth/id-token-expired') {
        statusCode = 401;
        message = 'Token expired';
    } else if (err.message.includes('not found')) {
        statusCode = 404;
        message = err.message;
    }

    // Send standardized error response
    res.status(statusCode).json({
        success: false,
        error: process.env.NODE_ENV === 'production' && statusCode === 500 ? message : err.message,
        code: err.code || 'INTERNAL_ERROR'
    });
};

// 404 handler
const notFoundHandler = (req, res) => {
    res.status(404).json({
        success: false,
        error: 'Endpoint not found',
        code: 'NOT_FOUND'
    });
};

// Async handler wrapper (catches promises)
const asyncHandler = (fn) => (req, res, next) => {
    Promise.resolve(fn(req, res, next)).catch(next);
};

// Standardized success response helper
const successResponse = (res, data, statusCode = 200) => {
    res.status(statusCode).json({
        success: true,
        data
    });
};

// Standardized error response helper
const errorResponse = (res, message, code, statusCode = 400) => {
    res.status(statusCode).json({
        success: false,
        error: message,
        code
    });
};

module.exports = {
    errorHandler,
    notFoundHandler,
    asyncHandler,
    successResponse,
    errorResponse
};
