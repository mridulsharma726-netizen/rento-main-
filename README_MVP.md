# Rento - P2P Rental Platform MVP

## Quick Start

### Backend (Running)
The backend is already running on **http://localhost:3000**

### Test Endpoints
```bash
# Health Check
curl http://localhost:3000/api/health

# Get Products (Demo)
curl http://localhost:3000/api/products

# Filter by Category
curl "http://localhost:3000/api/products?category=electronics"
```

## API Endpoints

### Products
| Method | Endpoint | Description |
|--------|---------|------------|
| GET | `/api/products` | List all products |
| GET | `/api/products/:id` | Get product details |
| POST | `/api/products` | Create product |
| PUT | `/api/products/:id` | Update product |
| DELETE | `/api/products/:id` | Delete product |

### Bookings
| Method | Endpoint | Description |
|--------|---------|------------|
| POST | `/api/bookings` | Create booking |
| GET | `/api/bookings/:userId` | Get user bookings |
| PUT | `/api/bookings/:id/cancel` | Cancel booking |

### Payments
| Method | Endpoint | Description |
|--------|---------|------------|
| POST | `/api/payments/create-order` | Create payment order |
| POST | `/api/payments/verify-payment` | Verify payment |
| POST | `/api/payments/refund` | Process refund |

### Handover
| Method | Endpoint | Description |
|--------|---------|------------|
| POST | `/api/handover/generate-otp` | Generate OTP |
| POST | `/api/handover/verify-otp` | Verify OTP |

### Return
| Method | Endpoint | Description |
|--------|---------|------------|
| POST | `/api/return/return-item` | Initiate return |
| POST | `/api/return/confirm-return` | Confirm return |

### Ratings
| Method | Endpoint | Description |
|--------|---------|------------|
| POST | `/api/ratings/rate-user` | Rate user |

### KYC
| Method | Endpoint | Description |
|--------|---------|------------|
| POST | `/api/kyc/upload-id-proof` | Upload ID proof |
| GET | `/api/kyc/status` | Get KYC status |

## Demo Mode

The backend runs in **demo mode** without Firebase configuration. To enable full functionality:

1. **Firebase Setup:**
   - Download service account JSON from Firebase Console
   - Replace `config/firebase-service-account.json`
   - Restart server

2. **Razorpay Setup:**
   - Add keys to `.env` file
   - Restart server

## Flutter App

The Flutter app is in the `frontend/` directory. To run:

```bash
cd frontend
flutter pub get
flutter run
```

## Project Structure

```
rento/
├── server.js              # Express server
├── package.json          # Dependencies
├── .env                # Environment
├── routes/
│   ├── products.js      # Products API
│   ├── bookings.js    # Bookings API
│   ├── payments.js   # Payments API
│   ├── handover.js   # OTP API
│   ├── return.js    # Return API
│   ├── ratings.js   # Ratings API
│   └── kyc.js     # KYC API
├── config/
│   └── firebase.config.js
├── middleware/
│   └── auth.js
└── frontend/
    └── lib/
        └── (Flutter app)
```

## Status: MVP Complete ✅

All core features implemented:
- ✅ Authentication (Firebase ready)
- ✅ Basic KYC
- ✅ Product Listing
- ✅ Product Browsing
- ✅ Booking System
- ✅ Payment System (Razorpay ready)
- ✅ Order Lifecycle
- ✅ OTP Handover
- ✅ Return Flow
- ✅ Rating System
