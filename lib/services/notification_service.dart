import 'dart:async';
import 'package:flutter_riverpod/legacy.dart';
import 'package:uuid/uuid.dart';
import 'package:segma/models/notification_model.dart';

class NotificationService extends StateNotifier<AppNotification?> {
  NotificationService() : super(null);

  Timer? _timer;
  final _uuid = const Uuid();

  /// Affiche une notification de type bulle (Toast)
  void show(String message, {NotificationType type = NotificationType.info, Duration? duration}) {
    _timer?.cancel();
    
    final notification = AppNotification(
      id: _uuid.v4(),
      message: message,
      type: type,
      duration: duration ?? const Duration(seconds: 4),
    );

    state = notification;

    _timer = Timer(notification.duration, () {
      if (state?.id == notification.id) {
        state = null;
      }
    });
  }

  /// Affiche un message de succès
  void success(String message) => show(message, type: NotificationType.success);

  /// Affiche un message d'erreur
  void error(String message) => show(message, type: NotificationType.error);

  /// Affiche un avertissement
  void warning(String message) => show(message, type: NotificationType.warning);

  /// Affiche une info
  void info(String message) => show(message, type: NotificationType.info);

  /// Efface la notification actuelle
  void dismiss() {
    _timer?.cancel();
    state = null;
  }
}

final notificationServiceProvider = StateNotifierProvider<NotificationService, AppNotification?>((ref) {
  return NotificationService();
});
