# CLAUDE.md

This file is the working brief for AI agents and engineers operating in this repository.
It reflects the codebase as it exists on May 3, 2026, not the older MVP/Firebase planning docs.

## Current Reality

Rento is a two-sided product rental marketplace:

- `Owner / Lender`: lists items, receives booking demand, hands over the item, confirms return, earns income.
- `Renter / Borrower`: browses inventory, books an item, pays deposit + rental, verifies pickup, returns item, rates the owner.

The stack in code today is:

- Backend: Node.js + Express + MongoDB + Mongoose + JWT
- Mobile app: Flutter
- Admin panel: React + Vite
- Payments: Razorpay
- Notifications: Firebase Cloud Messaging
- Realtime chat: Socket.IO

Important: older docs still refer to Firebase/Firestore as the primary backend. That is no longer true for the live code. Trust the implementation first.

## Product Scope Implemented Today

### Renter Flow

1. Sign up or log in with email/password or Google.
2. Browse product listings on the mobile app.
3. Select dates and create a booking request.
4. Pay total amount using Razorpay.
5. Receive / enter OTP at pickup to activate the rental.
6. Initiate return when done.
7. Rate the owner after completion.

### Owner Flow

1. Sign up or log in.
2. Optionally submit KYC.
3. Create product listings with local image upload.
4. Receive booking notifications.
5. Generate pickup OTP after payment.
6. Confirm return and optionally retain deposit.
7. Build trust score from completed bookings and ratings.

### Admin Flow

1. Log into the React admin panel with an admin user.
2. Review platform counts, users, KYC submissions, bookings, payments, and disputes.
3. Ban or unban users.
4. Approve or reject KYC.
5. View payments and manually release payouts in the current placeholder flow.

## Architecture Map

### Backend

- Entry point: `server.js`
- DB connection and indexes: `config/db.js`
- Auth middleware: `middleware/auth.js`
- Validation and sanitization: `middleware/validators.js`
- File uploads: `middleware/upload.js`
- Payment service: `services/razorpay.service.js`
- Notifications: `services/notification.service.js`
- Realtime chat: `services/socket.service.js`

### Core Backend Domains

- Auth: `routes/auth.js`
- Products: `routes/products.js`
- Bookings: `routes/bookings.js`
- Payments: `routes/payments.js`
- Handover OTP: `routes/handover.js`
- Return flow: `routes/return.js`
- Ratings: `routes/ratings.js`
- KYC: `routes/kyc.js`
- Profile: `routes/profile.js`
- Support: `routes/support.js`
- Notifications: `routes/notifications.js`
- Chat: `routes/chat.js`
- Admin: `routes/admin.js`

### Mobile App

- App shell and routing: `frontend/lib/app.dart`
- Theme system: `frontend/lib/core/theme/app_theme.dart`
- API wiring: `frontend/lib/core/services/api_service.dart`
- Auth/session: `frontend/lib/core/services/auth_service.dart`
- Providers: `frontend/lib/providers/`
- Main user screens: `frontend/lib/screens/`

### Admin Panel

- Shell and login: `admin-panel/src/App.jsx`
- Admin API client: `admin-panel/src/api.js`
- Pages: `admin-panel/src/pages/`

## Canonical Data and Statuses

### User

Main fields live in `models/User.js`:

- identity: `name`, `email`, `password`, `google_id`, `phone`
- KYC mirror fields: `kyc_status`, `kyc_id_type`, `kyc_id_number`, `kyc_image_url`, `kyc_submitted_at`
- trust fields: `trust_score`, `total_transactions`, `completed_transactions`, `cancelled_transactions`, `is_kyc_verified`
- moderation: `role`, `is_banned`
- notifications: `fcmToken`

### Product

Main fields live in `models/Product.js`:

- listing data: `title`, `description`, `category`, `price_per_day`, `deposit`, `images`
- ownership: `owner_id`
- status: currently a free-form string with values used across the app such as `available`, `rented`, `return_pending`, and `unavailable`

Important: product status is not tightly normalized today. The schema does not enforce the same state vocabulary the UI and routes use.

### Booking

Main fields live in `models/Booking.js`.

Canonical booking lifecycle in code today:

- `pending`
- `paid`
- `active`
- `completed`
- `cancelled`

Payment lifecycle:

- `pending`
- `paid`
- `refunded`
- `released`

Booking records also store:

- pricing snapshot
- Razorpay IDs and signature
- OTP handover fields
- return metadata
- deposit / commission placeholders

### KYC

Main fields live in `models/KYC.js`.

Statuses:

- `pending`
- `verified`
- `rejected`

### Return

Main fields live in `models/Return.js`.

Statuses:

- `return_pending`
- `returned`
- `rejected`

## KYC and Trust Score: How It Actually Works

### User Submission Flow

Mobile KYC starts in `frontend/lib/screens/kyc/kyc_screen.dart`.

The user submits:

- ID type
- ID number
- full legal name
- one uploaded ID image

Backend flow in `routes/kyc.js`:

1. `POST /api/kyc/upload-id-proof`
2. Save a `KYC` document with `status: pending`
3. Mirror key KYC fields onto the `User` document
4. Set `user.kyc_status = 'pending'`
5. Create an in-app notification that review has started

### Admin Review Flow

Admin review happens from `routes/admin.js` and the React KYC page.

Current review flow:

1. Admin opens pending KYC requests.
2. Admin marks a submission `verified` or `rejected`.
3. On verify:
   - `user.kyc_status` becomes `verified`
   - `user.is_kyc_verified` becomes `true`
   - trust score receives `+20`
   - user gets notification + push
4. On reject:
   - `user.kyc_status` becomes `rejected`
   - user gets notification with optional reason

### Trust Score Rules

Trust score logic lives in `utils/trustScore.js`.

Current score deltas:

- `BOOKING_COMPLETED`: `+10`
- `GOOD_RATING`: `+5`
- `KYC_VERIFIED`: `+20`
- `BOOKING_CANCELLED`: `-10`
- `COMPLAINT`: `-20`

Score is bounded to `0..100`.

This is a product trust heuristic, not a compliance-grade risk engine.

### What KYC Does Not Yet Do

Current KYC is basic and mostly manual. It does not yet enforce:

- KYC before listing
- KYC before booking
- selfie or liveness checks
- OCR extraction / mismatch detection
- document expiry checks
- duplicate / resubmission controls
- vendor verification
- audit-grade review notes
- secure document vaulting beyond local uploads

## UI and Theme Reality

### Mobile App

The Flutter UI is dark-first and manually styled.

Important implementation details:

- `MaterialApp` is hardcoded to `ThemeMode.dark` in `frontend/lib/app.dart`
- `AppTheme.light` exists, but only a small part of the component system is defined for light mode
- many screens use `AppColors.background`, `AppColors.surface`, and other dark-specific tokens directly instead of reading from `Theme.of(context)`

Implication: this is not “one toggle away” from a proper dual-theme product. A real light-theme rollout requires migrating from hardcoded dark colors to semantic theme tokens across screens and widgets.

### Admin Panel

The admin panel is also dark-only and fairly lightweight:

- glassmorphism styling
- no persistent session bootstrap on refresh
- no real design system
- mostly table-based operations UI

## Product Gaps and Critical Risks

These are the most important things future work should respect and/or fix.

### Critical Bugs and Security Issues

- OTP handover is currently broken end-to-end for owners in the app. `BookingProvider.generateOtp()` expects `data.otp`, but the backend intentionally never returns the OTP in `routes/handover.js`. The owner UI therefore cannot display the pickup code.
- Support admin endpoints are not actually admin-protected. `routes/support.js` uses `verifyToken` on `/admin` and `PATCH /:id`, which means any authenticated user could potentially access support operations.
- Payment verification lacks ownership and idempotency checks. `routes/payments.js` verifies the Razorpay signature and creates a payment, but it does not explicitly ensure the caller is the booking renter and it does not block duplicate verification writes before saving.

### Product / Marketplace Design Gaps

- Booking flow has no owner accept / decline step before payment. The renter creates a booking and moves directly to pay.
- Payout release is only a simulated state change today; there is no true marketplace settlement integration.
- Cancellation policy is incomplete. There is renter cancel before payment, but not a full late cancellation / no-show / owner cancellation framework.
- Damage handling is thin. Deposit retention exists, but evidence collection, dispute creation, and decision support are minimal.
- Search and discovery are basic: category chips, price filters on API, but no location, ranking, condition, delivery/pickup options, availability preview, or real text search.
- The support system is a simple ticket thread, not a structured trust-and-safety case workflow.

### UX / Consistency Gaps

- Status naming is inconsistent between backend and Flutter UI. Backend uses `pending/paid/active`, while some widgets still expect legacy names like `booking_created` and `payment_done`.
- Many values are hardcoded in UI copy, including things like `Member since 2024`, support contact copy, and localhost-based URLs.
- Search field on the home screen is currently visual only.
- API response shape is not fully consistent across routes.

## What This Repo Needs Next

If you are making product or engineering decisions, optimize for these themes:

1. Fix broken trust-critical flows first.
2. Normalize lifecycle states across backend, Flutter, and admin.
3. Add explicit trust gates before scale.
4. Turn “manual placeholder” payment/payout logic into real marketplace money movement.
5. Build a proper light/dark semantic design system instead of screen-by-screen color overrides.

## Guidance for Future Agents

- Treat the booking lifecycle `pending -> paid -> active -> completed/cancelled` as the current source of truth.
- Do not assume Firebase/Firestore is still the active backend just because older docs say so.
- When editing theme code, plan for both dark and light mode even if the current app is forced to dark.
- When touching KYC, trust score, or payouts, think about security, operations, dispute handling, and compliance together rather than changing a single screen in isolation.
- Preserve the distinction between owner-facing trust and renter-facing trust. This product is two-sided, so both sides need safety signals.
- Prefer documenting and fixing inconsistencies instead of papering over them in UI copy.
