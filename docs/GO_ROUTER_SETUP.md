# How to Add go_router to Your Flutter Project

A step-by-step guide for junior developers. Use this so all screen navigation goes through one place: **URLs, deep links, and back button work correctly**, and your app stays consistent.

---

## 1. Add the dependency

In `pubspec.yaml`:

```yaml
dependencies:
  flutter:
    sdk: flutter
  go_router: ^14.0.0   # or latest stable
```

Then run:

```bash
flutter pub get
```

---

## 2. Define your routes in one place

Create a file (e.g. `lib/app_router.dart`) that holds **all path strings** and builds the router.

### 2.1 Route path constants

Put every path in a single class so you never type `'/login'` by hand in the app. Use this class whenever you navigate.

```dart
/// Use these when calling context.go() or context.push().
abstract class AppRoutes {
  static const String home = '/';
  static const String login = '/login';
  static const String signUp = '/signup';
  static const String profile = '/profile';
  // Add more as you add screens...
}
```

### 2.2 Paths with parameters

For detail screens (e.g. `/item/123`), use a helper so the path is always correct:

```dart
abstract class AppRoutes {
  static const String items = '/items';
  static const String itemDetail = '/items/item';
  /// Use: AppRoutes.itemDetailPath('123') → '/items/item/123'
  static String itemDetailPath(String id) => '$itemDetail/$id';
}
```

### 2.3 Build the GoRouter

In the same file, create a function that returns a `GoRouter` with all top-level routes:

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
// Import your screen widgets here.

GoRouter createAppRouter() {
  return GoRouter(
    initialLocation: AppRoutes.home,
    routes: <RouteBase>[
      GoRoute(
        path: AppRoutes.home,
        builder: (context, state) => const HomeScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: AppRoutes.signUp,
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (context, state) => const ProfileScreen(),
      ),
      // More routes...
    ],
  );
}
```

---

## 3. Use the router in your app

In `main.dart`, create the router once and pass it to `MaterialApp.router` (do **not** use `MaterialApp` with `home:`).

```dart
import 'package:four_ideas/app_router.dart';
import 'package:go_router/go_router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final router = createAppRouter();
    return MaterialApp.router(
      routerConfig: router,
      title: 'My App',
      theme: ThemeData(/* ... */),
    );
  }
}
```

After this, **all navigation should use GoRouter** (see step 5). Do not use `Navigator.push(MaterialPageRoute(...))` for full screens.

---

## 4. Routes with path parameters (e.g. `/items/:id`)

Use a **nested** `GoRoute` under a parent so the path is e.g. `/items/item/42`.

**In `app_router.dart`:**

```dart
GoRoute(
  path: '/items',
  builder: (context, state) => const ItemsListScreen(),
  routes: <RouteBase>[
    GoRoute(
      path: 'item/:id',   // full path: /items/item/:id
      builder: (context, state) {
        final id = state.pathParameters['id'] ?? '';
        // Load your data by id, then:
        return ItemDetailScreen(itemId: id);
      },
    ),
  ],
),
```

**Navigate to it:**

```dart
context.push(AppRoutes.itemDetailPath('42'));
```

---

## 5. How to navigate (use these instead of Navigator.push)

You need `BuildContext context` (e.g. inside a widget’s `build` or `onPressed`). Import `go_router`:

```dart
import 'package:go_router/go_router.dart';
```

| Goal | Code |
|------|------|
| Go to a screen (replace current stack) | `context.go(AppRoutes.login);` |
| Push a screen (back goes to previous) | `context.push(AppRoutes.profile);` |
| Push and replace current screen | `context.pushReplacement(AppRoutes.signUp);` |
| Go back | `context.pop();` |
| Go back with a result (e.g. for dialogs) | Still use `Navigator.pop(context, true);` in dialogs |

**Examples:**

```dart
// Button: go to login
onPressed: () => context.push(AppRoutes.login),

// After login success: replace stack with home
onPressed: () => context.go(AppRoutes.home),

// Back button or "Cancel"
onPressed: () => context.pop(),
```

---

## 6. Passing data to a screen (e.g. an object)

Use **path parameters** for IDs (so the URL is shareable). Use **extra** for one-off data (e.g. a model object).

### 6.1 Path parameter (recommended when you have an id)

- Route path: `item/:id`
- Navigate: `context.push(AppRoutes.itemDetailPath(id));`
- In the route `builder`: `final id = state.pathParameters['id'];` then load the item (e.g. from a repository).

### 6.2 Extra (when you don’t want it in the URL)

- Navigate: `context.push(AppRoutes.orderDetail, extra: myOrderMap);`
- In the route `builder`:

```dart
GoRoute(
  path: '/order-detail',
  builder: (context, state) {
    final order = state.extra as Map<String, dynamic>?;
    if (order == null) return Scaffold(body: Center(child: Text('Missing data')));
    return OrderDetailScreen(order: order);
  },
),
```

---

## 7. Optional: Query parameters (e.g. `?email=user@example.com`)

In the route builder, read them from `state.uri.queryParameters`:

```dart
builder: (context, state) {
  final email = state.uri.queryParameters['email'] ?? '';
  return EmailVerificationScreen(userEmail: email);
},
```

Navigate with query string: `context.push('${AppRoutes.emailVerification}?email=${Uri.encodeComponent(email)}');` or use `GoRouterState` and build the URI in a helper.

---

## 8. Checklist for adding a new screen

1. **Create the screen widget** (e.g. `lib/screens/settings_screen.dart`).
2. **Add a path constant** in `AppRoutes` (e.g. `static const String settings = '/settings';`).
3. **Register the route** in `createAppRouter()`:
   ```dart
   GoRoute(
     path: AppRoutes.settings,
     builder: (context, state) => const SettingsScreen(),
   ),
   ```
4. **Navigate** from anywhere with `context.push(AppRoutes.settings)` or `context.go(AppRoutes.settings)`.
5. **Back** from the screen with `context.pop()` (e.g. in AppBar or a button).

---

## 9. When *not* to use GoRouter

- **Dialogs** (e.g. `showDialog`): keep using `Navigator.pop(context, result)` to close and return a value.
- **Bottom sheets**: keep using `showModalBottomSheet` and `Navigator.pop`.
- **Overlays** (e.g. full-screen image viewer): can stay as `Navigator.push` if they are transient and not part of the “app URL” structure.

Use GoRouter for **every full-screen route** that should appear in the stack and support back / deep link.

---

## 10. Quick reference

| Task | Code |
|------|------|
| Add dependency | `go_router: ^14.0.0` in `pubspec.yaml`, then `flutter pub get` |
| Define paths | `abstract class AppRoutes { static const String home = '/'; ... }` |
| Build router | `GoRouter(initialLocation: '...', routes: [...])` |
| Use in app | `MaterialApp.router(routerConfig: createAppRouter(), ...)` |
| Go to screen | `context.go(AppRoutes.home)` or `context.push(...)` |
| Back | `context.pop()` |
| Path param | Route: `path: 'item/:id'`, read: `state.pathParameters['id']` |
| Pass object | `context.push(path, extra: myObject)`, read: `state.extra` |

If you follow this, all main screens will use go_router and your project will have one clear place for routes and navigation.
