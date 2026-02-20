import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/user.dart';
import '../../domain/usecases/check_auth_status_usecase.dart';
import '../../domain/usecases/forgot_password_usecase.dart';
import '../../domain/usecases/get_current_user_usecase.dart';
import '../../domain/usecases/login_usecase.dart';
import '../../domain/usecases/logout_usecase.dart';
import '../../domain/usecases/reload_user_usecase.dart';
import '../../domain/usecases/resend_email_verification_usecase.dart';
import '../../domain/usecases/send_email_verification_usecase.dart';
import '../../domain/usecases/sign_in_with_apple_usecase.dart';
import '../../domain/usecases/sign_in_with_google_usecase.dart';
import '../../domain/usecases/signup_usecase.dart';
import 'auth_event.dart';
import 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  final LoginUseCase loginUseCase;
  final SignUpUseCase signUpUseCase;
  final ForgotPasswordUseCase forgotPasswordUseCase;
  final LogoutUseCase logoutUseCase;
  final CheckAuthStatusUseCase checkAuthStatusUseCase;
  final GetCurrentUserUseCase getCurrentUserUseCase;
  final SendEmailVerificationUseCase sendEmailVerificationUseCase;
  final ResendEmailVerificationUseCase resendEmailVerificationUseCase;
  final ReloadUserUseCase reloadUserUseCase;
  final SignInWithGoogleUseCase signInWithGoogleUseCase;
  final SignInWithAppleUseCase signInWithAppleUseCase;
  
  StreamSubscription<User?>? _authStateSubscription;

  AuthBloc({
    required this.loginUseCase,
    required this.signUpUseCase,
    required this.forgotPasswordUseCase,
    required this.logoutUseCase,
    required this.checkAuthStatusUseCase,
    required this.getCurrentUserUseCase,
    required this.sendEmailVerificationUseCase,
    required this.resendEmailVerificationUseCase,
    required this.reloadUserUseCase,
    required this.signInWithGoogleUseCase,
    required this.signInWithAppleUseCase,
  }) : super(const AuthInitial()) {
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignUpRequested>(_onSignUpRequested);
    on<AuthForgotPasswordRequested>(_onForgotPasswordRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
    on<AuthStatusChecked>(_onAuthStatusChecked);
    on<AuthErrorShown>(_onErrorShown);
    on<_AuthUserChanged>(_onAuthUserChanged);
    on<SendEmailVerificationRequested>(_onSendEmailVerificationRequested);
    on<ResendEmailVerificationRequested>(_onResendEmailVerificationRequested);
    on<ReloadUserRequested>(_onReloadUserRequested);
    on<AuthSignInWithGoogleRequested>(_onSignInWithGoogleRequested);
    on<AuthSignInWithAppleRequested>(_onSignInWithAppleRequested);

    // Start with unauthenticated state if Firebase isn't configured
    // The stream subscription will be attempted when AuthStatusChecked is called
    // This avoids issues during BLoC construction
  }

  void _listenToAuthChanges() {
    // Only try to listen if not already closed
    if (isClosed) {
      debugPrint('AuthBloc is already closed, skipping stream subscription');
      return;
    }
    
    try {
      // Try to get the stream
      final stream = checkAuthStatusUseCase();
      
      // Only subscribe if we got a valid stream and BLoC is still open
      if (!isClosed) {
        _authStateSubscription = stream.listen(
          (user) {
            if (!isClosed) {
              try {
                if (user != null) {
                  if (state is! Authenticated || (state as Authenticated).user.uid != user.uid) {
                    add(_AuthUserChanged(user));
                  }
                } else {
                  if (state is! Unauthenticated) {
                    add(const _AuthUserChanged(null));
                  }
                }
              } catch (e) {
                debugPrint('Error in auth stream listener: $e');
              }
            }
          },
          onError: (error) {
            // Handle errors gracefully if Firebase isn't configured
            debugPrint('Auth stream error: $error');
            if (!isClosed) {
              try {
                add(const _AuthUserChanged(null));
              } catch (e) {
                // Ignore if already closed or other error
                debugPrint('Could not emit unauthenticated state: $e');
              }
            }
          },
          cancelOnError: false, // Don't cancel on error, keep listening
        );
      }
    } catch (e) {
      // If stream can't be created (Firebase not initialized), just continue
      // The app will work, but auth features won't function
      debugPrint('Could not create auth stream (Firebase may not be configured): $e');
      // Emit unauthenticated state immediately if BLoC is still open
      if (!isClosed) {
        try {
          add(const _AuthUserChanged(null));
        } catch (e2) {
          debugPrint('Could not emit initial unauthenticated state: $e2');
        }
      }
    }
  }
  
  @override
  Future<void> close() {
    // Cancel subscription first, then close the BLoC
    _authStateSubscription?.cancel();
    _authStateSubscription = null;
    return super.close();
  }
  
  void _onAuthUserChanged(_AuthUserChanged event, Emitter<AuthState> emit) {
    if (event.user != null) {
      final user = event.user as User;
      // Check email verification status
      if (!user.emailVerified) {
        emit(EmailNotVerified(user));
      } else {
        emit(Authenticated(user));
      }
    } else {
      emit(const Unauthenticated());
    }
  }

  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await loginUseCase(
        email: event.email,
        password: event.password,
      );
      // Check if email is verified
      if (!user.emailVerified) {
        emit(EmailNotVerified(user));
      } else {
        emit(Authenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignUpRequested(
    AuthSignUpRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signUpUseCase(
        email: event.email,
        password: event.password,
      );
      // Automatically send verification email after signup
      try {
        await sendEmailVerificationUseCase();
        emit(EmailVerificationSent(
          'Verification email sent! Please check your inbox to verify your email address.',
        ));
      } catch (e) {
        // If verification email fails, still show user as signed up but not verified
        emit(EmailNotVerified(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onForgotPasswordRequested(
    AuthForgotPasswordRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await forgotPasswordUseCase(event.email);
      emit(const PasswordResetSent(
        'Password reset email sent. Please check your inbox.',
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await logoutUseCase();
      emit(const Unauthenticated());
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  void _onAuthStatusChecked(
    AuthStatusChecked event,
    Emitter<AuthState> emit,
  ) {
    // Check current user immediately for faster initial state
    // This ensures users who are already logged in are recognized right away
    // Firebase Auth automatically persists sessions, so we check if user is already logged in
    try {
      final currentUser = getCurrentUserUseCase();
      if (currentUser != null) {
        // User is already authenticated, set state immediately
        if (!currentUser.emailVerified) {
          emit(EmailNotVerified(currentUser));
        } else {
          emit(Authenticated(currentUser));
        }
      } else {
        // No current user, emit unauthenticated state
        emit(const Unauthenticated());
      }
    } catch (e) {
      // If checking current user fails, just continue to stream listening
      debugPrint('Error checking current user: $e');
      emit(const Unauthenticated());
    }

    // Start listening to auth changes for future updates
    // This ensures the BLoC is fully constructed before subscribing
    if (_authStateSubscription == null && !isClosed) {
      _listenToAuthChanges();
    }
  }

  void _onErrorShown(
    AuthErrorShown event,
    Emitter<AuthState> emit,
  ) {
    // Reset error state - let the stream listener handle auth state
    // This will be updated by the authStateChanges stream
  }

  Future<void> _onSendEmailVerificationRequested(
    SendEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await sendEmailVerificationUseCase();
      emit(const EmailVerificationSent(
        'Verification email sent! Please check your inbox.',
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onResendEmailVerificationRequested(
    ResendEmailVerificationRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      await resendEmailVerificationUseCase();
      emit(const EmailVerificationSent(
        'Verification email resent! Please check your inbox.',
      ));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onReloadUserRequested(
    ReloadUserRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await reloadUserUseCase();
      if (!user.emailVerified) {
        emit(EmailNotVerified(user));
      } else {
        emit(Authenticated(user));
      }
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithGoogleRequested(
    AuthSignInWithGoogleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signInWithGoogleUseCase();
      // Social login users are automatically verified
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }

  Future<void> _onSignInWithAppleRequested(
    AuthSignInWithAppleRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(const AuthLoading());
    try {
      final user = await signInWithAppleUseCase();
      // Social login users are automatically verified
      emit(Authenticated(user));
    } catch (e) {
      emit(AuthError(e.toString()));
    }
  }
}

// Internal event for auth state changes
class _AuthUserChanged extends AuthEvent {
  final dynamic user;
  const _AuthUserChanged(this.user);
  
  @override
  List<Object?> get props => [user];
}

