import 'package:firebase_auth/firebase_auth.dart' show FirebaseAuth;
import '../features/auth/data/datasources/auth_remote_datasource.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/auth/domain/repositories/auth_repository.dart';
import '../features/auth/domain/usecases/check_auth_status_usecase.dart';
import '../features/auth/domain/usecases/forgot_password_usecase.dart';
import '../features/auth/domain/usecases/get_current_user_usecase.dart';
import '../features/auth/domain/usecases/login_usecase.dart';
import '../features/auth/domain/usecases/logout_usecase.dart';
import '../features/auth/domain/usecases/reload_user_usecase.dart';
import '../features/auth/domain/usecases/resend_email_verification_usecase.dart';
import '../features/auth/domain/usecases/send_email_verification_usecase.dart';
import '../features/auth/domain/usecases/sign_in_with_apple_usecase.dart';
import '../features/auth/domain/usecases/sign_in_with_google_usecase.dart';
import '../features/auth/domain/usecases/signup_usecase.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

class InjectionContainer {
  static final InjectionContainer _instance = InjectionContainer._internal();
  factory InjectionContainer() => _instance;
  InjectionContainer._internal();

  // Data Sources - lazy initialization to handle Firebase not being initialized
  AuthRemoteDataSource? _authRemoteDataSource;
  
  AuthRemoteDataSource get authRemoteDataSource {
    try {
      // Check if Firebase is initialized by trying to access it
      final firebaseAuth = FirebaseAuth.instance;
      _authRemoteDataSource ??= AuthRemoteDataSourceImpl(
        firebaseAuth: firebaseAuth,
      );
      return _authRemoteDataSource!;
    } catch (e) {
      // If Firebase fails, we still need to create something to avoid crashes
      // The error will be thrown when actually trying to use auth features
      throw Exception(
        'Firebase not initialized. Please configure Firebase first.\n'
        'See FIREBASE_SETUP.md for instructions.\n'
        'Error: $e'
      );
    }
  }

  // Repositories
  AuthRepository? _authRepository;
  
  AuthRepository get authRepository {
    _authRepository ??= AuthRepositoryImpl(
      remoteDataSource: authRemoteDataSource,
    );
    return _authRepository!;
  }

  // Use Cases - lazy initialization
  LoginUseCase? _loginUseCase;
  SignUpUseCase? _signUpUseCase;
  ForgotPasswordUseCase? _forgotPasswordUseCase;
  LogoutUseCase? _logoutUseCase;
  CheckAuthStatusUseCase? _checkAuthStatusUseCase;
  GetCurrentUserUseCase? _getCurrentUserUseCase;
  SendEmailVerificationUseCase? _sendEmailVerificationUseCase;
  ResendEmailVerificationUseCase? _resendEmailVerificationUseCase;
  ReloadUserUseCase? _reloadUserUseCase;
  SignInWithGoogleUseCase? _signInWithGoogleUseCase;
  SignInWithAppleUseCase? _signInWithAppleUseCase;

  // BLoC - lazy initialization (singleton, for backward compatibility)
  AuthBloc? _authBloc;
  
  AuthBloc get authBloc {
    if (_authBloc != null) return _authBloc!;
    return createAuthBloc();
  }
  
  // Create a new AuthBloc instance (for use with BlocProvider)
  AuthBloc createAuthBloc() {
    try {
      // Ensure use cases are initialized (this might fail if Firebase isn't configured)
      _loginUseCase ??= LoginUseCase(authRepository);
      _signUpUseCase ??= SignUpUseCase(authRepository);
      _forgotPasswordUseCase ??= ForgotPasswordUseCase(authRepository);
      _logoutUseCase ??= LogoutUseCase(authRepository);
      _checkAuthStatusUseCase ??= CheckAuthStatusUseCase(authRepository);
      _getCurrentUserUseCase ??= GetCurrentUserUseCase(authRepository);
      _sendEmailVerificationUseCase ??= SendEmailVerificationUseCase(authRepository);
      _resendEmailVerificationUseCase ??= ResendEmailVerificationUseCase(authRepository);
      _reloadUserUseCase ??= ReloadUserUseCase(authRepository);
      _signInWithGoogleUseCase ??= SignInWithGoogleUseCase(authRepository);
      _signInWithAppleUseCase ??= SignInWithAppleUseCase(authRepository);
      
      // Create new instance (not singleton)
      return AuthBloc(
        loginUseCase: _loginUseCase!,
        signUpUseCase: _signUpUseCase!,
        forgotPasswordUseCase: _forgotPasswordUseCase!,
        logoutUseCase: _logoutUseCase!,
        checkAuthStatusUseCase: _checkAuthStatusUseCase!,
        getCurrentUserUseCase: _getCurrentUserUseCase!,
        sendEmailVerificationUseCase: _sendEmailVerificationUseCase!,
        resendEmailVerificationUseCase: _resendEmailVerificationUseCase!,
        reloadUserUseCase: _reloadUserUseCase!,
        signInWithGoogleUseCase: _signInWithGoogleUseCase!,
        signInWithAppleUseCase: _signInWithAppleUseCase!,
      );
    } catch (e) {
      // If Firebase isn't initialized, the repository/authRemoteDataSource access will fail
      throw Exception(
        'Cannot create AuthBloc: Firebase not initialized.\n'
        'Please configure Firebase first.\n'
        'See FIREBASE_SETUP.md for instructions.\n'
        'Original error: $e'
      );
    }
  }
}

