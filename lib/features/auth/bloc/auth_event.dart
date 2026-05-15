part of 'auth_bloc.dart';

abstract class AuthEvent {}

// Check if user is already logged in
class AuthCheckRequested extends AuthEvent {}

// User submits login form
class AuthLoginRequested extends AuthEvent {
  final String email;
  final String password;

  AuthLoginRequested({
    required this.email,
    required this.password,
  });
}

// User submits signup form
class AuthSignupRequested extends AuthEvent {
  final String email;
  final String password;
  final String fullName;

  AuthSignupRequested({
    required this.email,
    required this.password,
    required this.fullName,
  });
}

// User taps logout
class AuthLogoutRequested extends AuthEvent {}