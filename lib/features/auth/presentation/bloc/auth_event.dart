import 'package:equatable/equatable.dart';

abstract class AuthEvent extends Equatable {
  const AuthEvent();

  @override
  List<Object?> get props => [];
}

class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthLoginRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthSignUpRequested extends AuthEvent {
  final String email;
  final String password;

  const AuthSignUpRequested({
    required this.email,
    required this.password,
  });

  @override
  List<Object> get props => [email, password];
}

class AuthForgotPasswordRequested extends AuthEvent {
  final String email;

  const AuthForgotPasswordRequested({required this.email});

  @override
  List<Object> get props => [email];
}

class AuthLogoutRequested extends AuthEvent {
  const AuthLogoutRequested();
}

class AuthStatusChecked extends AuthEvent {
  const AuthStatusChecked();
}

class AuthErrorShown extends AuthEvent {
  const AuthErrorShown();
}

class SendEmailVerificationRequested extends AuthEvent {
  const SendEmailVerificationRequested();
}

class ResendEmailVerificationRequested extends AuthEvent {
  const ResendEmailVerificationRequested();
}

class ReloadUserRequested extends AuthEvent {
  const ReloadUserRequested();
}

class AuthSignInWithGoogleRequested extends AuthEvent {
  const AuthSignInWithGoogleRequested();
}

class AuthSignInWithAppleRequested extends AuthEvent {
  const AuthSignInWithAppleRequested();
}






