#!/usr/bin/env node
/**
 * Rento Setup Script
 * Run this before starting the server for the first time
 */

const fs = require('fs');
const path = require('path');

console.log('Rento Backend Setup\n================\n');

// Check required directories
const dirs = [
    path.join(__dirname, '..', 'logs'),
    path.join(__dirname, '..', 'config'),
    path.join(__dirname, '..', 'routes'),
    path.join(__dirname, '..', 'middleware'),
    path.join(__dirname, '..', 'services')
];

let dirsCreated = 0;

dirs.forEach(dir => {
    if (!fs.existsSync(dir)) {
        fs.mkdirSync(dir, { recursive: true });
        console.log(`✓ Created: ${path.basename(dir)}`);
        dirsCreated++;
    }
});

if (dirsCreated > 0) {
    console.log(`\nCreated ${dirsCreated} directory(ies)\n`);
}

// Check required config files
const requiredFiles = [
    { file: '.env', template: 'RENTO' },
    { file: 'config/firebase-service-account.json', template: 'FIREBASE' }
];

const missingFiles = [];

requiredFiles.forEach(({ file, template }) => {
    const filePath = path.join(__dirname, '..', file);
    if (!fs.existsSync(filePath)) {
        missingFiles.push(file);
        console.log(`✗ Missing: ${file}`);
    }
});

if (missingFiles.length > 0) {
    console.log('\n========================================');
    console.log('IMPORTANT: Setup Required');
    console.log('========================================\n');
    console.log('Please configure the following files before starting:');
    missingFiles.forEach(f => console.log(`  - ${f}`));
    console.log('\nSee the documentation for configuration details.');
    process.exit(1);
} else {
    console.log('✓ All configuration files present');
    console.log('\n========================================');
    console.log('Setup Complete!');
    console.log('========================================\n');
    console.log('To start the server, run:');
    console.log('  npm start');
    console.log('\nTo install dependencies, run:');
    console.log('  npm install');
}

console.log('\n========================================');
console.log('Environment Variables Needed:');
console.log('========================================\n');
console.log('Firebase:');
console.log('  - FIREBASE_PROJECT_ID');
console.log('  - FIREBASE_PRIVATE_KEY');
console.log('  - FIREBASE_CLIENT_EMAIL');
console.log('\nRazorpay:');
console.log('  - RAZORPAY_KEY_ID');
console.log('  - RAZORPAY_KEY_SECRET');
console.log('\nServer:');
console.log('  - PORT (default: 3000)');
console.log('  - NODE_ENV (development/production)');
