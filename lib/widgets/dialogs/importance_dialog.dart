import 'package:flutter/material.dart';
import 'package:segma/models/notification_model.dart';

class ImportanceDialog extends StatelessWidget {
  final String message;
  final NotificationType type;

  const ImportanceDialog({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final color = type.color(scheme);

    return AlertDialog(
      backgroundColor: scheme.surface,
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
        side: BorderSide(color: color.withValues(alpha: 0.5), width: 2),
      ),
      icon: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(type.icon, color: color, size: 40),
      ),
      title: Text(
        type == NotificationType.critical ? 'Alerte Critique' : 'Attention',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: scheme.onSurface,
        ),
      ),
      content: Text(
        message,
        textAlign: TextAlign.center,
        style: TextStyle(
          height: 1.5,
          color: scheme.onSurfaceVariant,
        ),
      ),
      actions: [
        Center(
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => Navigator.pop(context),
              style: FilledButton.styleFrom(
                backgroundColor: color,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text('Compris'),
            ),
          ),
        ),
      ],
      actionsPadding: const EdgeInsets.all(20),
    );
  }
}
