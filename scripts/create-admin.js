require('dotenv').config();
const mongoose = require('mongoose');
const bcrypt = require('bcryptjs');
const User = require('../models/User');

const MONGO_URI = process.env.MONGO_URI || 'mongodb://localhost:27017/rento';

async function createAdmin() {
    try {
        await mongoose.connect(MONGO_URI);
        console.log('Connected to MongoDB');

        const email = 'admin@rento.app';
        const password = 'adminpassword123';
        
        const existing = await User.findOne({ email });
        if (existing) {
            console.log('Admin already exists');
            existing.role = 'admin';
            await existing.save();
            process.exit(0);
        }

        const hashedPassword = await bcrypt.hash(password, 10);
        const admin = new User({
            name: 'Super Admin',
            email: email,
            password: hashedPassword,
            role: 'admin',
            is_kyc_verified: true,
            trust_score: 100
        });

        await admin.save();
        console.log('Admin created successfully');
        console.log('Email:', email);
        console.log('Password:', password);
        process.exit(0);
    } catch (err) {
        console.error('Error creating admin:', err);
        process.exit(1);
    }
}

createAdmin();
