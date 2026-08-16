import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/widgets/common/settings_ui.dart';
import 'package:segma/services/notification_service.dart';
import 'package:segma/models/notification_model.dart';

class HealthCheckTile extends ConsumerWidget {
  const HealthCheckTile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final healthAsync = ref.watch(healthCheckProvider);

    return healthAsync.when(
      loading: () => SettingsTile(
        title: 'Vérifier la connexion',
        subtitle: 'Vérification...',
        trailing: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(scheme.primary),
          ),
        ),
      ),
      error: (err, stack) => SettingsTile(
        title: 'Vérifier la connexion',
        subtitle: 'Problème de connexion',
        trailing: Icon(Icons.error, color: scheme.error),
        onTap: () async {
          ref.invalidate(healthCheckProvider);
          ref.read(notificationServiceProvider.notifier).error(err, stackTrace: stack);
        },
      ),
      data: (health) {
        final status = health['status'] as String? ?? 'unknown';
        final isHealthy = status == 'healthy';
        return SettingsTile(
          title: 'Vérifier la connexion',
          subtitle: isHealthy ? 'Connecté' : 'Déconnecté',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHealthy
                  ? scheme.tertiaryContainer
                  : scheme.errorContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isHealthy ? scheme.tertiary : scheme.error,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isHealthy ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isHealthy
                        ? scheme.onTertiaryContainer
                        : scheme.onErrorContainer,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            ref.invalidate(healthCheckProvider);
            final type = isHealthy ? NotificationType.success : NotificationType.error;
            ref.read(notificationServiceProvider.notifier).show(
              'Status: $status',
              type: type,
            );
          },
        );
      },
    );
  }
}
