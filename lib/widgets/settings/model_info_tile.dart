import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/widgets/common/settings_ui.dart';
import 'package:segma/services/notification_service.dart';
import 'package:segma/utils/error_handler.dart';

class ModelInfoTile extends ConsumerWidget {
  const ModelInfoTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final modelAsync = ref.watch(modelInfoProvider);

    return modelAsync.when(
      loading: () => Column(
        children: [
          SettingsTile(
            title: 'Type de modèle',
            subtitle: 'Chargement...',
            trailing: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
              ),
            ),
          ),
        ],
      ),
      error: (err, _) => Column(
        children: [
          SettingsTile(
            title: 'Type de modèle',
            subtitle: AppErrorHandler.getFriendlyMessage(err),
            trailing: Icon(Icons.error_outline, color: scheme.error),
          ),
        ],
      ),
      data: (info) {
        final modelType = info['model_type'] as String? ?? 'unknown';
        final device = info['device'] as String? ?? 'unknown';
        final isLoaded = info['is_loaded'] as bool? ?? false;
        final cudaAvailable = info['cuda_available'] as bool? ?? false;

        return Column(
          children: [
            SettingsTile(
              title: 'Type de modèle',
              subtitle: modelType.toUpperCase(),
              trailing: Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: scheme.primary,
              ),
              onTap: () {
                ref.read(notificationServiceProvider.notifier).info('Allez à "Configuration du modèle" pour changer');
              },
            ),
            SettingsTile(
              title: 'Dispositif',
              subtitle: device.toUpperCase(),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: device == 'cuda'
                      ? scheme.tertiaryContainer
                      : scheme.primaryContainer,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  device == 'cuda' ? '⚡ GPU' : '💻 CPU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: device == 'cuda'
                        ? scheme.tertiary
                        : scheme.primary,
                  ),
                ),
              ),
            ),
            SettingsTile(
              title: 'Statut du modèle',
              subtitle: isLoaded ? 'Chargé ✓' : 'Non chargé',
              trailing: Icon(
                isLoaded ? Icons.check_circle : Icons.download,
                color: isLoaded ? scheme.tertiary : scheme.secondary,
              ),
            ),
            if (!cudaAvailable)
              SettingsTile(
                title: 'CUDA',
                subtitle: 'Non disponible (GPU requis)',
                trailing: Icon(Icons.close, color: scheme.error),
              ),
          ],
        );
      },
    );
  }
}
