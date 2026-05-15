import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

class ErrorHandler {
  static String getReadableError(dynamic error) {
    final msg = error.toString().toLowerCase();

    if (msg.contains('network') ||
        msg.contains('socket') ||
        msg.contains('connection')) {
      return 'No internet connection. Please check your network.';
    }

    if (msg.contains('timeout')) {
      return 'Request timed out. Please try again.';
    }

    if (msg.contains('unauthorized') || msg.contains('401')) {
      return 'Session expired. Please login again.';
    }

    if (msg.contains('404')) {
      return 'Resource not found.';
    }

    if (msg.contains('500') || msg.contains('server')) {
      return 'Server error. Please try again later.';
    }

    if (msg.contains('supabase') || msg.contains('postgrest')) {
      return 'Database error. Please try again.';
    }

    // Clean up exception prefix
    return error
        .toString()
        .replaceAll('Exception: ', '')
        .replaceAll('Error: ', '');
  }

  static void showSnackbar(
    BuildContext context,
    String message, {
    bool isError = true,
  }) {
    if (!context.mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
            ),
          ),
          backgroundColor: isError
              ? AppColors.error
              : AppColors.success,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          duration: Duration(seconds: isError ? 4 : 2),
        ),
      );
  }
}