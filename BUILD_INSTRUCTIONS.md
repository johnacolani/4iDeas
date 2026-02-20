# Build Instructions for iOS and Android

## Prerequisites

1. **Flutter SDK** - Installed and in PATH
2. **Android Studio** - For Android builds
3. **Xcode** - For iOS builds (macOS only)
4. **Firebase** - Already configured via `flutterfire configure`

## Android Build

### Requirements
- Android SDK installed via Android Studio
- Android device or emulator

### Build Commands

```bash
# Get dependencies
flutter pub get

# Build APK (debug)
flutter build apk

# Build App Bundle (for Play Store)
flutter build appbundle

# Run on connected device/emulator
flutter run -d android
```

### Android Configuration Status ✅
- ✅ Firebase configured (`google-services.json` present)
- ✅ Google Services plugin configured
- ✅ Build files configured correctly

## iOS Build

### Requirements
- Xcode installed (macOS only)
- Apple Developer account (for physical devices)
- CocoaPods installed

### Setup Steps

1. **Install CocoaPods dependencies:**
   ```bash
   cd ios
   pod install
   cd ..
   ```

2. **Configure Code Signing in Xcode:**
   ```bash
   open ios/Runner.xcworkspace
   ```
   
   Then in Xcode:
   - Select **Runner** project → **Runner** target
   - Go to **Signing & Capabilities** tab
   - Check **"Automatically manage signing"**
   - Select your **Team** (Apple ID)
   - Xcode will create provisioning profile automatically

3. **Build Commands:**
   ```bash
   # Get dependencies
   flutter pub get
   
   # Install CocoaPods
   cd ios && pod install && cd ..
   
   # Build iOS app (for simulator)
   flutter build ios --simulator
   
   # Build iOS app (for device - requires signing)
   flutter build ios
   
   # Run on simulator (no signing needed)
   flutter run -d "iPhone Simulator"
   
   # Run on connected device (requires signing)
   flutter run -d ios
   ```

### iOS Configuration Status
- ✅ Firebase configured (`GoogleService-Info.plist` present)
- ✅ Podfile configured
- ⚠️ Code signing needs to be configured in Xcode (see above)

## Common Issues & Fixes

### Android Issues

#### Build fails with Gradle error
```bash
cd android
./gradlew clean
cd ..
flutter clean
flutter pub get
```

#### Missing SDK components
- Open Android Studio
- Go to Tools → SDK Manager
- Install required SDK components

### iOS Issues

#### CocoaPods not installed
```bash
sudo gem install cocoapods
```

#### Pod install fails
```bash
cd ios
pod deintegrate
pod install
cd ..
```

#### Code signing errors
- Open Xcode: `open ios/Runner.xcworkspace`
- Sign in to Xcode with your Apple ID
- Configure automatic signing (see Setup Steps above)

#### "No Accounts" error
1. Xcode → Settings → Accounts
2. Click + → Apple ID
3. Sign in with your Apple ID

## Quick Test Commands

### Test on Web (No setup needed)
```bash
flutter run -d chrome
```

### Test on Android Emulator
```bash
# Start Android emulator from Android Studio, then:
flutter run -d android
```

### Test on iOS Simulator (No signing needed)
```bash
flutter run -d "iPhone Simulator"
```

## Release Builds

### Android Release APK
```bash
flutter build apk --release
# Output: build/app/outputs/flutter-apk/app-release.apk
```

### Android App Bundle (for Play Store)
```bash
flutter build appbundle --release
# Output: build/app/outputs/bundle/release/app-release.aab
```

### iOS Release (requires signing)
```bash
# First configure signing in Xcode, then:
flutter build ios --release
# Then archive in Xcode for App Store submission
```






