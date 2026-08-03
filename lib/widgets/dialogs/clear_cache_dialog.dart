import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class ClearCacheDialog extends StatelessWidget {
  const ClearCacheDialog({super.key});

  @override
  Widget build(BuildContext context) {
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Cache vidé ✓'),
                    duration: Duration(seconds: 2),
                  ),
                );
              }
            } catch (e) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Erreur: $e'),
                    backgroundColor: Colors.red,
                  ),
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
