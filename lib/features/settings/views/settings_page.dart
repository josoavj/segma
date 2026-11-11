import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/app/shell/view_models/navigation_view_model.dart';
import 'package:segma/core/config/backend_config.dart';
import 'package:segma/features/settings/views/widgets/settings_ui.dart';
import 'package:segma/features/settings/views/widgets/health_check_tile.dart';
import 'package:segma/features/settings/views/widgets/model_info_tile.dart';
import 'package:segma/features/settings/views/widgets/storage_info_tile.dart';
import 'package:segma/features/settings/views/widgets/model_configuration_tile.dart';
import 'package:segma/features/settings/views/widgets/clear_cache_dialog.dart';
import 'package:segma/core/notifications/notification_service.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return SingleChildScrollView(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Section Apparence
            SettingsSection(
              title: 'Apparence',
              children: [
                SettingsTile(
                  title: 'Thème',
                  subtitle: isDarkTheme ? 'Mode sombre' : 'Mode clair',
                  trailing: Switch(
                    value: isDarkTheme,
                    onChanged: (value) {
                      ref.read(themeNotifierProvider.notifier).setTheme(value);
                    },
                  ),
                ),
                SettingsTile(
                  title: 'Couleur primaire',
                  subtitle: 'Bleu (défaut)',
                  trailing: Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: scheme.primary,
                      borderRadius: BorderRadius.circular(6),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section Backend
            SettingsSection(
              title: 'Configuration Backend',
              children: [
                SettingsTile(
                  title: 'URL du serveur',
                  subtitle: BackendConfig.backendUrl,
                  onTap: () {
                    ref
                        .read(notificationServiceProvider.notifier)
                        .info('URL: ${BackendConfig.backendUrl}');
                  },
                ),
                const HealthCheckTile(),
              ],
            ),
            const SizedBox(height: 24),

            // Section Modèle SAM
            SettingsSection(
              title: 'Modèle SAM',
              children: [
                const ModelInfoTile(),
                const ModelConfigurationTile(),
              ],
            ),
            const SizedBox(height: 24),

            // Section Stockage
            SettingsSection(
              title: 'Stockage',
              children: [
                const StorageInfoTile(),
                SettingsTile(
                  title: 'Vider le cache',
                  subtitle: 'Supprimer les images temporaires',
                  trailing: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: scheme.errorContainer,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.delete_outline,
                      color: Colors.white,
                      size: 18,
                    ),
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => const ClearCacheDialog(),
                    );
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),

            // Section À Propos
            SettingsSection(
              title: 'À Propos',
              children: [
                SettingsTile(
                  title: 'Version',
                  subtitle: '1.0.0',
                  trailing: Icon(
                    Icons.check_circle,
                    color: scheme.tertiary,
                    size: 20,
                  ),
                ),
                SettingsTile(
                  title: 'Vérifier les mises à jour',
                  subtitle: 'Vous avez la dernière version',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: scheme.primary,
                  ),
                  onTap: () {
                    ref
                        .read(notificationServiceProvider.notifier)
                        .success('Vous avez la dernière version');
                  },
                ),
                const SettingsTile(
                  title: 'Développeur',
                  subtitle: 'Josoa VONJINIAINA',
                  trailing: Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.blue,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}
