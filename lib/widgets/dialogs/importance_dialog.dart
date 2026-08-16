import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/models/notification_model.dart';
import 'package:segma/providers/navigation_provider.dart';

class ImportanceDialog extends ConsumerWidget {
  final String message;
  final NotificationType type;

  const ImportanceDialog({
    super.key,
    required this.message,
    required this.type,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
        type == NotificationType.critical ? 'Alerte Système' : 'Information Importante',
        textAlign: TextAlign.center,
        style: TextStyle(
          fontWeight: FontWeight.w900,
          color: scheme.onSurface,
        ),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              height: 1.5,
              color: scheme.onSurfaceVariant,
            ),
          ),
          if (type == NotificationType.critical || type == NotificationType.error) ...[
            const SizedBox(height: 20),
            Text(
              "Les détails techniques ont été enregistrés pour l'assistance.",
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 11,
                fontStyle: FontStyle.italic,
                color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
              ),
            ),
          ],
        ],
      ),
      actions: [
        Column(
          children: [
            SizedBox(
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
                child: const Text('J\'ai compris'),
              ),
            ),
            if (type == NotificationType.critical || type == NotificationType.error) ...[
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  ref.read(currentPageProvider.notifier).state = NavigationPage.logs;
                },
                child: const Text('Consulter les logs détaillés'),
              ),
            ],
          ],
        ),
      ],
      actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    );
  }
}
