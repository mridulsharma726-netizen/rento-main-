/**
 * Winston Logger - Production Logging
 */

const winston = require('winston');
const path = require('path');

// Define log format
const logFormat = winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.errors({ stack: true }),
    winston.format.json()
);

// Console format for development
const consoleFormat = winston.format.combine(
    winston.format.timestamp({ format: 'YYYY-MM-DD HH:mm:ss' }),
    winston.format.colorize(),
    winston.format.printf(({ timestamp, level, message, ...meta }) => {
        let log = `${timestamp} [${level}]: ${message}`;
        if (Object.keys(meta).length > 0) {
            log += ` ${JSON.stringify(meta)}`;
        }
        return log;
    })
);

// Create logger instance
const logger = winston.createLogger({
    level: process.env.NODE_ENV === 'production' ? 'info' : 'debug',
    format: logFormat,
    transports: [
        // Console transport
        new winston.transports.Console({
            format: consoleFormat
        }),
        // Error log file
        new winston.transports.File({
            filename: path.join(__dirname, '..', 'logs', 'error.log'),
            level: 'error',
            maxsize: 5242880, // 5MB
            maxFiles: 5
        }),
        // Combined log file
        new winston.transports.File({
            filename: path.join(__dirname, '..', 'logs', 'combined.log'),
            maxsize: 5242880,
            maxFiles: 5
        })
    ]
});

// Create stream for Morgan HTTP logging
const stream = {
    write: (message) => {
        logger.info(message.trim());
    }
};

// API request/response logging helper
const logAPICall = (req, res, duration) => {
    const logData = {
        method: req.method,
        path: req.path,
        ip: req.ip,
        userAgent: req.get('user-agent'),
        status: res.statusCode,
        duration: `${duration}ms`
    };
    
    if (res.statusCode >= 400) {
        logger.warn('API Error', logData);
    } else {
        logger.info('API Call', logData);
    }
};

// Payment event logging
const logPaymentEvent = (event, data) => {
    logger.info(`Payment Event: ${event}`, {
        bookingId: data.booking_id,
        amount: data.amount,
        timestamp: new Date().toISOString()
    });
};

// Security event logging
const logSecurityEvent = (event, data) => {
    logger.warn(`Security Event: ${event}`, {
        ...data,
        timestamp: new Date().toISOString()
    });
};

module.exports = {
    logger,
    stream,
    logAPICall,
    logPaymentEvent,
    logSecurityEvent
};
