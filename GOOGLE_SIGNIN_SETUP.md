# Google Sign-In Setup Instructions

## For Web App:

### Step 1: Add Google Client ID to web/index.html

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Select your project
3. Go to **Authentication** > **Sign-in method**
4. Click on **Google** provider
5. Under **Web SDK configuration**, copy the **Web client ID** (it looks like: `123456789-abcdefghijklmnopqrstuvwxyz.apps.googleusercontent.com`)

6. Open `web/index.html` file
7. Find the line:
   ```html
   <meta name="google-signin-client_id" content="YOUR_CLIENT_ID.apps.googleusercontent.com">
   ```
8. Replace `YOUR_CLIENT_ID.apps.googleusercontent.com` with your actual Web client ID from step 5

✅ **You've already completed this step!**

### Step 2: Enable People API (REQUIRED)

**IMPORTANT:** Google Sign-In on web requires the **People API** to be enabled.

1. **Enable People API:**
   - Visit: https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=68544054220
   - Or manually:
     - Go to https://console.cloud.google.com/
     - Select your project
     - Navigate to **APIs & Services** > **Library**
     - Search for "People API"
     - Click on "Google People API"
     - Click **Enable**

2. Wait 1-2 minutes for the API to propagate

3. Test Google Sign-In - it should work now!

📝 **See `ENABLE_PEOPLE_API.md` for detailed instructions**

### Step 3: Rebuild Your Web App

After completing the above steps:
```bash
flutter build web
```

## For Mobile Apps (Android/iOS):

The Google Sign-In is automatically configured through:
- Android: `google-services.json` file (already configured)
- iOS: `GoogleService-Info.plist` file (already configured)

No additional setup needed for mobile apps if Firebase is properly configured.

---

## Apple Sign-In Note:

Apple Sign-In is only available on:
- ✅ iOS devices
- ✅ macOS devices
- ❌ Web browsers (not supported)

The Apple Sign-In button will automatically be hidden on web and only shown on mobile devices.

