# 📦 Live Order - Real-time Logistics Management System

![Flutter](https://img.shields.io/badge/Flutter-3.12.0+-blue?style=flat-square)
![Dart](https://img.shields.io/badge/Dart-3.12+-blue?style=flat-square)
![License](https://img.shields.io/badge/License-Proprietary-red?style=flat-square)
![Platform](https://img.shields.io/badge/Platform-iOS%20%7C%20Android%20%7C%20Web-brightgreen?style=flat-square)

---

## 🌟 Overview

**Live Order** is a cutting-edge Flutter-based logistics management application that connects users, drivers, and administrators in a seamless real-time order tracking and delivery ecosystem. The app enables users to request cargo delivery services, track shipments in real-time, communicate with drivers, and manage payments—all within an intuitive mobile interface.

### Key Highlights
- ✅ **Real-time Order Tracking** with live GPS location updates
- ✅ **Multi-role Architecture** (User, Driver, Admin)
- ✅ **In-app Chat & Communication** with instant messaging
- ✅ **Rewards & Loyalty Program** with referral system
- ✅ **Advanced Driver Management** with ratings and reviews
- ✅ **Secure Authentication** via Supabase
- ✅ **Push Notifications** using Firebase Cloud Messaging
- ✅ **Google Maps Integration** for location services

---

## 🏗️ Project Architecture

### Clean Architecture + BLoC Pattern

The project follows **Clean Architecture** principles with **BLoC** for state management:

```
lib/
├── core/                           # Shared across features
│   ├── constants/                  # App-wide constants & theme data
│   ├── models/                     # Core domain models
│   ├── routing/                    # Navigation & route definitions
│   ├── utils/                      # Helpers (storage, logging, dialogs)
│   └── widgets/                    # Reusable UI components
│
├── features/                       # Feature-specific modules
│   ├── auth/                       # Authentication & login
│   ├── admin/                      # Admin dashboard
│   ├── user_home/                  # User dashboard
│   ├── driver_home/                # Driver dashboard
│   ├── user_drivers/               # Driver listing & details
│   ├── driver_orders/              # Order management for drivers
│   ├── user_tracking/              # Real-time shipment tracking
│   ├── user_chat/                  # User-to-driver messaging
│   ├── driver_chat/                # Driver-to-user messaging
│   ├── user_rate_driver/           # Driver rating system
│   ├── user_rewards/               # Loyalty & rewards management
│   ├── user_payments/              # Payment processing
│   ├── user_account/               # User profile management
│   ├── user_notifications/         # Notification center
│   ├── user_create_shipment/       # Shipment creation flow
│   └── session/                    # Session management
│
└── main_production.dart            # Production entry point
```

### Feature Structure

Each feature follows this pattern:

```
feature/
├── ui/
│   ├── screen.dart                 # Main screen component
│   └── widget/                     # Feature-specific widgets
├── logic/
│   ├── cubit/                      # State management (BLoC)
│   └── state.dart                  # State definitions
├── data/
│   ├── model/                      # Data models
│   └── repository/                 # Data layer logic
```

---

## 📱 Features

### 👤 For Users
- **Dashboard**: View active shipments and order statistics
- **Create Shipment**: Intuitive flow to create new delivery orders
- **Real-time Tracking**: Live location updates with interactive map
- **Driver Management**: Browse available drivers, view ratings & reviews
- **Chat & Communication**: Direct messaging with assigned driver
- **Order History**: Detailed tracking of all past shipments
- **Driver Ratings**: Review and rate drivers after delivery
- **Rewards Program**: Earn points, track balance, and referral bonuses
- **Notifications**: Real-time push notifications for order updates
- **Payment Management**: Secure payment processing and history
- **Profile Management**: Edit profile, manage preferences, stored addresses

### 🚗 For Drivers
- **Job Board**: View and accept available delivery jobs
- **Order Management**: Track assigned orders and statuses
- **Navigation**: Google Maps integration for optimal routing
- **Customer Chat**: Real-time communication with users
- **Income Tracking**: Monitor earnings and daily statistics
- **Profile**: Manage vehicle details, documents, and ratings

### 👨‍💼 For Admins
- **Dashboard**: System-wide analytics and monitoring
- **User Management**: Manage users, drivers, and accounts
- **Order Oversight**: Monitor all active and completed orders
- **Payment Management**: Track transactions and settlements
- **Report Generation**: View detailed business metrics

---

## 🛠️ Tech Stack

### Framework & Language
- **Flutter** 3.12.0+ - Modern cross-platform mobile framework
- **Dart** 3.12+ - Type-safe language for Flutter

### State Management
- **flutter_bloc** (9.1.1) - BLoC pattern implementation
- **equatable** (2.0.8) - Value equality

### Backend & Authentication
- **Supabase** (2.8.3) - PostgreSQL backend with Auth API
- **Firebase Core** (4.9.0) - Firebase integration base
- **Firebase Messaging** (16.2.2) - Cloud push notifications

### Location & Maps
- **Google Maps Flutter** (2.17.1) - Interactive maps
- **Geolocator** (14.0.2) - GPS location services

### UI & Design
- **flutter_screenutil** (5.9.3) - Responsive design scaling
- **google_fonts** (8.1.0) - Google Fonts integration
- **lottie** (3.3.3) - Animated Lottie files
- **cached_network_image** (3.4.1) - Image caching

### Utilities
- **go_transitions** (0.8.3) - Page transitions
- **flutter_secure_storage** (10.3.1) - Secure token storage
- **get_it** (9.2.1) - Service locator/dependency injection
- **dartz** (0.10.1) - Functional programming (Either/Option)
- **animated_snack_bar** (0.4.0) - Custom notifications
- **flutter_dotenv** (5.2.1) - Environment configuration
- **image_picker** (1.1.2) - Image selection
- **intl** (0.20.2) - Localization & formatting

### Development Tools
- **flutter_launcher_icons** (0.13.1) - App icon generation
- **flutter_native_splash** (2.4.0) - Native splash screens
- **flutter_lints** (6.0.0) - Code quality linting

---

## 🚀 Getting Started

### Prerequisites
- Flutter SDK 3.12.0 or higher
- Dart 3.12 or higher
- Xcode 14+ (for iOS)
- Android Studio (for Android)
- Git

### Installation

1. **Clone the repository**
   ```bash
   git clone <repository-url>
   cd live_order
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Configure environment variables**
   ```bash
   # Create .env file in project root
   cp .env.example .env
   
   # Add your configuration:
   # - Supabase URL
   # - Supabase Anon Key
   # - Firebase Project ID
   # - Google Maps API Key
   ```

4. **Run code generation** (if needed)
   ```bash
   flutter pub run build_runner build
   ```

5. **Run the app**
   ```bash
   # Development
   flutter run lib/main_staging.dart
   
   # Production
   flutter run lib/main_production.dart
   ```

### Build & Deployment

**Android**
```bash
flutter build apk --release
# or
flutter build appbundle --release
```

**iOS**
```bash
flutter build ios --release
```

---

## 🔧 Configuration

### Environment Setup

The app supports multiple environments via `.env` file:

```env
SUPABASE_URL=https://your-project.supabase.co
SUPABASE_ANON_KEY=your_anon_key_here
GOOGLE_MAPS_API_KEY=your_google_maps_key
FIREBASE_PROJECT_ID=your_firebase_project
```

### Firebase Setup

1. Create a Firebase project in [Firebase Console](https://console.firebase.google.com)
2. Add iOS and Android apps
3. Download `google-services.json` (Android) and `GoogleService-Info.plist` (iOS)
4. Place files in respective platform directories

### Supabase Setup

1. Create a Supabase project
2. Configure authentication (Email/Password, OAuth)
3. Create necessary database tables and policies
4. Enable Row Level Security (RLS)

---

## 📊 Data Flow

```
┌─────────────┐
│   UI Layer  │ (Screens & Widgets)
└──────┬──────┘
       │
┌──────▼──────────────────┐
│  State Management Layer  │ (BLoC/Cubit)
└──────┬──────────────────┘
       │
┌──────▼──────────────────┐
│   Repository Layer      │ (Business Logic)
└──────┬──────────────────┘
       │
┌──────▼──────────────────┐
│   Data Source Layer     │ (Supabase, Firebase, Local)
└─────────────────────────┘
```

---

## 📦 Key Features Implementation

### Real-time Order Tracking
- Utilizes Google Maps Flutter for interactive mapping
- Geolocator tracks driver position updates
- BLoC manages location state and UI updates
- WebSocket connections for real-time data

### Push Notifications
- Firebase Cloud Messaging (FCM) for delivery
- Background message handling
- Deep linking to relevant screens

### Chat System
- Real-time messaging between users and drivers
- Message persistence in Supabase
- Typing indicators and read receipts

### Payment Processing
- Secure transaction handling
- Multiple payment method support
- Transaction history and receipts

### Rewards Program
- Point accumulation system
- Referral bonus tracking
- Redemption management

---

## 🧪 Testing

```bash
# Run unit tests
flutter test

# Run integration tests
flutter test integration_test

# Generate coverage report
flutter test --coverage
```

---

## 📝 Code Conventions

### Naming Conventions
- **Classes**: PascalCase (e.g., `UserProfile`)
- **Variables/Functions**: camelCase (e.g., `getDriversList`)
- **Constants**: camelCase with underscore prefix (e.g., `_defaultTimeout`)
- **Files**: snake_case (e.g., `user_profile.dart`)

### BLoC Naming
- **Cubit**: `{Feature}Cubit` (e.g., `DriversCubit`)
- **State**: `{Feature}State` (e.g., `DriversState`)
- **Events**: `{Feature}Event` (e.g., `DriversEvent`)

### Imports Order
```dart
import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:live_order/core/...';
import 'package:live_order/features/...';
```

---

## 🔐 Security Best Practices

✅ **Implemented**
- Secure token storage using `flutter_secure_storage`
- Row-level security (RLS) in Supabase
- Environment variable management via `.env`
- HTTPS only for API communication
- Input validation on all forms
- Secure session management

⚠️ **In Progress**
- Biometric authentication
- Certificate pinning
- Enhanced encryption for sensitive data

---

## 🐛 Troubleshooting

### Common Issues

**Flutter dependencies conflict**
```bash
flutter pub get
flutter clean
flutter pub get
```

**Google Maps not showing (Android)**
- Verify API key in `AndroidManifest.xml`
- Enable Google Maps API in Google Cloud Console
- Check SHA-1 fingerprint matches

**Firebase initialization error**
- Ensure `google-services.json` and `GoogleService-Info.plist` are in correct locations
- Verify Firebase project credentials

**Supabase connection failed**
- Confirm `.env` variables are correct
- Check internet connectivity
- Verify Supabase project is active

---

## 📚 Project Resources

- [Flutter Documentation](https://docs.flutter.dev)
- [BLoC Library](https://bloclibrary.dev)
- [Supabase Documentation](https://supabase.com/docs)
- [Firebase Documentation](https://firebase.google.com/docs)
- [Google Maps SDK](https://developers.google.com/maps)

---

## 👨‍💼 Development Team

**Lead Developer**: Sohib Emad

---

## 📄 License

This project is proprietary and confidential. All rights reserved.

---

## 🤝 Contributing

For contributions and bug reports, please contact the development team.

---

## 📞 Support

For issues and questions:
1. Check existing GitHub issues
2. Review project documentation
3. Contact the development team

---

**Last Updated**: June 2026  
**Current Version**: 1.0.0  
**Status**: 🟢 Active Development

