# AGENTS.md

This file provides guidance to Codex (Codex.ai/code) when working with code in this repository.

## Project Overview

**Rento** is a full-stack peer-to-peer rental platform (like Airbnb for products). It's a multi-application monorepo with:
- **Backend**: Node.js + Express + MongoDB (Atlas)
- **Mobile Frontend**: Flutter (iOS/Android)
- **Web Admin Panel**: React + Vite
- **Real-time**: Firebase Cloud Messaging for push notifications

The platform handles complete rental workflows: product listings, bookings, secure payments (Razorpay), OTP-based handover, return processing, and user ratings with a trust score system.

## Repository Structure

```
rento/
├── server.js                    # Express server entry point
├── package.json                 # Backend dependencies
├── config/
│   ├── db.js                   # MongoDB connection
│   └── indexes.json            # Firestore legacy config
├── models/                      # Mongoose schemas (User, Product, Booking, etc.)
├── routes/                      # API endpoints (13 route files)
├── middleware/                  # Auth, validation, error handling, rate limiting
├── services/                    # Razorpay, logger, notifications
├── utils/                       # Trust score calculations
├── frontend/                    # Flutter mobile app
│   ├── pubspec.yaml
│   ├── lib/
│   │   ├── main.dart
│   │   ├── providers/          # State management (auth, products, bookings, chat)
│   │   ├── screens/            # Full UI screens
│   │   ├── models/             # Data models
│   │   ├── core/               # Constants, theme, services, utils
│   │   └── widgets/            # Reusable components
│   └── README.md               # Flutter-specific setup
├── admin-panel/                 # React admin dashboard
│   ├── package.json
│   ├── vite.config.js
│   └── src/
│       ├── App.jsx             # Admin shell with auth
│       ├── pages/              # Dashboard, Users, KYC, Bookings, Payments, Disputes
│       └── api.js              # Axios instance
└── scripts/                     # Data seeding, utilities
```

## Build & Development Commands

### Backend (Node.js)
```bash
# Install dependencies
npm install

# Start server (dev and start both run `node server.js` — no nodemon)
npm run dev
# or
npm start

# Run tests
npm test

# Check database connection
curl http://localhost:3000/api/test-db

# Health check
curl http://localhost:3000/api/health
```

### Frontend (Flutter)
```bash
# Get dependencies
cd frontend
flutter pub get

# Run on connected device/emulator
flutter run

# Build APK (Android)
flutter build apk

# Build IPA (iOS)
flutter build ios

# Run tests
flutter test

# Update API base URL in lib/core/constants/api_constants.dart
# Android Emulator: http://10.0.2.2:3000/api
# iOS Simulator: http://localhost:3000/api
# Production: https://your-api-url.com/api
```

### Admin Panel (React)
```bash
# Get dependencies
cd admin-panel
npm install

# Start dev server (Vite HMR)
npm run dev

# Build for production
npm run build

# Run ESLint
npm run lint

# Preview production build locally
npm run preview
```

## Environment Setup

### Backend (.env required)
```
PORT=3000
NODE_ENV=development
MONGO_URI=mongodb+srv://username:password@cluster.mongodb.net/rentoDb
JWT_SECRET=your-jwt-secret
GOOGLE_CLIENT_ID=your-google-client-id
RAZORPAY_KEY_ID=your-razorpay-key
RAZORPAY_KEY_SECRET=your-razorpay-secret
ALLOWED_ORIGINS=http://localhost:3000,http://localhost:5173
```

**Critical**: Never commit `.env`. Add credentials via `config/firebase-service-account.json` (also git-ignored).

### Database
- Uses **MongoDB Atlas** (cloud MongoDB)
- Mongoose ORM for schema validation
- Connection tested via `/api/test-db` endpoint
- 13 collections: User, Product, Booking, Payment, Return, Rating, KYC, Message, SupportMessage, Notification, Support, Dispute, TrustLog

## Core Architecture & Data Flow

### Authentication Flow
1. **Registration** (`/api/auth/signup`): Email + password or Google OAuth
2. **Login** (`/api/auth/login`): Returns JWT token valid for requests
3. **Token verification**: Middleware `verifyToken()` checks Authorization header
4. **Role-based access**: Admin routes check `user.role === 'admin'`

**Key file**: `middleware/auth.js` defines `verifyToken()` and `optionalAuth()`

### Rental Lifecycle & Status States
A booking transitions through statuses in `models/Booking.js`:
- `pending` → `paid` → `active` → `completed` / `cancelled`

**Associated flows**:
- **Payment** (`routes/payments.js`): Creates Razorpay order, verifies signature, stores payment record
- **Handover** (`routes/handover.js`): Generates 6-digit OTP, verifies it moves booking to `active`
- **Return** (`routes/return.js`): Renter initiates return with images, owner confirms condition
- **Ratings** (`routes/ratings.js`): Both users rate each other (1-5 stars), calculates average
- **Trust Score** (`utils/trustScore.js`): Updated based on completed transactions, cancellations, KYC status (0-100 scale)

### Key Entities & Relationships

**User** (MongoDB model):
- `_id`, `name`, `email`, `password` (hashed with bcrypt)
- `kyc_status`: not_submitted | pending | verified | rejected
- `trust_score`: 0-100 (auto-calculated from transaction history)
- `role`: user | admin (for admin panel access)
- `fcmToken`: For Firebase Cloud Messaging notifications

**Product**:
- `title`, `description`, `price_per_day`, `deposit`
- `category`: 9 enum values (Electronics, Vehicles, Furniture, etc.)
- `owner_id` → User (owner/lender)
- `status`: available | booked | rented

**Booking**:
- Links `renter_id` + `owner_id` + `product_id`
- `start_date`, `end_date`, `days` (auto-calculated)
- `rental_amount`, `deposit`, `total_amount`
- Razorpay integration: `razorpay_order_id`, `razorpay_payment_id`, `razorpay_signature`
- OTP fields: `otp` (hashed), `otp_salt`, `otp_generated_at`, `failed_otp_attempts`
- Return fields: `return_id` (ref), `damage_observed`, `deposit_retained`

### Security Layers

1. **HTTP Security** (`helmet.js`): Security headers, CORS policy
2. **Rate Limiting** (`middleware/rateLimiter.js`): 
   - General: 100 req/15min
   - Auth: 20 req/15min
   - Payments: 10 req/15min
   - OTP: 5 req/min
3. **Input Validation** (`middleware/validators.js`): Field validation using `express-validator`, HTML sanitization with `sanitize-html`
4. **OTP Security**:
   - Crypto-random 6-digit generation
   - Salted hash storage (not plaintext)
   - 15-minute expiry
   - 3-attempt lockout with cooldown
5. **Duplicate Prevention**:
   - Payment signature verification (Razorpay webhook)
   - Booking overlap checks (prevents double-booking same product)
   - "Already rated" checks in ratings route

### Payment System (Razorpay Integration)

**Flow** (`routes/payments.js` + `services/razorpay.service.js`):
1. Frontend calls `/api/payments/create-order` with `booking_id`
2. Backend creates Razorpay order, stores in `Payment` collection
3. Frontend opens Razorpay checkout, user completes payment
4. Frontend calls `/api/payments/verify-payment` with payment details
5. Backend verifies Razorpay signature (`crypto.createHmac()`)
6. If valid: Update booking status to `paid`, create payment record
7. Webhook (`/api/payments/webhook`) handles payment failures

**Key**: Signature verification prevents tampered payments. Order ID + Payment ID matching ensures no double-spending.

### Admin Panel

**Tech**: React 19 + Vite + React Router + Axios + Lucide icons

**Pages**:
- **Dashboard**: Stats (users, bookings, payments, disputes)
- **Users**: List all users, trust score, KYC status, ban users
- **KYC**: Verify/reject user ID proofs
- **Bookings**: View all bookings, status transitions
- **Payments**: Payment history, refund management
- **Disputes**: Handle user disputes (extended feature)

**Auth**: Email + password login, role check on backend, token stored in localStorage

### Mobile App (Flutter)

**State Management**: Provider (auth_provider, product_provider, booking_provider, chat_provider)

**Key Flows**:
- **Splash** → auto-login if token exists → Home
- **Home**: Lists products, filters by category, search
- **Product Detail**: Images, pricing, date picker, "Book Now" → Booking screen
- **Booking**: Price breakdown, confirm booking → Payment screen
- **Payment**: Razorpay integration via `razorpay_flutter` package
- **Orders**: Tabs for "As Renter" and "As Owner", status-colored chips
- **Chat**: Real-time messaging with WebSocket (Firebase Realtime DB or custom socket.io)

**Design System**: Dark mode (matte black `#0B0B0B`), deep red accent `#B91C1C`, Inter font

## API Endpoint Categories

| Category | Files | Key Endpoints |
|----------|-------|---------------|
| Auth | `routes/auth.js` | POST `/signup`, `/login`, `/google` |
| Products | `routes/products.js` | GET/POST `/`, GET/PUT/DELETE `/:id`, filters by category/price |
| Bookings | `routes/bookings.js` | POST `/`, GET `/:userId`, PUT `/:id/cancel` |
| Payments | `routes/payments.js` | POST `/create-order`, `/verify-payment`, `/webhook`, `/refund` |
| Handover | `routes/handover.js` | POST `/generate-otp`, `/verify-otp`, `/resend-otp` |
| Return | `routes/return.js` | POST `/return-item`, `/confirm-return`, GET `/:bookingId` |
| Ratings | `routes/ratings.js` | POST `/rate-user`, GET `/user/:userId`, `/booking/:bookingId` |
| KYC | `routes/kyc.js` | POST `/upload`, GET `/status` |
| Chat | `routes/chat.js` | Messages, typing indicators |
| Admin | `routes/admin.js` | User stats, KYC approval, dispute handling |
| Profile | `routes/profile.js` | Get/update user info, change password |
| Support | `routes/support.js` | Support tickets, messages |
| Notifications | `routes/notifications.js` | FCM token registration, push history |

**Common Response Format**:
```json
{ "success": true, "data": { ... } }
{ "error": "message", "code": "ERROR_CODE" }
```

## Error Handling & Logging

- **Error Handler** (`middleware/errorHandler.js`): Catches all async errors, returns standardized JSON
- **Logger** (`services/logger.js`): Winston-based logging to files (`error.log`, `combined.log`)
- **Request Logging** (`server.js`): Morgan logs all requests; custom console logs for debugging
- **Validation Errors**: `express-validator` returns 422 with field-level errors

## Testing

- Backend: Jest (config in `package.json`)
- Run with: `npm test`
- MongoDB Memory Server used for isolated test DB

## Known Patterns & Gotchas

1. **Mongoose vs Legacy Firebase Config**: Code has legacy Firestore references (`config/indexes.json`), but current DB is MongoDB. Firestore config can be removed.

2. **Booking Status Naming**: Status values use underscores (`booking_created`, `payment_done`), but newer code uses direct values (`pending`, `paid`, `active`). Migration may be needed.

3. **OTP Hashing**: OTP is stored hashed with salt (not plaintext) for security. Verification requires hashing input OTP with stored salt.

4. **Trust Score**: Auto-calculated from completed/cancelled transactions and KYC status. Not manually set. Check `utils/trustScore.js` for formula.

5. **API Base URL**: Flutter app needs correct base URL per environment:
   - Emulator: `10.0.2.2:3000` (not `localhost`)
   - iOS Simulator: `localhost:3000`
   - Update in `frontend/lib/core/constants/api_constants.dart`

6. **Admin Panel Routing**: Uses React Router v7, not deprecated v6 syntax.

7. **MongoDB Connection**: Requires `.env` MONGO_URI. If missing, server exits with helpful error message.

8. **Image Uploads**: Multer configured for `/uploads` directory (git-ignored). In production, use cloud storage (S3, Firebase Storage).

9. **Razorpay Webhook**: Must be public endpoint; local dev uses manual verification for testing.

