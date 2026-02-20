# How to Add Admin Roles

## Current Implementation (Simple - Hardcoded List)

The admin system currently uses a hardcoded list of admin email addresses in `lib/services/admin_service.dart`.

### To Add More Admins:

1. Open `lib/services/admin_service.dart`
2. Find the `_adminEmails` list
3. Add the new admin email address:

```dart
static const List<String> _adminEmails = [
  'john.ace.colani@outlook.com',
  'newadmin@example.com',  // Add new admin here
  'another.admin@example.com',  // Add more as needed
];
```

4. Save the file
5. Rebuild the app

**Pros:**
- Simple and fast
- No database setup required
- Works immediately

**Cons:**
- Requires code changes to add/remove admins
- Need to rebuild/redeploy app
- All admins see the same code

---

## Advanced Implementation (Recommended - Firestore Based)

For a production app, it's better to store admin roles in Firestore so you can add/remove admins without code changes.

### Option 1: Store Admin Emails in Firestore

#### Step 1: Create Admin Collection in Firestore

1. Go to Firebase Console → Firestore Database
2. Click **Start collection**
3. Collection ID: `admins`
4. Document ID: `list` (or use auto-ID)
5. Add field:
   - Field: `emails`
   - Type: `array`
   - Value: `["john.ace.colani@outlook.com"]`

#### Step 2: Update AdminService to Read from Firestore

Update `lib/services/admin_service.dart`:

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Cache for admin emails (to avoid reading Firestore on every check)
  static List<String>? _cachedAdminEmails;
  static DateTime? _cacheTimestamp;
  static const Duration _cacheDuration = Duration(minutes: 5);

  /// Check if the current user is an admin
  static Future<bool> isAdmin() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return false;
    }
    final adminEmails = await _getAdminEmails();
    return adminEmails.contains(user.email!.toLowerCase().trim());
  }

  /// Synchronous version (uses cache, may be outdated)
  static bool isAdminSync() {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return false;
    }
    if (_cachedAdminEmails == null) {
      // Fallback to hardcoded list if cache is empty
      return _hardcodedAdminEmails.contains(user.email!.toLowerCase().trim());
    }
    return _cachedAdminEmails!.contains(user.email!.toLowerCase().trim());
  }

  /// Get admin emails from Firestore (with caching)
  static Future<List<String>> _getAdminEmails() async {
    // Return cached list if still valid
    if (_cachedAdminEmails != null && 
        _cacheTimestamp != null && 
        DateTime.now().difference(_cacheTimestamp!) < _cacheDuration) {
      return _cachedAdminEmails!;
    }

    try {
      final doc = await _firestore.collection('admins').doc('list').get();
      if (doc.exists && doc.data() != null) {
        final emails = (doc.data()!['emails'] as List<dynamic>?)
            ?.map((e) => e.toString().toLowerCase().trim())
            .toList() ?? [];
        
        _cachedAdminEmails = emails;
        _cacheTimestamp = DateTime.now();
        return emails;
      }
    } catch (e) {
      debugPrint('Error fetching admin emails: $e');
    }

    // Fallback to hardcoded list
    return _hardcodedAdminEmails;
  }

  // Fallback hardcoded list (backup if Firestore fails)
  static const List<String> _hardcodedAdminEmails = [
    'john.ace.colani@outlook.com',
  ];

  /// Check if a specific email is an admin
  static Future<bool> isAdminEmail(String email) async {
    final adminEmails = await _getAdminEmails();
    return adminEmails.contains(email.toLowerCase().trim());
  }

  /// Get the current user's email if they are an admin
  static Future<String?> getAdminEmail() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null || user.email == null) {
      return null;
    }
    if (await isAdmin()) {
      return user.email;
    }
    return null;
  }
}
```

#### Step 3: Update Menu to Use Async Admin Check

Since `isAdmin()` is now async, you'll need to update `sliding_menu.dart`:

```dart
// In the menu builder, use FutureBuilder or StreamBuilder
FutureBuilder<bool>(
  future: AdminService.isAdmin(),
  builder: (context, snapshot) {
    if (snapshot.data == true) {
      return MenuItem(
        icon: Icons.admin_panel_settings,
        title: 'Admin - Orders',
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AdminOrdersScreen(),
            ),
          );
        },
      );
    }
    return const SizedBox.shrink();
  },
),
```

---

### Option 2: Store Admin Status in User Document (Even Better)

#### Step 1: Create Users Collection Structure

1. In Firestore, create a collection: `users`
2. Document ID: Use the user's UID
3. Add field:
   - Field: `isAdmin`
   - Type: `boolean`
   - Value: `true` (for admins) or `false` (for regular users)

Or add a `role` field:
- Field: `role`
- Type: `string`
- Value: `"admin"` or `"user"`

#### Step 2: Update AdminService

```dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AdminService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Check if the current user is an admin
  static Future<bool> isAdmin() async {
    final user = _auth.currentUser;
    if (user == null) {
      return false;
    }

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data();
        // Check for isAdmin field
        if (data?['isAdmin'] == true) {
          return true;
        }
        // Or check for role field
        if (data?['role'] == 'admin') {
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error checking admin status: $e');
    }

    return false;
  }
}
```

---

## Recommended Approach for Your App

For now, **start with the simple hardcoded list** since you only have one admin. When you need to add more admins or want to manage them through Firebase Console, switch to **Option 1 (Admin Emails in Firestore)**.

### Quick Start (Current Implementation):

1. Open `lib/services/admin_service.dart`
2. Add email addresses to the `_adminEmails` list
3. Rebuild the app

That's it! The admin menu will appear for those email addresses.

---

## Security Rules for Admin Collection

If you use Firestore to store admins, update security rules:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Admins collection - only readable by authenticated users
    match /admins/{document} {
      allow read: if request.auth != null;
      allow write: if false; // Only admins can write (do this manually in console for now)
    }
    
    // ... rest of your rules
  }
}
```

