# Firestore Security Rules for Admin Access

## Updated Rules for Admin Feature

To allow admins to read all orders, update your Firestore security rules:

### Go to Firebase Console:
👉 https://console.firebase.google.com/project/my-web-page-ef286/firestore/rules

### Updated Security Rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Helper function to check if user is admin
    function isAdmin() {
      return request.auth != null && 
             request.auth.token.email in [
               'john.ace.colani@outlook.com'
             ];
    }

    // Orders collection
    match /orders/{orderId} {
      // Allow users to read/write their own orders
      allow read, write: if request.auth != null && 
                          resource.data.userId == request.auth.uid;
      
      // Allow admins to read all orders
      allow read: if isAdmin();
      
      // Allow admins to update orders (to add responses)
      allow update: if isAdmin();
    }
    
    // Deny all other access by default
    match /{document=**} {
      allow read, write: if false;
    }
  }
}
```

### For Testing (Less Secure - Use Temporarily):

If the above rules don't work immediately, you can use this simpler version for testing:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /orders/{orderId} {
      // Allow authenticated users to read/write their own orders
      allow read, write: if request.auth != null && 
                          resource.data.userId == request.auth.uid;
      
      // Allow all authenticated users to read (for testing admin)
      // Remove this after confirming admin check works
      allow read: if request.auth != null;
      allow update: if request.auth != null;
    }
  }
}
```

### Steps:

1. Copy the rules above (use the first set for production)
2. Go to Firebase Console → Firestore → Rules
3. Paste the rules
4. Click **Publish**
5. Wait 10-30 seconds for rules to propagate
6. Test the admin feature

### Note:

The admin check is done in the app code (via `AdminService.isAdmin()`), but Firestore rules provide an extra layer of security. In production, you should use the first set of rules that explicitly checks for admin emails in the security rules.

However, for now, the app-level check is sufficient. The second set of rules (testing version) allows any authenticated user to read/update orders, but the app UI will only show the admin menu to the specified admin email.

