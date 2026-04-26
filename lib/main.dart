import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:four_ideas/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:four_ideas/injection/injection_container.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_event.dart';
import 'package:four_ideas/app_router.dart';
import 'package:four_ideas/core/design_system/theme.dart';
import 'package:four_ideas/core/widgets/brand_splash_overlay.dart';
import 'package:four_ideas/seo/seo_binding.dart';
import 'package:go_router/go_router.dart';
import 'package:sizer/sizer.dart';

import 'url_strategy_stub.dart' if (dart.library.html) 'url_strategy_web.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  configureWebUrlStrategy();

  final goRouter = createAppRouter();
  attachSeoToRouter(goRouter);
  runApp(
    MyApp(
      router: goRouter,
      appInitialization: _initializeAppServices(),
    ),
  );
}

Future<void> _initializeAppServices() async {
  // Lock orientation to portrait only for mobile devices.
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Initialize Firebase once during bootstrap.
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    debugPrint('Firebase initialization error: $e');
    debugPrint('App will continue but authentication features may not work');
  }
}

class MyApp extends StatefulWidget {
  const MyApp({
    super.key,
    required this.router,
    required this.appInitialization,
  });

  final GoRouter router;
  final Future<void> appInitialization;

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> with SingleTickerProviderStateMixin {
  static const Duration _minSplashDuration = Duration(milliseconds: 1850);
  late final AnimationController _splashController;
  bool _isAppReady = false;

  @override
  void initState() {
    super.initState();
    _splashController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    // Start splash timing only after first paint so slower mobile startups
    // still show the full branded sequence.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _splashController.forward(from: 0);
      _runBootstrapFlow();
    });
  }

  Future<void> _runBootstrapFlow() async {
    await Future.wait([
      Future<void>.delayed(_minSplashDuration),
      widget.appInitialization,
    ]);
    if (!mounted) {
      return;
    }
    setState(() {
      _isAppReady = true;
    });
  }

  @override
  void dispose() {
    _splashController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      final injectionContainer = InjectionContainer();

      if (!_isAppReady) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: '4iDeas – Product Design & Development',
          themeMode: ThemeMode.dark,
          darkTheme: DesignSystemTheme.dark,
          theme: DesignSystemTheme.dark,
          home: Scaffold(
            body: SplashScreen(
              animation: _splashController,
              simplifiedMode: false,
            ),
          ),
        );
      }

      return BlocProvider<AuthBloc>(
        create: (context) {
          try {
            // Create a new BLoC instance (don't use singleton)
            final bloc = injectionContainer.createAuthBloc();
            // Trigger auth status check to start listening
            bloc.add(const AuthStatusChecked());
            return bloc;
          } catch (e, stackTrace) {
            debugPrint('Error creating AuthBloc: $e');
            debugPrint('Stack trace: $stackTrace');
            // If Firebase isn't configured, show error screen
            rethrow;
          }
        },
        child: Sizer(
          builder: (context, orientation, deviceType) {
            return MaterialApp.router(
              routerConfig: widget.router,
              debugShowCheckedModeBanner: false,
              title: '4iDeas – Product Design & Development',
              themeMode: ThemeMode.dark,
              darkTheme: DesignSystemTheme.dark,
              theme: DesignSystemTheme.dark,
            );
          },
        ),
      );
    } catch (e) {
      // If InjectionContainer fails completely, show error screen
      debugPrint('Critical error: $e');
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: '4iDeas',
        home: Scaffold(
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 24),
                  const Text(
                    'Firebase Not Configured',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Please configure Firebase to run this app.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'See FIREBASE_SETUP.md for instructions.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Error: ${e.toString()}',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[500],
                        fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }
}
