import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/auth_bloc.dart';
import '../widgets/auth_button.dart';
import '../widgets/auth_header.dart';
import '../widgets/auth_text_field.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/utils/app_toast.dart';
import 'package:go_router/go_router.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _onSignup() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(
        AuthSignupRequested(
          fullName: _nameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        ),
      );
    }
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) {
      return 'Email is required';
    }

    final emailRegex = RegExp(
      r'^[\w-.]+@([\w-]+\.)+[\w-]{2,4}$',
    );

    if (!emailRegex.hasMatch(v.trim())) {
      return 'Enter a valid email';
    }

    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgDark,
      body: BlocConsumer<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state is AuthError) {
            showErrorToast(context, state.message);
          }

          if (state is AuthSignupSuccess) {
            if (!context.mounted) return;

            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (_) => AlertDialog(
                backgroundColor: AppColors.bgCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                title: Text(
                  '✅ Check your email',
                  style: AppTypography.headingMedium,
                ),
                content: Text(
                  'We sent a confirmation link to ${state.email}.\n\nPlease verify your email then sign in.',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      if (context.mounted) {
                        Navigator.pop(context);
                        context.go('/login');
                      }
                    },
                    child: const Text('Go to Login'),
                  ),
                ],
              ),
            );
          }
        },
        builder: (context, state) {
          final isLoading = state is AuthLoading;

          return SafeArea(
            child: Center(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 420),
                  child: IgnorePointer(
                    ignoring: isLoading,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: AuthHeader(
                              title: 'Create account',
                              subtitle:
                                  'Start chatting with your documents',
                            ),
                          ),

                          const SizedBox(height: 40),

                          AuthTextField(
                            label: 'Full Name',
                            hint: 'John Doe',
                            controller: _nameController,
                            validator: (v) {
                              if (v == null || v.trim().isEmpty) {
                                return 'Name is required';
                              }
                              return null;
                            },
                          ).animate().fadeIn(
                                delay: 200.ms,
                                duration: 400.ms,
                              ),

                          const SizedBox(height: 20),

                          AuthTextField(
                            label: 'Email',
                            hint: 'you@example.com',
                            controller: _emailController,
                            keyboardType: TextInputType.emailAddress,
                            validator: _validateEmail,
                          ).animate().fadeIn(
                                delay: 250.ms,
                                duration: 400.ms,
                              ),

                          const SizedBox(height: 20),

                          AuthTextField(
                            label: 'Password',
                            hint: '••••••••',
                            controller: _passwordController,
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Password is required';
                              }

                              if (v.length < 6) {
                                return 'Minimum 6 characters';
                              }

                              return null;
                            },
                          ).animate().fadeIn(
                                delay: 300.ms,
                                duration: 400.ms,
                              ),

                          const SizedBox(height: 20),

                          AuthTextField(
                            label: 'Confirm Password',
                            hint: '••••••••',
                            controller: _confirmPasswordController,
                            isPassword: true,
                            validator: (v) {
                              if (v == null || v.isEmpty) {
                                return 'Confirm your password';
                              }

                              if (v != _passwordController.text) {
                                return 'Passwords do not match';
                              }

                              return null;
                            },
                          ).animate().fadeIn(
                                delay: 350.ms,
                                duration: 400.ms,
                              ),

                          const SizedBox(height: 32),

                          AuthButton(
                            label: 'Create Account',
                            onTap: isLoading ? null : _onSignup,
                            isLoading: isLoading,
                          ),

                          const SizedBox(height: 24),

                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Already have an account? ',
                                  style: AppTypography.bodyMedium.copyWith(
                                    color: AppColors.textSecondary,
                                  ),
                                ),
                                GestureDetector(
                                  onTap: () => Navigator.pop(context),
                                  child: Text(
                                    'Sign In',
                                    style: AppTypography.bodyMedium.copyWith(
                                      color: AppColors.primary,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ).animate().fadeIn(delay: 400.ms),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}