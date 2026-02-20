# Apple Sign-In Setup Guide

## Prerequisites
- Apple Developer Account (paid membership required: $99/year)
- Xcode installed on your Mac
- Access to Apple Developer Portal

## Step-by-Step Setup

### Step 1: Configure App ID in Apple Developer Portal

1. **Go to Apple Developer Portal**
   - Visit: https://developer.apple.com/account
   - Sign in with your Apple Developer account

2. **Navigate to Certificates, Identifiers & Profiles**
   - Click on "Certificates, Identifiers & Profiles" from the left sidebar

3. **Create/Edit App ID**
   - Click on "Identifiers" in the left sidebar
   - Click the "+" button to create a new identifier OR find your existing App ID
   - Select "App IDs" and click "Continue"
   - Select "App" and click "Continue"
   - Register your App ID:
     - **Description**: 4iDeas (or any description)
     - **Bundle ID**: `com.JohnColani.4iDeas` (must match your app's bundle ID)
   - Under "Capabilities", check the box for **"Sign In with Apple"**
   - Click "Continue" and then "Register"

### Step 2: Create Service ID (Required for Web/Android)

Since you're using Flutter which supports multiple platforms, you need a Service ID:

1. **Create Service ID**
   - In "Identifiers", click the "+" button
   - Select "Services IDs" and click "Continue"
   - Register your Service ID:
     - **Description**: 4iDeas Web Service
     - **Identifier**: `com.JohnColani.4iDeas.service` (or similar, must be unique)
   - Click "Continue" and then "Register"

2. **Configure Service ID**
   - Click on the Service ID you just created
   - Check "Sign In with Apple"
   - Click "Configure"
   - **Primary App ID**: Select your App ID (`com.JohnColani.4iDeas`)
   - **Website URLs**:
     - **Domains and Subdomains**: `my-web-page-ef286.web.app` (your Firebase hosting domain)
     - **Return URLs**: `https://my-web-page-ef286.web.app` (add your web URL)
   - Click "Save"
   - Click "Continue" and then "Save"

### Step 3: Create Key for Sign In with Apple (Optional but Recommended)

1. **Create a Key**
   - In "Certificates, Identifiers & Profiles", go to "Keys"
   - Click the "+" button
   - **Key Name**: 4iDeas Sign In Key (or any name)
   - Check "Sign In with Apple"
   - Click "Configure" next to "Sign In with Apple"
   - Select your Primary App ID (`com.JohnColani.4iDeas`)
   - Click "Save"
   - Click "Continue" and then "Register"
   - **IMPORTANT**: Download the key file (`.p8` file) - you can only download it once!
   - Note the Key ID (you'll need this)

### Step 4: Enable Capabilities in Xcode

1. **Open your project in Xcode**
   ```bash
   open ios/Runner.xcworkspace
   ```
   (Use `.xcworkspace`, not `.xcodeproj`)

2. **Select the Runner target**
   - In the Project Navigator, click on "Runner" (blue icon at the top)
   - Select the "Runner" target (under TARGETS)
   - Go to the "Signing & Capabilities" tab

3. **Add Sign In with Apple capability**
   - Click the "+ Capability" button
   - Search for "Sign In with Apple"
   - Double-click to add it
   - Make sure your Team is selected (Apple Developer account team)

4. **Verify Bundle Identifier**
   - Under "Signing & Capabilities", verify:
     - **Bundle Identifier**: `com.JohnColani.4iDeas`
     - **Team**: Your Apple Developer Team
     - **Sign In with Apple**: Enabled

5. **Save and close Xcode**

### Step 5: Configure iOS Info.plist (if needed)

The `sign_in_with_apple` package should handle this automatically, but verify:

1. **Check Info.plist**
   - Open `ios/Runner/Info.plist`
   - Make sure it exists and has proper configuration
   - The package should add required entries automatically

### Step 6: Update Firebase Console (if using Firebase Auth)

1. **Enable Apple Provider in Firebase**
   - Go to Firebase Console: https://console.firebase.google.com
   - Select your project: `my-web-page-ef286`
   - Go to "Authentication" → "Sign-in method"
   - Click on "Apple" provider
   - Click "Enable"

2. **Fill in the OAuth Code Flow Configuration:**
   
   **⚠️ IMPORTANT: Get your Apple Team ID first**
   - Go to https://developer.apple.com/account → Membership
   - Your Team ID is a 10-character code (like `ABC123DEF4`)
   - **DO NOT use your email address** - use the Team ID!
   
   **Fill in Firebase fields:**
   - **Apple Team ID**: Enter your Team ID (10-character code from Membership page)
   - **Key ID**: Enter the Key ID from the key you created in Step 3
   - **Private key**: 
     - Open the downloaded `.p8` file in a text editor
     - Copy the ENTIRE content including:
       ```
       -----BEGIN PRIVATE KEY-----
       [key content]
       -----END PRIVATE KEY-----
       ```
     - Paste it into the Private key field
   
   - **Service ID (not required for Apple)**: Leave empty or enter Service ID if you created one
   
   - **Authorization callback URL**: 
     - Copy this URL: `https://my-web-page-ef286.firebaseapp.com/__/auth/handler`
     - You'll need this for Service ID configuration (Step 7)

3. **Click "Save"**

4. **Note the Callback URL**
   - Firebase will show you the authorization callback URL
   - Copy this URL - you'll need it for Service ID configuration

### Step 7: Test the Implementation

1. **Test on iOS Device/Simulator**
   ```bash
   flutter run -d ios
   ```
   - Sign In with Apple should appear in your login screen
   - Test the sign-in flow

2. **Test on Android** (if applicable)
   - Apple Sign-In also works on Android
   - Test on an Android device/emulator

3. **Test on Web** (if applicable)
   - Apple Sign-In on web requires the Service ID configuration
   - Test on your deployed web app

### Step 8: Verify Code Implementation

Your code should already have Apple Sign-In implemented. Verify these files:

1. **pubspec.yaml** - Should have:
   ```yaml
   dependencies:
     sign_in_with_apple: ^6.1.3
   ```

2. **lib/features/auth/data/datasources/auth_remote_datasource.dart**
   - Should have `signInWithApple()` method

3. **lib/features/auth/presentation/screens/login_screen.dart**
   - Should have Apple Sign-In button

## Troubleshooting

### Common Issues:

1. **"Sign in with Apple is not enabled"**
   - Verify you've enabled it in Apple Developer Portal for your App ID
   - Check Xcode capabilities are enabled
   - Make sure you're using the correct Bundle ID

2. **"Invalid client" (Web)**
   - Verify Service ID is configured correctly
   - Check Return URLs match your domain
   - Ensure Firebase has correct Service ID configuration

3. **"No valid 'aps-environment' entitlement"**
   - This is normal for Sign In with Apple - you don't need push notifications
   - Can be ignored unless you're using push notifications

4. **Apple button not showing on web**
   - Check Service ID configuration
   - Verify Firebase Authentication settings
   - Check browser console for errors

## Important Notes

- **Apple Developer Account**: Requires paid membership ($99/year)
- **Testing**: You can test Sign In with Apple on simulator/emulator, but real device testing is recommended
- **Production**: Ensure all configurations are complete before production deployment
- **Web Support**: Apple Sign-In on web requires Service ID configuration (Step 2)
- **Key File**: If you created a key (Step 3), keep the `.p8` file secure - you can only download it once!

## Verification Checklist

- [ ] App ID created/updated with "Sign In with Apple" capability
- [ ] Service ID created and configured (for web/Android)
- [ ] Key created and downloaded (optional but recommended)
- [ ] Xcode project has "Sign In with Apple" capability enabled
- [ ] Bundle ID matches: `com.JohnColani.4iDeas`
- [ ] Firebase Console has Apple provider enabled (if using Firebase Auth)
- [ ] Code implementation is in place
- [ ] Tested on iOS device/simulator
- [ ] Tested on Android (if applicable)
- [ ] Tested on Web (if applicable)

## Additional Resources

- Apple Documentation: https://developer.apple.com/sign-in-with-apple/
- Flutter Package: https://pub.dev/packages/sign_in_with_apple
- Firebase Apple Auth: https://firebase.google.com/docs/auth/ios/apple

