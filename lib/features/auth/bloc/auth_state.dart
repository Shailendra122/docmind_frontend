part of 'auth_bloc.dart';

abstract class AuthState {}

// App just started, checking session
class AuthInitial extends AuthState {}

// Showing spinner
class AuthLoading extends AuthState {}

// Successfully logged in
class AuthAuthenticated extends AuthState {
  final String userId;
  final String email;

  AuthAuthenticated({
    required this.userId,
    required this.email,
  });
}

// Not logged in
class AuthUnauthenticated extends AuthState {}

// Something went wrong
class AuthError extends AuthState {
  final String message;
  AuthError(this.message);
}

// Signup successful — show verify email message
class AuthSignupSuccess extends AuthState {
  final String email;
  AuthSignupSuccess(this.email);
}