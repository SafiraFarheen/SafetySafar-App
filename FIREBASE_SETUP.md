# Firebase Configuration Guide

## Overview
Safety Safar uses Firebase for:
- **Authentication** (Email/Password, Google Sign-In)
- **Realtime Database** (optional)
- **Cloud Storage** (for KYC documents)
- **Firebase Cloud Messaging** (push notifications)

## Prerequisites
- Google account
- Firebase project created at https://console.firebase.google.com

## Step 1: Create a Firebase Project

1. Go to **Firebase Console**: https://console.firebase.google.com
2. Click **"Create a project"**
3. Enter project name (e.g., "SafetySafar")
4. Enable Google Analytics (optional)
5. Click **"Create project"**
6. Wait for project creation (usually 1-2 minutes)

## Step 2: Set Up Android App in Firebase

### 2.1 Register Android App
1. In Firebase Console, click **"+ Add app"** → **Android**
2. Fill in details:
   - **Package name**: `com.safety_safar.app`
   - **App nickname**: SafetySafar (optional)
   - **Debug signing certificate SHA-1**: (see below)
3. Click **"Register app"**

### 2.2 Get SHA-1 Certificate Fingerprint

**On Windows (PowerShell):**
```powershell
cd safety_safar_app/android
# If you have a keystore:
keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
```

Or generate a new one:
```powershell
keytool -genkey -v -keystore debug.keystore -storepass android -alias android -keypass android -keyalg RSA -keysize 2048
```

Copy the **SHA1** value from output.

### 2.3 Download google-services.json
1. In Firebase Console, download the `google-services.json` file
2. Place it in: `safety_safar_app/android/app/`
3. **Do NOT commit this file!** (Already in .gitignore)

## Step 3: Set Up iOS App in Firebase

### 3.1 Register iOS App
1. In Firebase Console, click **"+ Add app"** → **iOS**
2. Fill in details:
   - **iOS bundle ID**: `com.satya.safarapp`
   - **App nickname**: SafetySafar (optional)
3. Click **"Register app"**

### 3.2 Download GoogleService-Info.plist
1. In Firebase Console, download `GoogleService-Info.plist`
2. Place it in: `safety_safar_app/ios/Runner/`
3. In Xcode, add it to the target's **"Copy Bundle Resources"**
4. **Do NOT commit this file!** (Already in .gitignore)

## Step 4: Enable Authentication Methods

1. In Firebase Console → **Authentication** (left sidebar)
2. Click **"Sign-in method"** tab
3. Enable these providers:
   - **Email/Password**: Click enable
   - **Google**: 
     - Click enable
     - Add OAuth consent screen email
     - Add authorized domains

## Step 5: Set Up Firestore Database (Optional)

1. Firebase Console → **Firestore Database**
2. Click **"Create database"**
3. Choose region close to your users
4. Start in **Test mode** (for development)
5. Later, set up security rules:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

## Step 6: Configure Backend (Python)

If your backend needs Firebase admin access, set up a service account:

1. Firebase Console → **Project Settings** (gear icon)
2. **Service Accounts** tab
3. Click **"Generate new private key"**
4. Save as `serviceAccountKey.json` in `safety_safar_backend/`
5. Add to `.gitignore` in backend
6. Set environment variable in `.env`:

```
FIREBASE_CREDENTIALS_PATH=path/to/serviceAccountKey.json
```

## Step 7: Connect Flutter App to Firebase

The connection is automatic once:
1. `google-services.json` is in `safety_safar_app/android/app/`
2. `GoogleService-Info.plist` is in `safety_safar_app/ios/Runner/`
3. Run: `flutter pub get`

## Troubleshooting

### "google-services.json not found"
- Verify file is in `safety_safar_app/android/app/`
- Run: `flutter clean && flutter pub get`

### Firebase Authentication not working
- Enable **Email/Password** in Firebase Console
- Check internet connection
- Verify package name matches Firebase registration

### SHA-1 Certificate Mismatch
- Get correct SHA-1 from:
  ```powershell
  keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android
  ```
- Update in Firebase Console

### iOS Build Fails
```bash
cd safety_safar_app/ios
pod repo update
pod install
cd ..
flutter run
```

## Security Considerations

⚠️ **IMPORTANT:**
- Never commit `google-services.json` or `GoogleService-Info.plist`
- Never share these files in issues/PRs
- These files contain API keys and project credentials
- Each developer should have their own Firebase project or shared dev project with restricted access
- Use separate Firebase projects for development and production

## Environment Variables

For backend Firebase integration, ensure `.env` contains:
```
FIREBASE_CREDENTIALS_PATH=./serviceAccountKey.json
FIREBASE_PROJECT_ID=your-project-id
```

## Resources

- Firebase Documentation: https://firebase.google.com/docs
- Flutter Firebase: https://firebase.flutter.dev
- Firebase CLI: https://firebase.google.com/docs/cli
