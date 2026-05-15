import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../core/utils/supabase_client.dart';
import '../../../core/errors/app_exceptions.dart';

part 'auth_event.dart';
part 'auth_state.dart';

class AuthBloc extends Bloc<AuthEvent, AuthState> {
  AuthBloc() : super(AuthInitial()) {
    on<AuthCheckRequested>(_onCheckRequested);
    on<AuthLoginRequested>(_onLoginRequested);
    on<AuthSignupRequested>(_onSignupRequested);
    on<AuthLogoutRequested>(_onLogoutRequested);
  }

  // Check if session already exists
  Future<void> _onCheckRequested(
    AuthCheckRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final session = supabase.auth.currentSession;
      if (session != null) {
        emit(
          AuthAuthenticated(
            userId: session.user.id,
            email: session.user.email ?? '',
          ),
        );
      } else {
        emit(AuthUnauthenticated());
      }
    } catch (e) {
      emit(AuthUnauthenticated());
    }
  }

  // Handle login
  Future<void> _onLoginRequested(
    AuthLoginRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await supabase.auth.signInWithPassword(
        email: event.email.trim(),
        password: event.password,
      );

      if (response.user != null) {
        emit(
          AuthAuthenticated(
            userId: response.user!.id,
            email: response.user!.email ?? '',
          ),
        );
      } else {
        emit(AuthError('Login failed. Please try again.'));
      }
    } on AuthException catch (e) {
      String message = e.message;
      if (message.contains('Invalid login')) {
        message = 'Invalid email or password.';
      } else if (message.contains('Email not confirmed')) {
        message = 'Please verify your email first.';
      }
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError('Login failed. Please try again.'));
    }
  }

  // Handle signup
  Future<void> _onSignupRequested(
    AuthSignupRequested event,
    Emitter<AuthState> emit,
  ) async {
    emit(AuthLoading());
    try {
      final response = await supabase.auth.signUp(
        email: event.email.trim(),
        password: event.password,
        data: {'full_name': event.fullName.trim()},
      );

      if (response.user != null) {
        emit(AuthSignupSuccess(event.email.trim()));
      } else {
        emit(AuthError('Signup failed. Please try again.'));
      }
    } on AuthException catch (e) {
      String message = e.message;
      if (message.contains('already registered')) {
        message = 'This email is already registered. Try logging in.';
      } else if (message.contains('Password should')) {
        message = 'Password must be at least 6 characters.';
      }
      emit(AuthError(message));
    } catch (e) {
      emit(AuthError('Signup failed. Please try again.'));
    }
  }

  // Handle logout
  Future<void> _onLogoutRequested(
    AuthLogoutRequested event,
    Emitter<AuthState> emit,
  ) async {
    try {
      emit(AuthUnauthenticated());

      await supabase.auth.signOut();
    } catch (e) {
      emit(AuthError('Logout failed. Please try again.'));
    }
  }
}
