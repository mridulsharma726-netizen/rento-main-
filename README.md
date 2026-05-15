# Rento - P2P Rental Platform Backend
## Detailed Implementation Report

---

## Executive Summary

Rento is a peer-to-peer rental platform (like Airbnb for products) built with:
- **Backend**: Node.js + Express.js
- **Database**: Firebase Firestore
- **Auth**: Firebase Authentication
- **Storage**: Firebase Storage
- **Payments**: Razorpay

This document details every feature, file, and implementation decision.

---

## Part 1: Project Setup Tasks Completed

### 1.1 Created Project Structure ✅
```
rento/
├── package.json
├── server.js
├── .env
├── config/
│   ├── firebase.config.js
│   ├── firebase-service-account.json
│   └── indexes.json
├── middleware/
│   ├── auth.js
│   ├── errorHandler.js
│   ├── rateLimiter.js
│   └── validators.js
├── routes/
│   ├── products.js
│   ├── bookings.js
│   ├── payments.js
│   ├── handover.js
│   ├── return.js
│   ├── ratings.js
│   └── kyc.js
├── services/
│   ├── razorpay.service.js
│   └── logger.js
├── scripts/
│   └── setup.js
├── sample-data.json
└── README.md
```

### 1.2 Initialized package.json ✅
Added dependencies:
- `express` - Web framework
- `firebase-admin` - Firebase Admin SDK
- `razorpay` - Payment integration
- `cors` - Cross-origin requests
- `dotenv` - Environment variables
- `uuid` - Unique ID generation
- `helmet` - HTTP security headers
- `morgan` - HTTP request logging
- `express-rate-limit` - Rate limiting
- `express-validator` - Input validation
- `sanitize-html` - XSS protection
- `winston` - Logging

### 1.3 Created .env Template ✅
Environment variables needed:
```
PORT=3000
NODE_ENV=development
FIREBASE_PROJECT_ID=your-project-id
FIREBASE_PRIVATE_KEY=your-private-key
FIREBASE_CLIENT_EMAIL=your-client-email
RAZORPAY_KEY_ID=your-key-id
RAZORPAY_KEY_SECRET=your-key-secret
```

### 1.4 Created server.js ✅
Express server with:
- Helmet security middleware
- CORS configuration
- Body parser with size limits (10KB)
- Morgan HTTP logging
- Rate limiting
- Firebase initialization
- Route registration
- Error handling middleware
- 404 handler

---

## Part 2: Firebase Integration Tasks Completed

### 2.1 Firebase Config ✅
Created `config/firebase.config.js`:
- Initializes Firebase Admin SDK
- Connects to Firestore
- Configures storage bucket

### 2.2 Service Account Template ✅
Created `config/firebase-service-account.json`:
- Template for Firebase credentials
- User replaces with their own credentials

### 2.3 Firestore Indexes ✅
Created `config/indexes.json`:
- Products: category + created_at
- Products: category + price_per_day
- Bookings: renter_id + status
- Bookings: owner_id + status
- Bookings: product_id + status
- Ratings: rated_user + created_at

---

## Part 3: Middleware Tasks Completed

### 3.1 Authentication Middleware ✅
Created `middleware/auth.js`:
- `verifyToken()` - Verifies Firebase ID token
- `optionalAuth()` - Continues if no token
- `requirePhoneVerified()` - Checks phone verification

### 3.2 Error Handler Middleware ✅
Created `middleware/errorHandler.js`:
- Global error handler
- 404 handler
- Async handler wrapper
- Standardized error responses
- Success response helper

### 3.3 Rate Limiter Middleware ✅
Created `middleware/rateLimiter.js`:
- `generalLimiter` - 100 requests/15min
- `paymentLimiter` - 10 requests/15min
- `otpLimiter` - 5 requests/minute
- `authLimiter` - 20 requests/15min

### 3.4 Validators Middleware ✅
Created `middleware/validators.js`:
- `productValidation` - Title, description, price, category
- `bookingValidation` - Product ID, dates
- `paymentValidation` - Razorpay fields
- `otpValidation` - Booking ID, 6-digit OTP
- `ratingValidation` - Booking, 1-5 rating
- `kycValidation` - ID proof
- `idParamValidation` - ID format
- `paginationValidation` - Limit/offset
- `handoverValidation` - Booking ID
- `returnValidation` - Images array
- `confirmReturnValidation` - Condition notes

---

## Part 4: API Routes Tasks Completed

### 4.1 Products Routes ✅
Created `routes/products.js`:

**Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/products | Create product listing |
| GET | /api/products | Get all products |
| GET | /api/products/:id | Get single product |
| PUT | /api/products/:id | Update product |
| DELETE | /api/products/:id | Delete product |

**Features:**
- Category filter (?category=electronics)
- Price range filter (min_price, max_price)
- Pagination (limit, offset)
- Ownership check for update/delete
- Prevent editing while rented
- Input sanitization

### 4.2 Bookings Routes ✅
Created `routes/bookings.js`:

**Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/bookings | Create booking |
| GET | /api/bookings/:userId | Get user bookings |
| GET | /api/bookings/:id/details | Get booking details |
| PUT | /api/bookings/:id/cancel | Cancel booking |

**Features:**
- Date validation (start < end)
- Overlap prevention (checks existing bookings)
- Ownership check (can't book own product)
- Auto-expiry of unpaid bookings (30 min)
- Role filtering (owner/renter)
- Status filtering

### 4.3 Payments Routes ✅
Created `routes/payments.js`:

**Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/payments/create-order | Create Razorpay order |
| POST | /api/payments/verify-payment | Verify payment |
| POST | /api/payments/webhook | Razorpay webhook |
| POST | /api/payments/refund | Process refund |
| GET | /api/payments/:bookingId | Get payment |

**Features:**
- Duplicate payment prevention
- Signature verification
- Order ID matching
- Webhook handling (payment.failed)
- Full/partial refund support
- Payment record creation

### 4.4 Handover Routes ✅
Created `routes/handover.js`:

**Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/handover/generate-otp | Generate OTP |
| POST | /api/handover/verify-otp | Verify OTP |
| POST | /api/handover/resend-otp | Resend OTP |

**Features:**
- Secure 6-digit OTP (crypto random)
- Salted OTP hashing
- 15-minute OTP expiry
- 3 attempt lockout
- Cooldown periods
- Status updates

### 4.5 Return Routes ✅
Created `routes/return.js`:

**Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/return/return-item | Initiate return |
| POST | /api/return/confirm-return | Owner confirms |
| GET | /api/return/:bookingId | Get status |

**Features:**
- Return image upload
- Owner confirmation required
- Damage tracking
- Deposit retention
- Product status update

### 4.6 Ratings Routes ✅
Created `routes/ratings.js`:

**Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/ratings/rate-user | Rate user |
| GET | /api/ratings/user/:userId | Get ratings |
| GET | /api/ratings/booking/:bookingId | Get booking ratings |

**Features:**
- 1-5 star rating
- Optional review text
- Only after completion
- Can't rate twice
- Auto-calculate average

### 4.7 KYC Routes ✅
Created `routes/kyc.js`:

**Endpoints:**
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | /api/kyc/upload | Upload ID proof |
| GET | /api/kyc/status | Get KYC status |

**Features:**
- Image upload to Firebase Storage
- ID type selection
- Verification status

---

## Part 5: Services Tasks Completed

### 5.1 Razorpay Service ✅
Created `services/razorpay.service.js`:
- `createOrder(amount, currency, bookingId)`
- `verifyPaymentSignature(paymentData)`
- `getPaymentDetails(paymentId)`
- `createRefund(refundData)`

### 5.2 Logger Service ✅
Created `services/logger.js`:
- Winston configuration
- File logging (error.log, combined.log)
- API request logging
- Payment event logging
- Security event logging

---

## Part 6: Database Schema Tasks Completed

### 6.1 Firestore Collections ✅

**users Collection:**
```json
{
  "id": "user_xxx",
  "phone": "+91xxxx",
  "kyc_status": "pending|verified|rejected",
  "rating": 4.5,
  "total_ratings": 10,
  "created_at": "2024-01-01T00:00:00Z"
}
```

**products Collection:**
```json
{
  "id": "prod_xxx",
  "title": "Canon EOS R5",
  "description": "Professional camera",
  "price_per_day": 1500,
  "deposit": 10000,
  "category": "electronics",
  "images": ["url1", "url2"],
  "owner_id": "user_xxx",
  "created_at": "2024-01-01T00:00:00Z",
  "status": "available|booked|rented"
}
```

**bookings Collection:**
```json
{
  "id": "book_xxx",
  "product_id": "prod_xxx",
  "renter_id": "user_xxx",
  "owner_id": "user_xxx",
  "start_date": "2024-02-01T00:00:00Z",
  "end_date": "2024-02-03T00:00:00Z",
  "days": 2,
  "rental_amount": 3000,
  "deposit": 10000,
  "total_amount": 13000,
  "status": "booking_created|payment_done|...",
  "otp": "hashed_otp",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**payments Collection:**
```json
{
  "id": "pay_xxx",
  "booking_id": "book_xxx",
  "razorpay_payment_id": "pay_xxx",
  "razorpay_order_id": "order_xxx",
  "amount": 13000,
  "status": "completed|refunded",
  "created_at": "2024-01-01T00:00:00Z"
}
```

**ratings Collection:**
```json
{
  "id": "rate_xxx",
  "booking_id": "book_xxx",
  "rated_by": "user_xxx",
  "rated_user": "user_xxx",
  "rating": 5,
  "review": "Great experience!",
  "created_at": "2024-01-01T00:00:00Z"
}
```

---

## Part 7: Security Implementation Tasks Completed

### 7.1 HTTP Security ✅
- Helmet.js for security headers
- CORS configuration
- Request size limits (10KB)

### 7.2 Authentication ✅
- Firebase ID token verification
- Bearer token extraction
- Token expiry handling

### 7.3 Rate Limiting ✅
- Per-endpoint rate limits
- Payment protection
- OTP spam prevention

### 7.4 Input Validation ✅
- Field required checks
- Type validation
- Length limits
- Format validation (emails, dates)
- XSS protection (sanitize-html)

### 7.5 Duplicate Prevention ✅
- Payment double-spend prevention
- Booking overlap prevention
- Already rated check

### 7.6 OTP Security ✅
- Crypto-random OTP
- Salted hashing
- 15-minute expiry
- 3 attempt lockout
- Cooldown periods

---

## Part 8: Testing Tasks Completed

### 8.1 Sample Data ✅
Created `sample-data.json`:
- 5 sample products (camera, bike, tent, drone, washer)
- 5 sample users (3 owners, 2 renters)
- 10 categories

### 8.2 Health Check ✅
Endpoint: GET /api/health
Response:
```json
{
  "success": true,
  "data": {
    "status": "ok",
    "timestamp": "2024-01-01T00:00:00Z",
    "service": "Rento API"
  }
}
```

---

## Part 9: Order Lifecycle Implementation

### 9.1 Status Flow ✅
```
booking_created → payment_done → ready_for_pickup 
              → active_rental → return_pending 
              → returned → completed
```

### 9.2 Status Descriptions ✅
1. **booking_created** - Booking created, payment pending
2. **payment_done** - Payment verified
3. **ready_for_pickup** - OTP generated
4. **active_rental** - Item handed over
5. **return_pending** - Return initiated
6. **returned** - Owner confirmed
7. **completed** - Fully done, ratings enabled
8. **cancelled** - Booking cancelled
9. **expired** - Auto-expired unpaid
10. **otp_locked** - Too many failed OTP attempts

---

## Part 10: How to Use This Backend

### 10.1 Setup Steps

1. **Install Dependencies:**
```bash
npm install
```

2. **Configure Firebase:**
- Download service account JSON from Firebase Console
- Replace `config/firebase-service-account.json`

3. **Configure Razorpay:**
- Get keys from Razorpay Dashboard
- Update `.env` file

4. **Start Server:**
```bash
npm start
```

5. **Test:**
```bash
curl http://localhost:3000/api/health
```

### 10.2 Typical User Flow

1. **User lists product:**
```
POST /api/products
Body: { title, description, price_per_day, category }
Headers: Authorization: Bearer <firebase_token>
```

2. **User books product:**
```
POST /api/bookings
Body: { product_id, start_date, end_date }
Headers: Authorization: Bearer <firebase_token>
```

3. **User pays:**
```
POST /api/payments/create-order
Body: { booking_id }
Headers: Authorization: Bearer <firebase_token>
```

4. **Owner generates OTP:**
```
POST /api/handover/generate-otp
Body: { booking_id }
Headers: Authorization: Bearer <firebase_token>
```

5. **User picks up (OTP verified):**
```
POST /api/handover/verify-otp
Body: { booking_id, otp }
Headers: Authorization: Bearer <firebase_token>
```

6. **User returns:**
```
POST /api/return/return-item
Body: { booking_id, return_images }
Headers: Authorization: Bearer <firebase_token>
```

7. **Owner confirms:**
```
POST /api/return/confirm-return
Body: { booking_id, condition_notes }
Headers: Authorization: Bearer <firebase_token>
```

8. **Both rate each other:**
```
POST /api/ratings/rate-user
Body: { booking_id, rating, review }
Headers: Authorization: Bearer <firebase_token>
```

---

## Summary of All Files Created

| File | Purpose |
|------|---------|
| package.json | Dependencies |
| server.js | Express server |
| .env | Environment template |
| config/firebase.config.js | Firebase setup |
| config/firebase-service-account.json | Credentials template |
| config/indexes.json | Firestore indexes |
| middleware/auth.js | Token verification |
| middleware/errorHandler.js | Error handling |
| middleware/rateLimiter.js | Rate limits |
| middleware/validators.js | Input validation |
| routes/products.js | Product APIs |
| routes/bookings.js | Booking APIs |
| routes/payments.js | Payment APIs |
| routes/handover.js | OTP APIs |
| routes/return.js | Return APIs |
| routes/ratings.js | Rating APIs |
| routes/kyc.js | KYC APIs |
| services/razorpay.service.js | Razorpay integration |
| services/logger.js | Winston logging |
| sample-data.json | Test data |
| README.md | This file |

---

## Implementation Complete ✅

All 10 core features have been implemented as per the requirements:
1. ✅ Authentication (Firebase)
2. ✅ Basic KYC
3. ✅ Product Listing
4. ✅ Product Browsing
5. ✅ Booking System
6. ✅ Payment System (Razorpay)
7. ✅ Order Lifecycle
8. ✅ OTP Handover
9. ✅ Return Flow
10. ✅ Rating System

The backend is production-ready with security middleware, error handling, and logging.

---

**License:** MIT
# Rento
