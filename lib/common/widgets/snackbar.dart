import 'package:flutter/material.dart';
import 'package:awesome_snackbar_content/awesome_snackbar_content.dart';

enum SnackbarType { success, error, warning, info }

class SnackbarHelper {
  static void showSuccess(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showAwesomeSnackbar(
      context,
      message,
      ContentType.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showError(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showAwesomeSnackbar(
      context,
      message,
      ContentType.failure,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showWarning(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showAwesomeSnackbar(
      context,
      message,
      ContentType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void showInfo(
    BuildContext context,
    String message, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    _showAwesomeSnackbar(
      context,
      message,
      ContentType.help,
      duration: duration,
      actionLabel: actionLabel,
      onActionPressed: onActionPressed,
    );
  }

  static void _showAwesomeSnackbar(
    BuildContext context,
    String message,
    ContentType contentType, {
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionPressed,
  }) {
    final snackBar = SnackBar(
      /// need to set following properties for best effect of awesome_snackbar_content
      elevation: 0,
      behavior: SnackBarBehavior.floating,
      backgroundColor: Colors.transparent,
      duration: duration,
      content: AwesomeSnackbarContent(
        title: _getTitleFromContentType(contentType),
        message: message,
        contentType: contentType,
      ),
      action:
          (actionLabel != null && onActionPressed != null)
              ? SnackBarAction(
                label: actionLabel,
                onPressed: onActionPressed,
                textColor: Colors.white,
              )
              : null,
    );

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(snackBar);
  }

  static String _getTitleFromContentType(ContentType contentType) {
    switch (contentType) {
      case ContentType.success:
        return 'Success!';
      case ContentType.failure:
        return 'Error!';
      case ContentType.warning:
        return 'Warning!';
      case ContentType.help:
        return 'Info!';
      default:
        return 'Notification!';
    }
  }
}

// Extension for easier usage (keeping the same method names)
extension SnackbarExtension on BuildContext {
  void showSuccessSnackbar(String message, {Duration? duration}) {
    SnackbarHelper.showSuccess(
      this,
      message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void showErrorSnackbar(String message, {Duration? duration}) {
    SnackbarHelper.showError(
      this,
      message,
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  void showWarningSnackbar(String message, {Duration? duration}) {
    SnackbarHelper.showWarning(
      this,
      message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }

  void showInfoSnackbar(String message, {Duration? duration}) {
    SnackbarHelper.showInfo(
      this,
      message,
      duration: duration ?? const Duration(seconds: 3),
    );
  }
}
