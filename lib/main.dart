import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:four_ideas/firebase_options.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:four_ideas/injection/injection_container.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_bloc.dart';
import 'package:four_ideas/features/auth/presentation/bloc/auth_event.dart';
import 'package:four_ideas/screens/home_screen.dart';
import 'package:sizer/sizer.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Lock orientation to portrait only for mobile devices
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  } catch (e) {
    // Firebase initialization failed
    debugPrint('Firebase initialization error: $e');
    debugPrint('App will continue but authentication features may not work');
  }
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    try {
      final injectionContainer = InjectionContainer();
      
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
            return MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'My Web Page',
              theme: ThemeData(
                primarySwatch: Colors.blue,
                useMaterial3: false,
                fontFamily: GoogleFonts.albertSans().fontFamily,
                scrollbarTheme: ScrollbarThemeData(
                  thumbVisibility: WidgetStateProperty.resolveWith((_) => true),
                  thumbColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.5)),
                  trackColor: WidgetStateProperty.all(Colors.white.withValues(alpha: 0.12)),
                ),
              ),
              home: const HomeScreen(),
            );
          },
        ),
      );
    } catch (e) {
      // If InjectionContainer fails completely, show error screen
      debugPrint('Critical error: $e');
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'My Web Page',
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[500], fontFamily: 'monospace'),
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
