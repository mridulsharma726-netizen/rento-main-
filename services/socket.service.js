const { Server } = require('socket.io');
const jwt = require('jsonwebtoken');

let io;

const initSocket = (httpServer) => {
    io = new Server(httpServer, {
        cors: { origin: '*', methods: ['GET', 'POST'] },
        transports: ['websocket', 'polling'],
    });

    // Authenticate every socket connection with the same JWT
    io.use((socket, next) => {
        const token = socket.handshake.auth?.token;
        if (!token) return next(new Error('Authentication required'));
        try {
            const decoded = jwt.verify(token, process.env.JWT_SECRET || 'supersecret_rento_key');
            socket.userId = (decoded.userId || decoded.id).toString();
            next();
        } catch {
            next(new Error('Invalid token'));
        }
    });

    io.on('connection', (socket) => {
        // Each user joins a room named by their userId so we can target them directly
        socket.join(socket.userId);

        socket.on('disconnect', () => {});
    });

    return io;
};

const getIO = () => io;

module.exports = { initSocket, getIO };
