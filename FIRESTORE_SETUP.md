# Fix Firestore Connection Error

## Error Message
```
[cloud_firestore/unknown] Unable to establish connection on channel
```

## Problem
Firestore security rules are likely blocking writes to the `orders` collection. By default, Firestore denies all reads/writes unless security rules are configured.

## Solution: Configure Firestore Security Rules

### Step 1: Go to Firebase Console
1. Visit: https://console.firebase.google.com/project/my-web-page-ef286/firestore/rules
2. Or manually:
   - Go to https://console.firebase.google.com/
   - Select project: **my-web-page-ef286**
   - Go to **Firestore Database** > **Rules** tab

### Step 2: Update Security Rules
Replace the default rules with these rules that allow authenticated users to read/write their own orders:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Orders collection: Users can only read/write their own orders
    match /orders/{orderId} {
      // Allow read if the user is authenticated and the order belongs to them
      allow read: if request.auth != null && request.resource.data.userId == request.auth.uid;
      
      // Allow create if the user is authenticated and the userId matches
      allow create: if request.auth != null && request.resource.data.userId == request.auth.uid;
      
      // Allow update if the user is authenticated and owns the order
      allow update: if request.auth != null && resource.data.userId == request.auth.uid;
      
      // Allow delete if the user is authenticated and owns the order
      allow delete: if request.auth != null && resource.data.userId == request.auth.uid;
    }
    
    // Deny all other access by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

**IMPORTANT**: For development/testing, you can temporarily use more permissive rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Temporary: Allow all authenticated users to read/write orders
    // WARNING: This is less secure - only use for testing!
    match /orders/{orderId} {
      allow read, write: if request.auth != null;
    }
    
    // Deny all other access
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### Step 3: Publish Rules
1. Click **Publish** button at the top
2. Wait a few seconds for rules to propagate

### Step 4: Test
Try submitting an order again. The error should be resolved.

---

## Alternative: Check if Firestore Database is Created

If you haven't created the Firestore database yet:

1. Go to: https://console.firebase.google.com/project/my-web-page-ef286/firestore
2. Click **Create database**
3. Choose **Start in test mode** (or **Start in production mode** if you want to set up rules immediately)
4. Select a location (choose the closest to your users)
5. Click **Enable**

**Note**: If you start in test mode, you'll need to update the security rules as shown above after 30 days (test mode expires).

---

## Verify Setup

After updating the rules:
1. The error should disappear
2. Orders should save successfully
3. Users should be able to view their orders in the Profile screen

## Security Best Practices

For production, use the first set of rules (with `userId` checks) to ensure users can only access their own orders.

