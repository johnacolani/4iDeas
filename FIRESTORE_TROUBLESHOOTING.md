# Firestore Connection Error - Detailed Troubleshooting

## Error Message
```
[cloud_firestore/unknown] Unable to establish connection on channel
```

## Common Causes & Solutions

### 1. **Firestore Database Not Created** (MOST COMMON)

**Check if database exists:**
1. Go to: https://console.firebase.google.com/project/my-web-page-ef286/firestore
2. If you see "Create database" button → **Database doesn't exist yet!**

**Solution:**
1. Click **"Create database"**
2. Choose **"Start in test mode"** (for now, we'll update rules later)
3. Select a **location** (choose the closest to your users, e.g., `us-central1`)
4. Click **"Enable"**
5. Wait 1-2 minutes for the database to initialize
6. Then go back and update the security rules (see step 2)

---

### 2. **Security Rules Not Published**

**Verify rules are published:**
1. Go to: https://console.firebase.google.com/project/my-web-page-ef286/firestore/rules
2. Check if you see a **green checkmark** or **"Published"** status
3. If you see **"Not published"** → Click **"Publish"** button

**Rules to use (temporary for testing):**
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
  }
}
```

---

### 3. **Wrong Database Location**

**Check database location:**
1. Go to: https://console.firebase.google.com/project/my-web-page-ef286/firestore/settings
2. Check the **"Default Cloud Firestore location"**
3. If it says "Not set" or "us-central" → This should be fine

**If location is an issue:**
- You might need to create a new database in a different location
- But this is rarely the cause of connection errors

---

### 4. **Browser Cache / Old Build**

**Clear browser cache and rebuild:**
1. **Hard refresh the browser:**
   - Chrome/Edge: `Ctrl+Shift+R` (Windows) or `Cmd+Shift+R` (Mac)
   - Safari: `Cmd+Option+R`
2. **Or clear browser cache completely:**
   - Chrome: Settings → Privacy → Clear browsing data → Cached images and files
3. **Rebuild and redeploy:**
   ```bash
   flutter clean
   flutter pub get
   flutter build web
   firebase deploy --only hosting
   ```

---

### 5. **Network / CORS Issues**

**Check browser console:**
1. Open browser DevTools (F12)
2. Go to **Console** tab
3. Look for CORS errors or network errors
4. Go to **Network** tab
5. Look for failed requests to `firestore.googleapis.com`

**If you see CORS errors:**
- This shouldn't happen with Firebase, but check if you're using a custom domain
- Make sure the domain is added to Firebase authorized domains

---

### 6. **Verify Firebase Initialization**

**Check if Firebase is initialized:**
1. Open browser console (F12)
2. Run this command:
   ```javascript
   firebase.apps
   ```
3. Should see an array with your Firebase app
4. If empty or error → Firebase not initialized properly

---

## Step-by-Step Checklist

Follow these in order:

- [ ] **Step 1:** Check if Firestore database exists
  - Go to: https://console.firebase.google.com/project/my-web-page-ef286/firestore
  - If "Create database" button exists → Create it first!
  
- [ ] **Step 2:** Verify security rules are published
  - Go to: https://console.firebase.google.com/project/my-web-page-ef286/firestore/rules
  - Rules should allow authenticated users: `allow read, write: if request.auth != null;`
  - Click "Publish" if not published
  
- [ ] **Step 3:** Wait 2-3 minutes after creating/publishing
  - Firebase changes can take a moment to propagate
  
- [ ] **Step 4:** Clear browser cache and hard refresh
  - `Cmd+Shift+R` (Mac) or `Ctrl+Shift+R` (Windows)
  
- [ ] **Step 5:** Check browser console for errors
  - Open DevTools (F12) → Console tab
  - Look for specific error messages
  
- [ ] **Step 6:** Verify you're logged in
  - Make sure you're authenticated in the app before submitting order
  
- [ ] **Step 7:** Test in incognito/private window
  - Sometimes browser extensions cause issues
  
- [ ] **Step 8:** Check Firebase Console → Firestore → Data
  - See if any test documents exist
  - Try creating a document manually to verify database works

---

## Quick Test

After following the checklist, try this:

1. **Open your app in browser**
2. **Make sure you're logged in** (check profile screen shows your email)
3. **Try submitting an order**
4. **Check Firebase Console → Firestore → Data tab**
5. **Look for a new document in the `orders` collection**

If the document appears → **Success!** The error was just a timing/initialization issue.

---

## Still Not Working?

If you've tried everything above and it still doesn't work:

1. **Check the exact error message in browser console:**
   - Open DevTools (F12)
   - Go to Console tab
   - Look for the full error message
   - Share the complete error (it might give more clues)

2. **Verify Firebase project settings:**
   - Go to: https://console.firebase.google.com/project/my-web-page-ef286/settings/general
   - Make sure the project ID is: `my-web-page-ef286`
   - Check that web app is registered

3. **Try creating a test document manually:**
   - Go to: https://console.firebase.google.com/project/my-web-page-ef286/firestore/data
   - Click "Start collection"
   - Collection ID: `test`
   - Document ID: `test1`
   - Add a field: `test: "value"`
   - Click "Save"
   - If this works, Firestore is set up correctly, and the issue is with the code/rules

---

## Contact Points

If none of the above works, please provide:
1. Screenshot of Firebase Console → Firestore (showing if database exists)
2. Screenshot of Firestore Rules page
3. Full error message from browser console (F12 → Console)
4. Screenshot of Firestore Data tab (to see if any documents exist)

