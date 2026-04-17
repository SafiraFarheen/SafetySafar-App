# Flutter Frontend Setup Guide

## Prerequisites
- Flutter SDK (3.11.3 or later)
- Dart SDK (comes with Flutter)
- Android Studio or Xcode (for iOS development)
- A code editor (VS Code, Android Studio, or IntelliJ)

## Installation

### Step 1: Install Flutter
Follow the official guide: https://flutter.dev/docs/get-started/install

Verify installation:
```bash
flutter --version
dart --version
```

### Step 2: Get Project Dependencies
Navigate to the Flutter app and install dependencies:

```bash
cd safety_safar_app
flutter pub get
```

This will install all packages defined in `pubspec.yaml`:

### Flutter Packages Used

**UI & Design:**
- `google_fonts` - Custom Google Fonts for the app
- `lucide_icons` - Beautiful icon library
- `cupertino_icons` - iOS style icons
- `intl` - Internationalization and localization

**State Management & Providers:**
- `provider` - State management solution

**Authentication & Security:**
- `firebase_core` - Firebase initialization
- `firebase_auth` - Firebase authentication
- `google_sign_in` - Google OAuth sign-in

**API & Networking:**
- `http` - HTTP client for API calls

**Location & Maps:**
- `geolocator` - Get device location
- `google_maps_flutter` - Integrated Google Maps

**File & Media:**
- `image_picker` - Pick images from camera/gallery
- `qr_flutter` - Generate QR codes

**Data Persistence:**
- `shared_preferences` - Local key-value storage

**Utilities:**
- `url_launcher` - Open URLs and phone numbers

### Step 3: Configure Firebase

#### Android
1. Download `google-services.json` from Firebase Console
2. Place it in: `safety_safar_app/android/app/`

#### iOS
1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in: `safety_safar_app/ios/Runner/`
   - Add it to Xcode project
   - Make sure it's in the target's resources

### Step 4: Run the App

#### On Android Emulator:
```bash
flutter run
```

#### On iOS Simulator:
```bash
flutter run -d macos
# or
open -a Simulator
flutter run
```

#### On Physical Device:
1. Enable Developer Mode on your device
2. Connect via USB
3. Run:
```bash
flutter devices  # to see connected devices
flutter run -d <device_id>
```

## Project Structure

```
safety_safar_app/
├── lib/
│   ├── main.dart              # Entry point
│   ├── home_screen.dart       # Home page
│   ├── login_screen.dart      # Login page
│   ├── registration_screen.dart
│   ├── otp_screen.dart        # OTP verification
│   ├── reset_password_screen.dart
│   ├── digital_id_screen.dart # Digital ID feature
│   ├── screens/               # Additional screens
│   ├── services/              # API services
│   └── utils/                 # Utility functions
├── android/                   # Android native code
├── ios/                       # iOS native code
├── web/                       # Web build (if enabled)
├── test/                      # Unit tests
├── pubspec.yaml               # Dependencies
└── pubspec.lock               # Locked versions (auto-generated)
```

## Development Commands

```bash
# Get latest dependencies
flutter pub get

# Upgrade dependencies
flutter pub upgrade

# Clean build artifacts
flutter clean

# Run on specific device
flutter run -d <device_id>

# Run with debug info
flutter run -v

# Build APK (Android)
flutter build apk --release

# Build IPA (iOS)
flutter build ios --release

# Run tests
flutter test

# Analyze code
flutter analyze

# Format code
flutter format lib/
```

## Important Notes

⚠️ **Before Running:**
1. Ensure `.env` is configured in the backend (required for API calls)
2. Backend server must be running on `http://localhost:8000` or configured URL
3. Firebase project must be set up with Authentication enabled
4. Location permissions must be granted on device

## Troubleshooting

### "flutter: command not found"
- Add Flutter to your PATH: https://flutter.dev/docs/get-started/install

### Build fails on Android
```bash
flutter clean
flutter pub get
flutter run
```

### iOS build issues
```bash
cd ios
pod repo update
pod install
cd ..
flutter run
```

### Firebase configuration errors
- Verify `google-services.json` and `GoogleService-Info.plist` are in correct folders
- Check Firebase Console for correct project ID
- Ensure authentication is enabled in Firebase

