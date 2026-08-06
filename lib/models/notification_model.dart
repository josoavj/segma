import 'package:flutter/material.dart';

enum NotificationType {
  info,
  success,
  warning,
  error,
  critical;

  IconData get icon {
    switch (this) {
      case NotificationType.info:
        return Icons.info_outline;
      case NotificationType.success:
        return Icons.check_circle_outline;
      case NotificationType.warning:
        return Icons.warning_amber_rounded;
      case NotificationType.error:
        return Icons.error_outline;
      case NotificationType.critical:
        return Icons.gpp_maybe_outlined;
    }
  }

  Color color(ColorScheme scheme) {
    switch (this) {
      case NotificationType.info:
        return scheme.primary;
      case NotificationType.success:
        return Colors.teal;
      case NotificationType.warning:
        return Colors.orange;
      case NotificationType.error:
      case NotificationType.critical:
        return scheme.error;
    }
  }
}

class AppNotification {
  final String id;
  final String message;
  final NotificationType type;
  final Duration duration;

  AppNotification({
    required this.id,
    required this.message,
    this.type = NotificationType.info,
    this.duration = const Duration(seconds: 4),
  });
}
