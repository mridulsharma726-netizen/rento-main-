# Rento - P2P Rental Platform

Rento is a full-stack peer-to-peer rental marketplace (like Airbnb for products). This project has been successfully migrated to a high-performance **Supabase** backend.

## 🚀 Modernized Architecture

- **Backend**: Node.js + Express.js
- **Database**: Supabase (PostgreSQL)
- **Auth**: Supabase Auth (JWT)
- **Real-time**: Supabase Realtime + Socket.io
- **Background Jobs**: BullMQ + Redis
- **Payments**: Razorpay Integration

---

## 🛠️ Tech Stack

### Backend
- **Framework**: Express.js
- **Database SDK**: `@supabase/supabase-js`
- **Security**: Helmet, CORS, Rate Limiting
- **Logging**: Winston + Morgan
- **Validation**: Express-validator + Sanitize-HTML

### Mobile (Frontend)
- **Framework**: Flutter
- **State Management**: Provider
- **Auth**: `supabase_flutter`

---

## 📂 Project Structure

```
rento/
├── server.js                # Express server entry point
├── config/
│   └── supabase.js          # Supabase Client Initialization
├── routes/                  # Migrated Supabase Routes (13 files)
│   ├── auth.js              # Supabase Auth integration
│   ├── products.js          # Marketplace listings
│   ├── bookings.js          # Rental lifecycle
│   └── ...
├── middleware/              # Auth, Rate Limiting, Error Handling
├── services/                # Razorpay, Logger, Socket.io
├── workers/                 # Background workers (Booking Expiry)
├── utils/                   # Trust Score & Audit Logging
├── frontend/                # Flutter Mobile Application
└── admin-panel/             # React Admin Dashboard
```

---

## 🚦 Getting Started

### 1. Prerequisites
- Node.js (v18+)
- Redis (for background jobs)
- Supabase Project

### 2. Environment Setup
Create a `.env` file in the root directory:
```env
PORT=3000
SUPABASE_URL=your-supabase-url
SUPABASE_ANON_KEY=your-anon-key
SUPABASE_SERVICE_ROLE_KEY=your-service-key
JWT_SECRET=your-jwt-secret
RAZORPAY_KEY_ID=your-key-id
RAZORPAY_KEY_SECRET=your-key-secret
REDIS_URL=redis://localhost:6379
```

### 3. Database Setup
Execute the `supabase_schema.sql` (found in the root or provided in documentation) in your Supabase SQL Editor to initialize the PostgreSQL tables, triggers, and functions.

### 4. Installation
```bash
# Install backend dependencies
npm install

# Start the server
npm run dev
```

---

## 🔄 Core Workflows

### 1. Authentication
Uses Supabase Auth. Tokens are passed via the `Authorization: Bearer <token>` header and verified in the `verifyToken` middleware.

### 2. Rental Lifecycle
`requested` → `approved` → `paid` → `active` → `return_pending` → `completed`

### 3. Trust Score
Calculated dynamically based on user behavior (successful rentals, cancellations, ratings). Managed in `utils/trustScore.js`.

### 4. Background Processing
Unpaid booking requests automatically expire after 30 minutes via BullMQ workers to keep inventory fresh.

---

## 🛡️ Security & Operations
- **Audit Logging**: Sensitive actions (bans, payments, KYC) are logged to the `audit_logs` table.
- **Rate Limiting**: Protection against brute-force and spam on Auth and Payment endpoints.
- **Input Sanitization**: All user-provided HTML is sanitized to prevent XSS.

---

## 📄 License
MIT
