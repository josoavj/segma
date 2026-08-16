import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:segma/services/notification_service.dart';

class ClearCacheDialog extends ConsumerWidget {
  const ClearCacheDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;

    return AlertDialog(
      title: const Text('Vider le cache'),
      content: const Text(
        'Êtes-vous sûr de vouloir supprimer les images temporaires ?',
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () async {
            Navigator.pop(context);
            try {
              final appDir = await getApplicationDocumentsDirectory();
              final uploadsDir = Directory('${appDir.path}/uploads');

              if (await uploadsDir.exists()) {
                await uploadsDir.delete(recursive: true);
              }

              if (context.mounted) {
                ref.read(notificationServiceProvider.notifier).success('Cache vidé');
              }
            } catch (e, stack) {
              if (context.mounted) {
                ref.read(notificationServiceProvider.notifier).error(
                  "Impossible de vider le cache. Vérifiez les permissions.",
                  technicalError: e,
                  stackTrace: stack,
                );
              }
            }
          },
          style: FilledButton.styleFrom(
            backgroundColor: scheme.error,
          ),
          child: const Text('Supprimer'),
        ),
      ],
    );
  }
}
