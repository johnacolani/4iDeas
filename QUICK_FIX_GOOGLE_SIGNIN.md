# Quick Fix: Enable Google People API

## The Error
```
Google sign in failed: People API has not been used in project 68544054220 before or it is disabled
```

## Solution (2 Steps):

### Step 1: Enable People API
**Click this link to enable it directly:**
👉 **https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=68544054220**

**OR manually:**
1. Go to https://console.cloud.google.com/
2. Make sure project `68544054220` is selected (top dropdown)
3. Go to **APIs & Services** > **Library** (or click the link above)
4. Search for "People API"
5. Click on "Google People API"
6. Click the **Enable** button

### Step 2: Wait 1-2 minutes
The API needs a moment to propagate through Google's systems.

### Step 3: Test again
Try Google Sign-In again - it should work now!

---

## Why is this needed?
The `google_sign_in` package on web uses the Google People API to fetch user profile information (name, email, profile photo) after authentication. This is a standard requirement for Google OAuth on web platforms.

## Note
This only needs to be done **once** per Google Cloud project. After enabling, all Google Sign-In attempts will work.

