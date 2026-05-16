import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../bloc/auth_bloc.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../features/history/bloc/history_bloc.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool _minTimeElapsed = false;
  bool _authChecked = false;
  AuthState? _authResult;

  @override
  void initState() {
    super.initState();
    _startMinTimer();
    _checkAuth();
  }

  void _startMinTimer() {
    Future.delayed(const Duration(milliseconds: 2500), () {
      if (!mounted) return;
      setState(() => _minTimeElapsed = true);
      _tryNavigate();
    });
  }

  void _checkAuth() {
    context.read<AuthBloc>().stream.listen((state) {
      if (!mounted) return;
      if (state is AuthAuthenticated || state is AuthUnauthenticated) {
        setState(() {
          _authChecked = true;
          _authResult = state;
        });
        _tryNavigate();
      }
    });

    context.read<AuthBloc>().add(AuthCheckRequested());
  }

  void _tryNavigate() {
    if (!_minTimeElapsed || !_authChecked || _authResult == null) return;
    if (!mounted) return;

    if (_authResult is AuthAuthenticated) {
      context.read<HistoryBloc>().add(HistoryLoadeds());
      context.go('/chat');
    } else {
      context.go('/login');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                gradient: AppColors.gradientPrimary,
                borderRadius: BorderRadius.circular(24),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.4),
                    blurRadius: 32,
                    offset: const Offset(0, 12),
                  ),
                ],
              ),
              child: const Icon(
                Icons.auto_awesome,
                color: Colors.white,
                size: 42,
              ),
            )
                .animate()
                .fadeIn(duration: 600.ms)
                .scale(
                  begin: const Offset(0.5, 0.5),
                  end: const Offset(1.0, 1.0),
                  curve: Curves.elasticOut,
                  duration: 800.ms,
                ),

            const SizedBox(height: 28),

            // App name
            Text(
              'Docmind',
              style: AppTypography.displayLarge.copyWith(
                letterSpacing: -1,
              ),
            )
                .animate()
                .fadeIn(delay: 300.ms, duration: 500.ms)
                .slideY(begin: 0.3, end: 0),

            const SizedBox(height: 8),

            // Tagline
            Text(
              'Your AI Document Assistant',
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            )
                .animate()
                .fadeIn(delay: 500.ms, duration: 500.ms),

            const SizedBox(height: 60),

            // ✅ Animated loading dots
            _LoadingDots()
                .animate()
                .fadeIn(delay: 700.ms, duration: 400.ms),
          ],
        ),
      ),
    );
  }
}

class _LoadingDots extends StatefulWidget {
  @override
  State<_LoadingDots> createState() => _LoadingDotsState();
}

class _LoadingDotsState extends State<_LoadingDots>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, _) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(3, (i) {
            // Each dot animates with offset
            final delay = i * 0.2;
            final value = (_controller.value - delay) % 1.0;
            final opacity = value < 0.5
                ? value * 2
                : (1.0 - value) * 2;

            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 4),
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: AppColors.primary.withValues(
                  alpha: opacity.clamp(0.2, 1.0),
                ),
                shape: BoxShape.circle,
              ),
            );
          }),
        );
      },
    );
  }
}