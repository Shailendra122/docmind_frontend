import 'package:docmind_flutter/features/chat/bloc/chat_bloc.dart';
import 'package:docmind_flutter/features/document/bloc/document_bloc.dart';
import 'package:docmind_flutter/features/history/bloc/history_bloc.dart';
import 'package:docmind_flutter/shared/app_shell.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/auth/bloc/auth_bloc.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/screens/signup_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/chat/screens/chat_screen.dart';

class AppRouter {
  AppRouter._();

  // Route names — use these instead of hardcoded strings
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const chat = '/chat';

  static GoRouter router(AuthBloc authBloc) {
    return GoRouter(
      initialLocation: splash,
      debugLogDiagnostics: kDebugMode,

      // Redirect logic — runs before every navigation
      redirect: (context, state) {
        final authState = authBloc.state;
        final isOnAuthPage =
            state.matchedLocation == login ||
            state.matchedLocation == signup ||
            state.matchedLocation == splash;

        // If authenticated and on auth page → go to chat
        if (authState is AuthAuthenticated && isOnAuthPage) {
          return chat;
        }

        // If not authenticated and trying to access chat → go to login
        if (authState is AuthUnauthenticated && !isOnAuthPage) {
          return login;
        }

        // No redirect needed
        return null;
      },

      // Listen to auth state changes and refresh router
      refreshListenable: GoRouterRefreshStream(authBloc.stream),

      routes: [
        GoRoute(
          path: login,
          builder: (context, state) => BlocProvider.value(
            value: context.read<HistoryBloc>(),
            child: const LoginScreen(),
          ),
        ),
        GoRoute(
          path: splash,
          builder: (context, state) => BlocProvider.value(
            value: context.read<HistoryBloc>(),
            child: const SplashScreen(),
          ),
        ),
        GoRoute(
          path: signup,
          builder: (context, state) => const SignupScreen(),
        ),
        GoRoute(
          path: chat,
          builder: (context, state) => MultiBlocProvider(
            providers: [
              BlocProvider.value(value: context.read<HistoryBloc>()),
              BlocProvider.value(value: context.read<DocumentBloc>()),
              BlocProvider.value(value: context.read<ChatBloc>()),
            ],
            child: const AppShell(child: ChatScreen()),
          ),
        ),
      ],

      // Error page
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text(
            'Page not found: ${state.error}',
            style: const TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}

// Helper — makes GoRouter react to BLoC stream changes
class GoRouterRefreshStream extends ChangeNotifier {
  GoRouterRefreshStream(Stream<dynamic> stream) {
    stream.listen((_) => notifyListeners());
  }
}
