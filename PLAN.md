# PLAN.md

# Rento Product and Execution Plan

Reviewed on May 3, 2026.

This plan replaces the original MVP build checklist. The product is already built past MVP in several areas, but it now needs trust, operational discipline, better UX, and a cleaner strategic roadmap.

## Executive Summary

Rento already has the core skeleton of a product-rental marketplace:

- authentication
- product listings
- bookings
- Razorpay payments
- OTP handover
- return flow
- ratings
- trust score
- manual KYC review
- chat
- notifications
- admin tooling

What it does not yet have is the level of trust, operational maturity, and UX clarity that users now expect from a two-sided rental marketplace.

The next phase should not be “add more screens.”
It should be:

1. make the current flows reliable
2. make trust and payouts real
3. make the marketplace easier to use on both sides
4. make the design system ready for both dark and light themes

## Reality Check

### What Exists Today

- Mobile app built in Flutter
- Admin panel built in React
- MongoDB-backed backend with JWT auth
- Manual KYC with uploaded ID image
- Trust score driven by a few additive events
- Payment capture via Razorpay
- Placeholder payout release
- Local file uploads for product and KYC images

### What Is Still Too Basic

- KYC is largely a document upload + admin approve/reject process
- owner approval before payment does not exist
- search/discovery is minimal
- cancellation and no-show logic is incomplete
- payout / escrow logic is not production-grade
- dispute tooling is thin
- status vocabulary is inconsistent
- light theme is not truly implemented

## Market Expectations Snapshot

Current marketplace norms strongly suggest the next investments should center on trust, protection, and operational rigor:

- Airbnb requires identity verification for hosts and booking guests, shows a verification badge after approval, and positions verification as a trust prerequisite rather than a nice-to-have. Source: [Airbnb identity verification](https://www.airbnb.com/help/article/450/what-is-verified-id?_set_bev_on_new_domain=1756383185_EAMGJhZDZhM2U3M2&locale=en)
- Airbnb also bundles host-facing protection and screening into the product promise. Source: [AirCover for Hosts](https://www.airbnb.com/resources/hosting-homes/a/improved-protections-for-hosts-and-guests-526)
- Turo formalizes check-in verification, photo evidence, cancellation windows, no-show handling, and host/guest accountability in detail. Sources: [Turo cancellation policy](https://turo.com/us/en/policies/cancellation), [Turo first-trip check-in flow](https://turo.com/us/en/car-rental/canada/renting-your-first-car), [Turo remote check-in guide](https://explore.turo.com/contactless-check-in-guide//)
- Marketplace payouts are expected to support linked accounts, split settlements, refunds, and reconciliation rather than a single platform account holding everything manually. Source: [Razorpay Route](https://razorpay.com/docs/payments/route/?locale=en-US)
- Modern marketplace payment stacks also treat identity verification, KYC, sanctions screening, and payout timing as platform primitives. Source: [Stripe Connect](https://stripe.com/connect)

Inference from these sources:

- trust must be visible, not hidden
- protection must be productized, not implied
- cancellation, no-show, and handover rules must be explicit
- payout operations must be first-class

## Product Priorities

## Phase 0: Immediate Blockers

Target: 1 to 2 weeks

### Reliability and Security

- Fix OTP generation/display mismatch between Flutter and backend.
- Add strict admin authorization to support admin endpoints.
- Make payment verification idempotent and renter-owned.
- Normalize booking status values across backend, Flutter, and admin.
- Persist admin login state on refresh and implement real logout.

### Core Marketplace Logic

- Add owner accept / decline before renter payment.
- Prevent users from listing or booking if the business wants KYC as a gate.
- Define a real cancellation and no-show policy in both backend rules and UI copy.

### Operational Hygiene

- Standardize API response shapes.
- Remove or isolate stale Firebase/Firestore references from docs and internal planning.
- Replace localhost-only assumptions in mobile/admin configuration.

## Phase 1: Trust and Safety Foundation

Target: next 2 to 4 weeks

### KYC

- Decide whether KYC is required for:
  - all users before first booking
  - owners before first listing
  - payout activation only
- Add structured review notes and mandatory rejection reasons.
- Allow resubmission after rejection with clear history.
- Store verified timestamp, reviewer ID, and review audit trail.
- Move KYC files away from local uploads into secure storage.

### Trust Signals

- Make verified badges visible everywhere they matter:
  - listing cards
  - product detail
  - profile
  - checkout
  - chat
- Split trust score into understandable components:
  - identity
  - completion rate
  - rating quality
  - cancellations
  - disputes / damage issues
- Show “why this score exists,” not just the number.

### Evidence and Disputes

- Add condition photo capture at pickup and return.
- Add renter and owner evidence upload for disputes.
- Turn disputes into a real workflow instead of a mostly passive admin list.

## Phase 2: Marketplace UX Upgrade

Target: next 3 to 6 weeks

### Listing Quality

- Support multiple listing images consistently.
- Add condition, brand, model, age, replacement value, and pickup area fields.
- Add availability calendar / blocked dates.
- Add pickup and return instructions.
- Add optional delivery or meetup rules.

### Discovery

- Implement real search, not only category filtering.
- Add sort by price, recency, trust, and rating.
- Add availability-aware filtering.
- Add saved / favorited listings.
- Add “owner response time” and “owner completion rate” as decision aids.

### Booking Experience

- Show booking state progression clearly:
  - requested
  - accepted
  - paid
  - ready for pickup
  - active
  - return pending
  - completed
- Add checkout summary with policy acknowledgements.
- Show cancellation and deposit rules before payment.
- Add booking detail screens instead of routing back to the orders list.

## Phase 3: Payments and Payouts

Target: next 3 to 6 weeks in parallel with Phase 2

### Money Movement

- Replace placeholder payout release with actual marketplace settlement logic.
- Evaluate Razorpay Route for linked accounts and split transfers.
- Record fee breakdown explicitly:
  - rental subtotal
  - platform fee
  - payment fee
  - deposit held
  - payout amount

### Refunds

- Add clear refund policy branches:
  - owner rejects request
  - renter cancels in grace period
  - renter cancels late
  - owner cancels
  - no-show
  - trust/safety cancellation

### Admin Finance Ops

- Add payout aging dashboard.
- Add manual hold / release queue.
- Add reconciliation views for booking, payment, refund, and payout states.

## Phase 4: Dual-Theme Design System

Target: next 2 to 4 weeks after the state model is stabilized

### Theme Migration

- Stop hardcoding dark colors directly in screens.
- Introduce semantic tokens for:
  - background
  - surface
  - border
  - muted text
  - success/warning/error
  - brand accents
- Support `ThemeMode.system`, `ThemeMode.dark`, and `ThemeMode.light`.

### Component Pass

- Audit all shared widgets first:
  - buttons
  - cards
  - inputs
  - status chips
  - app bars
  - empty states
- Only then migrate screens.

### UX Direction

- Keep dark mode premium and strong.
- Make light mode feel intentional, not a reversed dark theme.
- Improve hierarchy and contrast in admin as well as mobile.

## Phase 5: Admin and Operations Maturity

Target: next 3 to 5 weeks

### Admin Panel

- Persist auth and user session.
- Add filters, pagination, and detail drawers.
- Add case timelines for KYC and disputes.
- Add manual notes on bookings, users, and disputes.
- Add trust/risk flags for suspicious behavior.

### Metrics

Track these as first-class product metrics:

- listing-to-booking conversion
- booking-to-paid conversion
- paid-to-completed conversion
- owner cancellation rate
- renter cancellation rate
- KYC submission-to-approval time
- dispute rate per completed rental
- return damage claim rate
- average trust score by completed cohort

## Testing and Release Readiness

This repo needs much stronger coverage before aggressive feature expansion.

### Backend

- add route tests for auth, bookings, payments, KYC, support admin protection
- add idempotency tests for payment verification
- add lifecycle tests for booking -> payment -> OTP -> return -> rating

### Flutter

- add provider tests
- add widget tests for booking, payment, KYC, orders
- add smoke tests for both dark and light modes once theming is real

### Admin

- add basic API integration tests or end-to-end smoke checks
- verify all critical pages with seeded admin accounts

## Suggested Build Sequence

1. Fix security and broken flow issues.
2. Normalize lifecycle states and response contracts.
3. Add owner approval, clearer cancellation policy, and booking detail UX.
4. Make KYC and trust visible, structured, and enforceable.
5. Replace simulated payout logic with real marketplace settlement infrastructure.
6. Migrate to a semantic design system and launch real light mode.
7. Deepen admin operations and metrics once the core flow is stable.

## Non-Negotiables for Future Work

- Do not scale growth features before trust-critical flows are correct.
- Do not add light mode by sprinkling one-off color overrides.
- Do not treat the trust score as a substitute for KYC, evidence capture, or policy enforcement.
- Do not ship marketplace payouts to production without proper settlement, reconciliation, and compliance review.

## Recommended First Deliverables

If work starts immediately, the highest-value first batch is:

1. Fix OTP handover flow.
2. Lock down support admin authorization.
3. Add owner accept / decline before payment.
4. Make payment verification safe and idempotent.
5. Normalize status labels across backend and Flutter.
6. Rewrite the booking and KYC copy so the product promise matches reality.
