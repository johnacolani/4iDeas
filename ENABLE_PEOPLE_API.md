# Enable Google People API for Google Sign-In

## Issue
Google Sign-In on web requires the **People API** to be enabled in your Google Cloud Console project.

## Error Message
```
People API has not been used in project 68544054220 before or it is disabled.
```

## Solution

1. **Go to Google Cloud Console:**
   - Visit: https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=68544054220
   - Or manually:
     - Go to https://console.cloud.google.com/
     - Select your project (ID: 68544054220)
     - Navigate to **APIs & Services** > **Library**
     - Search for "People API"
     - Click on "Google People API"
     - Click **Enable**

2. **Wait a few minutes** for the API to propagate (usually 1-2 minutes)

3. **Test Google Sign-In again** - it should work now!

## Alternative: Direct Link
Click this link to enable it directly:
👉 https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=68544054220

## Why is this needed?
The `google_sign_in` package on web uses the Google People API to fetch user profile information (name, email, profile photo) after authentication. This is a standard requirement for Google OAuth on web platforms.

## Note
This only needs to be done once per Google Cloud project. After enabling, all Google Sign-In attempts in your web app will work correctly.

