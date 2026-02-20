# Firebase Setup Instructions

## Step 1: Create Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project" or "Create a project"
3. Enter project name: **My-Web-Page**
4. Follow the setup wizard (disable Google Analytics if you don't need it)
5. Click "Create project"

## Step 2: Add Web App to Firebase

1. In Firebase Console, click the Web icon (`</>`) to add a web app
2. Register app nickname: **My-Web-Page-Web**
3. Check "Also set up Firebase Hosting" if you want to host later
4. Click "Register app"
5. Copy the Firebase configuration object

## Step 3: Add Firebase Configuration to Your Flutter App

### For Web:

1. Open `web/index.html`
2. Add the Firebase SDK scripts before the closing `</body>` tag:

```html
<!-- Firebase SDK -->
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js"></script>
<script src="https://www.gstatic.com/firebasejs/10.7.1/firebase-auth-compat.js"></script>
<script>
  // Your web app's Firebase configuration
  const firebaseConfig = {
    apiKey: "YOUR_API_KEY",
    authDomain: "YOUR_AUTH_DOMAIN",
    projectId: "YOUR_PROJECT_ID",
    storageBucket: "YOUR_STORAGE_BUCKET",
    messagingSenderId: "YOUR_MESSAGING_SENDER_ID",
    appId: "YOUR_APP_ID"
  };
  
  // Initialize Firebase
  firebase.initializeApp(firebaseConfig);
</script>
```

### For Android:

1. Download `google-services.json` from Firebase Console
2. Place it in `android/app/` directory
3. Update `android/build.gradle`:
   - Add to `dependencies`:
     ```gradle
     classpath 'com.google.gms:google-services:4.4.0'
     ```
4. Update `android/app/build.gradle`:
   - Add at the bottom:
     ```gradle
     apply plugin: 'com.google.gms.google-services'
     ```

### For iOS:

1. Download `GoogleService-Info.plist` from Firebase Console
2. Place it in `ios/Runner/` directory
3. In Xcode, add the file to the Runner target

## Step 4: Enable Authentication

1. In Firebase Console, go to **Authentication**
2. Click "Get started"
3. Enable **Email/Password** authentication:
   - Click on "Email/Password"
   - Enable "Email/Password" (first toggle)
   - Click "Save"

## Step 5: Install Dependencies

Run the following command in your project root:

```bash
flutter pub get
```

## Step 6: Update main.dart (if needed)

If you're using platform-specific Firebase initialization, you may need to create a `firebase_options.dart` file using:

```bash
flutterfire configure
```

This will automatically generate the Firebase configuration for all platforms.

## Verification

1. Run your app: `flutter run -d chrome` (for web)
2. Try to sign up with a test email
3. Check Firebase Console > Authentication to see if the user was created

## Security Rules (Optional)

For production, configure Firebase Security Rules in the Firebase Console under **Firestore Database** or **Realtime Database** if you plan to use them later.

## Notes

- The app is configured to work with Firebase Authentication
- All authentication flows (login, signup, forgot password) are implemented
- Users must be authenticated to place orders
- The authentication state is managed using BLoC pattern with Clean Architecture

