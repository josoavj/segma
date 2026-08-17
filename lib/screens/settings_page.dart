import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/navigation_provider.dart';
import 'package:segma/config/app_config.dart';
import 'package:segma/widgets/common/settings_ui.dart';
import 'package:segma/widgets/settings/health_check_tile.dart';
import 'package:segma/widgets/settings/model_info_tile.dart';
import 'package:segma/widgets/settings/storage_info_tile.dart';
import 'package:segma/widgets/settings/model_configuration_tile.dart';
import 'package:segma/widgets/dialogs/clear_cache_dialog.dart';
import 'package:segma/services/notification_service.dart';

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
                  subtitle: AppConfig.backendUrl,
                  onTap: () {
                    ref.read(notificationServiceProvider.notifier).info('URL: ${AppConfig.backendUrl}');
                  },
                ),
                SettingsTile(
                  title: 'État de la connexion',
                  subtitle: 'En ligne',
                  trailing: _StatusIndicator(
                    color: scheme.tertiary,
                    bgColor: scheme.tertiaryContainer,
                    onColor: scheme.onTertiaryContainer,
                    label: 'Actif',
                  ),
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
                    ref.read(notificationServiceProvider.notifier).success('Vous avez la dernière version');
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

class _StatusIndicator extends StatelessWidget {
  final Color color;
  final Color bgColor;
  final Color onColor;
  final String label;

  const _StatusIndicator({
    required this.color,
    required this.bgColor,
    required this.onColor,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: onColor,
            ),
          ),
        ],
      ),
    );
  }
}
