import 'package:equatable/equatable.dart';
import '../../domain/entities/user.dart';

abstract class AuthState extends Equatable {
  const AuthState();

  @override
  List<Object?> get props => [];
}

class AuthInitial extends AuthState {
  const AuthInitial();
}

class AuthLoading extends AuthState {
  const AuthLoading();
}

class Authenticated extends AuthState {
  final User user;

  const Authenticated(this.user);

  @override
  List<Object> get props => [user];
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class AuthError extends AuthState {
  final String message;

  const AuthError(this.message);

  @override
  List<Object> get props => [message];
}

class PasswordResetSent extends AuthState {
  final String message;

  const PasswordResetSent(this.message);

  @override
  List<Object> get props => [message];
}

class EmailVerificationSent extends AuthState {
  final String message;

  const EmailVerificationSent(this.message);

  @override
  List<Object> get props => [message];
}

class EmailNotVerified extends AuthState {
  final User user;

  const EmailNotVerified(this.user);

  @override
  List<Object> get props => [user];
}






