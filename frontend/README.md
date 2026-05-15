# RENTO Flutter Frontend

Premium dark-mode P2P rental marketplace UI — fintech-inspired design.

## Design System

| Token | Value |
|-------|-------|
| Background | `#0B0B0B` Matte Black |
| Surface (Cards) | `#121212` |
| Accent (CTAs) | `#B91C1C` Deep Red |
| Text Primary | `#FFFFFF` |
| Text Secondary | `#A1A1AA` |
| Borders | `#1F1F1F` |
| Border Radius | `12px` cards, `16px` modals |
| Font | Inter (via google_fonts) |

## Screens

| Screen | Route | Description |
|--------|-------|-------------|
| Splash | `/` | Animated logo, auto-navigates |
| Login | `/login` | Phone number input |
| OTP Verify | `/otp` | 6-box OTP entry with timer |
| Home | `/home` | Product feed, category filter, search |
| Product Detail | `/product` | Images, pricing, date picker, Book Now |
| Add Product | `/add-product` | Form to list a new item |
| Booking | `/booking` | Summary, price breakdown, confirm |
| Payment | `/payment` | Razorpay checkout + success state |
| Orders | `/orders` | Renter/Owner tabs with status chips |
| Profile | `/profile` | User info, KYC status, sign out |

## Setup

### 1. Initialize Flutter project

```bash
flutter create . --org com.rento --project-name rento_app
# Then replace lib/ with the files in this folder
```

### 2. Firebase Setup

```bash
flutter pub add firebase_core firebase_auth
flutterfire configure
```

This generates `lib/firebase_options.dart`. Update `main.dart`:

```dart
import 'firebase_options.dart';
// ...
await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
```

### 3. Android Permissions

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET"/>
<uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE"/>
```

For Razorpay (Android), add in `android/app/build.gradle`:

```groovy
android {
    defaultConfig {
        minSdkVersion 19
    }
}
```

### 4. API Base URL

Update `lib/core/constants/api_constants.dart`:

- **Android Emulator**: `http://10.0.2.2:3000/api`
- **iOS Simulator**: `http://localhost:3000/api`
- **Production**: `https://your-api-url.com/api`

### 5. Install & Run

```bash
flutter pub get
flutter run
```

## Project Structure

```
lib/
├── main.dart               # Entry point, providers
├── app.dart                # MaterialApp, routing
├── core/
│   ├── constants/
│   │   ├── app_colors.dart     # All colors
│   │   ├── app_strings.dart    # All UI text
│   │   └── api_constants.dart  # API endpoints
│   ├── theme/
│   │   └── app_theme.dart      # Central ThemeData
│   ├── utils/
│   │   ├── currency_utils.dart
│   │   └── date_utils.dart
│   └── services/
│       ├── api_service.dart    # HTTP calls
│       └── auth_service.dart   # Firebase Auth
├── models/
│   ├── product_model.dart
│   ├── booking_model.dart
│   └── user_model.dart
├── providers/
│   ├── auth_provider.dart
│   ├── product_provider.dart
│   └── booking_provider.dart
├── screens/
│   ├── splash/splash_screen.dart
│   ├── auth/{login,otp}_screen.dart
│   ├── home/home_screen.dart
│   ├── product/{product_detail,add_product}_screen.dart
│   ├── booking/booking_screen.dart
│   ├── payment/payment_screen.dart
│   ├── orders/orders_screen.dart
│   └── profile/profile_screen.dart
└── widgets/
    ├── rento_button.dart       # Primary/Secondary/Ghost buttons
    ├── rento_card.dart         # Dark surface card
    ├── rento_input.dart        # Styled text input
    ├── product_card.dart       # Grid product tile
    └── booking_status_chip.dart # Colored status pills
```
