import 'package:flutter/material.dart';
import 'package:top_snackbar_flutter/custom_snack_bar.dart';
import 'package:top_snackbar_flutter/top_snack_bar.dart';

void showSuccessToast(
  BuildContext context,
  String message,
) {
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.success(
      message: message,
    ),
    displayDuration: const Duration(seconds: 2),
  );
}

void showErrorToast(
  BuildContext context,
  String message,
) {
  showTopSnackBar(
    Overlay.of(context),
    CustomSnackBar.error(
      message: message,
    ),
    displayDuration: const Duration(seconds: 3),
  );
}