# Customize Google Sign-In UI to Show "4iDeas"

## Problem
Currently, Google Sign-In shows "project-68544054220" instead of "4iDeas"

## Solution: Configure OAuth Consent Screen

### Step 1: Enable People API (Required First)
1. Visit: https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=68544054220
2. Click **Enable**
3. Wait 1-2 minutes

### Step 2: Configure OAuth Consent Screen
1. Go to: https://console.cloud.google.com/apis/credentials/consent?project=68544054220
2. Or manually:
   - Go to https://console.cloud.google.com/
   - Select project: **68544054220**
   - Go to **APIs & Services** > **OAuth consent screen**

3. Configure the following:
   - **User Type**: Choose "External" (unless you have a Google Workspace)
   - Click **Create**

4. **App Information**:
   - **App name**: `4iDeas`
   - **User support email**: Your email address
   - **App logo** (optional): Upload your logo if desired
   - **App domain** (optional): Your domain if you have one
   - **Developer contact information**: Your email address
   - Click **Save and Continue**

5. **Scopes**:
   - Click **Add or Remove Scopes**
   - Make sure these scopes are included:
     - `.../auth/userinfo.email`
     - `.../auth/userinfo.profile`
     - `openid`
   - Click **Update**, then **Save and Continue**

6. **Test users** (if in Testing mode):
   - Add test users if needed
   - Click **Save and Continue**

7. **Summary**:
   - Review your settings
   - Click **Back to Dashboard**

### Step 3: Wait and Test
- Wait 1-2 minutes for changes to propagate
- The Google Sign-In screen should now show "4iDeas" instead of "project-68544054220"

---

## Important Notes:

1. **People API must be enabled first** - Otherwise Google Sign-In won't work at all
2. **OAuth Consent Screen** - This controls what users see during sign-in
3. **Publishing** - If you want to use it publicly (not just test users), you may need to submit for verification (usually not required for basic email/profile scopes)

## Quick Links:
- **Enable People API**: https://console.developers.google.com/apis/api/people.googleapis.com/overview?project=68544054220
- **OAuth Consent Screen**: https://console.cloud.google.com/apis/credentials/consent?project=68544054220

