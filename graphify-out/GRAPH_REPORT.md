# Graph Report - /sessions/magical-happy-noether/mnt/rento  (2026-05-02)

## Corpus Check
- 182 files · ~80,101 words
- Verdict: corpus is large enough that graph structure adds value.

## Summary
- 586 nodes · 651 edges · 31 communities detected
- Extraction: 99% EXTRACTED · 1% INFERRED · 0% AMBIGUOUS · INFERRED: 9 edges (avg confidence: 0.8)
- Token cost: 0 input · 0 output

## Community Hubs (Navigation)
- [[_COMMUNITY_Product Listing & Discovery|Product Listing & Discovery]]
- [[_COMMUNITY_Booking & KYC Screens|Booking & KYC Screens]]
- [[_COMMUNITY_Core Services & API Layer|Core Services & API Layer]]
- [[_COMMUNITY_Auth & Chat Providers|Auth & Chat Providers]]
- [[_COMMUNITY_Booking & Payment Flow|Booking & Payment Flow]]
- [[_COMMUNITY_Windows Platform Runner|Windows Platform Runner]]
- [[_COMMUNITY_App Theme & UI Screens|App Theme & UI Screens]]
- [[_COMMUNITY_User Profile Management|User Profile Management]]
- [[_COMMUNITY_Home Screen|Home Screen]]
- [[_COMMUNITY_Orders & Booking Cards|Orders & Booking Cards]]
- [[_COMMUNITY_Customer Support Chat|Customer Support Chat]]
- [[_COMMUNITY_Push Notifications UI|Push Notifications UI]]
- [[_COMMUNITY_Account Settings|Account Settings]]
- [[_COMMUNITY_Linux Platform Runner|Linux Platform Runner]]
- [[_COMMUNITY_Shared UI Widgets|Shared UI Widgets]]
- [[_COMMUNITY_Community 15|Community 15]]
- [[_COMMUNITY_Community 16|Community 16]]
- [[_COMMUNITY_Community 17|Community 17]]
- [[_COMMUNITY_Community 18|Community 18]]
- [[_COMMUNITY_Community 20|Community 20]]
- [[_COMMUNITY_Community 21|Community 21]]
- [[_COMMUNITY_Community 22|Community 22]]
- [[_COMMUNITY_Community 26|Community 26]]
- [[_COMMUNITY_Community 27|Community 27]]
- [[_COMMUNITY_Community 28|Community 28]]
- [[_COMMUNITY_Community 31|Community 31]]
- [[_COMMUNITY_Community 32|Community 32]]
- [[_COMMUNITY_Community 40|Community 40]]
- [[_COMMUNITY_Community 41|Community 41]]
- [[_COMMUNITY_Community 42|Community 42]]
- [[_COMMUNITY_Community 43|Community 43]]

## God Nodes (most connected - your core abstractions)
1. `package:flutter/material.dart` - 31 edges
2. `../core/constants/app_colors.dart` - 21 edges
3. `package:provider/provider.dart` - 16 edges
4. `../core/constants/app_strings.dart` - 12 edges
5. `../../providers/auth_provider.dart` - 11 edges
6. `../../widgets/rento_card.dart` - 10 edges
7. `../../core/services/api_service.dart` - 7 edges
8. `AppDelegate` - 6 edges
9. `../models/product_model.dart` - 6 edges
10. `../../widgets/rento_button.dart` - 6 edges

## Surprising Connections (you probably didn't know these)
- `startServer()` --calls--> `connectDB()`  [INFERRED]
  server.js → config/db.js
- `main()` --calls--> `my_application_new()`  [INFERRED]
  frontend/linux/runner/main.cc → frontend/linux/runner/my_application.cc
- `my_application_activate()` --calls--> `fl_register_plugins()`  [INFERRED]
  frontend/linux/runner/my_application.cc → frontend/linux/flutter/generated_plugin_registrant.cc
- `OnCreate()` --calls--> `GetClientArea()`  [INFERRED]
  frontend/windows/runner/flutter_window.cpp → frontend/windows/runner/win32_window.cpp
- `OnCreate()` --calls--> `RegisterPlugins()`  [INFERRED]
  frontend/windows/runner/flutter_window.cpp → frontend/windows/flutter/generated_plugin_registrant.cc

## Communities

### Community 0 - "Product Listing & Discovery"
Cohesion: 0.04
Nodes (51): ../core/constants/api_constants.dart, ../core/utils/currency_utils.dart, ../models/product_model.dart, package:cached_network_image/cached_network_image.dart, package:shimmer/shimmer.dart, _applyFilter, clearError, clearSelected (+43 more)

### Community 1 - "Booking & KYC Screens"
Cohesion: 0.05
Nodes (42): ../core/constants/app_colors.dart, ../core/constants/app_strings.dart, dart:io, package:image_picker/image_picker.dart, BookingScreen, build, _dateCell, Divider (+34 more)

### Community 2 - "Core Services & API Layer"
Cohesion: 0.05
Nodes (38): api_service.dart, ../../app.dart, ../constants/api_constants.dart, ../core/services/auth_service.dart, ../core/services/push_notification_service.dart, dart:async, dart:convert, ../models/user_model.dart (+30 more)

### Community 3 - "Auth & Chat Providers"
Cohesion: 0.06
Nodes (33): package:provider/provider.dart, ../../providers/auth_provider.dart, build, Center, dispose, LoginScreen, _LoginScreenState, Scaffold (+25 more)

### Community 4 - "Booking & Payment Flow"
Cohesion: 0.06
Nodes (30): ../../core/services/api_service.dart, ../../models/booking_model.dart, ../models/message_model.dart, package:flutter/material.dart, package:razorpay_flutter/razorpay_flutter.dart, AppColors, BookingProvider, clearError (+22 more)

### Community 5 - "Windows Platform Runner"
Cohesion: 0.11
Nodes (19): RegisterPlugins(), FlutterWindow(), OnCreate(), Create(), Destroy(), EnableFullDpiSupportIfAvailable(), GetClientArea(), GetThisFromHandle() (+11 more)

### Community 6 - "App Theme & UI Screens"
Cohesion: 0.08
Nodes (25): core/theme/app_theme.dart, screens/auth/login_screen.dart, screens/booking/booking_screen.dart, screens/chat/chat_list_screen.dart, screens/chat/chat_screen.dart, screens/home/home_screen.dart, screens/kyc/kyc_screen.dart, screens/notifications/notifications_screen.dart (+17 more)

### Community 7 - "User Profile Management"
Cohesion: 0.08
Nodes (24): build, _buildTextField, dispose, EditProfileScreen, _EditProfileScreenState, initState, Scaffold, SizedBox (+16 more)

### Community 8 - "Home Screen"
Cohesion: 0.11
Nodes (18): build, _CategoryChips, dispose, _EmptySliver, _ErrorSliver, FilterChip, HomeScreen, _HomeScreenState (+10 more)

### Community 9 - "Orders & Booking Cards"
Cohesion: 0.11
Nodes (18): _BookingCard, _BookingList, build, Center, dispose, Divider, Icon, _infoChip (+10 more)

### Community 10 - "Customer Support Chat"
Cohesion: 0.11
Nodes (18): Align, build, _buildChatBubble, _buildEmptyState, _buildInputArea, Center, Container, dispose (+10 more)

### Community 11 - "Push Notifications UI"
Cohesion: 0.12
Nodes (15): build, _buildEmptyState, _buildNotificationItem, Center, _formatDate, _getIcon, _getIconBgColor, _getIconColor (+7 more)

### Community 12 - "Account Settings"
Cohesion: 0.13
Nodes (14): build, _buildPasswordField, _buildSectionHeader, dispose, Divider, ListTile, Scaffold, SettingsScreen (+6 more)

### Community 13 - "Linux Platform Runner"
Cohesion: 0.14
Nodes (4): fl_register_plugins(), main(), my_application_activate(), my_application_new()

### Community 14 - "Shared UI Widgets"
Cohesion: 0.14
Nodes (12): ../constants/app_colors.dart, package:flutter/services.dart, package:google_fonts/google_fonts.dart, AppTheme, _buildDark, _buildLight, _interTextTheme, ThemeData (+4 more)

### Community 15 - "Community 15"
Cohesion: 0.15
Nodes (11): package:intl/intl.dart, CurrencyUtils, format, formatDecimal, perDay, daysBetween, display, range (+3 more)

### Community 16 - "Community 16"
Cohesion: 0.17
Nodes (11): ../../core/utils/date_utils.dart, build, Center, ChatListScreen, _ChatListScreenState, Icon, initState, ListTile (+3 more)

### Community 17 - "Community 17"
Cohesion: 0.2
Nodes (9): ApiConstants, bookingDetails, cancelBooking, chatConversation, markRead, paymentByBooking, productById, returnStatus (+1 more)

### Community 18 - "Community 18"
Cohesion: 0.29
Nodes (2): FlutterAppDelegate, AppDelegate

### Community 20 - "Community 20"
Cohesion: 0.33
Nodes (3): RegisterGeneratedPlugins(), NSWindow, MainFlutterWindow

### Community 21 - "Community 21"
Cohesion: 0.47
Nodes (4): wWinMain(), CreateAndAttachConsole(), GetCommandLineArguments(), Utf8FromUtf16()

### Community 22 - "Community 22"
Cohesion: 0.4
Nodes (2): RunnerTests, XCTestCase

### Community 26 - "Community 26"
Cohesion: 0.5
Nodes (2): connectDB(), startServer()

### Community 27 - "Community 27"
Cohesion: 0.83
Nodes (3): log(), request(), runTests()

### Community 28 - "Community 28"
Cohesion: 0.67
Nodes (2): hashOTP(), verifyOTPHash()

### Community 31 - "Community 31"
Cohesion: 0.67
Nodes (2): copyWith, ProductModel

### Community 32 - "Community 32"
Cohesion: 0.67
Nodes (2): ConversationModel, MessageModel

### Community 40 - "Community 40"
Cohesion: 1.0
Nodes (1): MainActivity

### Community 41 - "Community 41"
Cohesion: 1.0
Nodes (1): AppStrings

### Community 42 - "Community 42"
Cohesion: 1.0
Nodes (1): BookingModel

### Community 43 - "Community 43"
Cohesion: 1.0
Nodes (1): UserModel

## Knowledge Gaps
- **345 isolated node(s):** `MainActivity`, `main`, `SystemUiOverlayStyle`, `package:firebase_core/firebase_core.dart`, `RentoApp` (+340 more)
  These have ≤1 connection - possible missing edges or undocumented components.
- **Thin community `Community 18`** (7 nodes): `FlutterAppDelegate`, `AppDelegate.swift`, `AppDelegate.swift`, `AppDelegate`, `.application()`, `.applicationShouldTerminateAfterLastWindowClosed()`, `.applicationSupportsSecureRestorableState()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 22`** (5 nodes): `RunnerTests.swift`, `RunnerTests.swift`, `RunnerTests`, `.testExample()`, `XCTestCase`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 26`** (4 nodes): `connectDB()`, `db.js`, `startServer()`, `server.js`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 28`** (4 nodes): `generateSecureOTP()`, `hashOTP()`, `handover.js`, `verifyOTPHash()`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 31`** (3 nodes): `product_model.dart`, `copyWith`, `ProductModel`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 32`** (3 nodes): `message_model.dart`, `ConversationModel`, `MessageModel`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 40`** (2 nodes): `MainActivity.kt`, `MainActivity`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 41`** (2 nodes): `app_strings.dart`, `AppStrings`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 42`** (2 nodes): `booking_model.dart`, `BookingModel`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.
- **Thin community `Community 43`** (2 nodes): `user_model.dart`, `UserModel`
  Too small to be a meaningful cluster - may be noise or needs more connections extracted.

## Suggested Questions
_Questions this graph is uniquely positioned to answer:_

- **Why does `package:flutter/material.dart` connect `Booking & Payment Flow` to `Product Listing & Discovery`, `Booking & KYC Screens`, `Core Services & API Layer`, `Auth & Chat Providers`, `App Theme & UI Screens`, `User Profile Management`, `Home Screen`, `Orders & Booking Cards`, `Customer Support Chat`, `Push Notifications UI`, `Account Settings`, `Shared UI Widgets`, `Community 16`?**
  _High betweenness centrality (0.235) - this node is a cross-community bridge._
- **Why does `../core/constants/app_colors.dart` connect `Booking & KYC Screens` to `Product Listing & Discovery`, `Auth & Chat Providers`, `Booking & Payment Flow`, `User Profile Management`, `Home Screen`, `Orders & Booking Cards`, `Customer Support Chat`, `Push Notifications UI`, `Account Settings`, `Community 16`?**
  _High betweenness centrality (0.066) - this node is a cross-community bridge._
- **Why does `package:flutter/foundation.dart` connect `Core Services & API Layer` to `Community 17`?**
  _High betweenness centrality (0.043) - this node is a cross-community bridge._
- **What connects `MainActivity`, `main`, `SystemUiOverlayStyle` to the rest of the system?**
  _345 weakly-connected nodes found - possible documentation gaps or missing edges._
- **Should `Product Listing & Discovery` be split into smaller, more focused modules?**
  _Cohesion score 0.04 - nodes in this community are weakly interconnected._
- **Should `Booking & KYC Screens` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._
- **Should `Core Services & API Layer` be split into smaller, more focused modules?**
  _Cohesion score 0.05 - nodes in this community are weakly interconnected._