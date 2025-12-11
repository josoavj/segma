import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/navigation_provider.dart';
import 'package:segma/config/app_config.dart';

class SettingsPage extends ConsumerWidget {
  const SettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDarkTheme = ref.watch(themeNotifierProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Paramètres'), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Section Thème
            _SettingsSection(
              title: 'Apparence',
              children: [
                _SettingsTile(
                  title: 'Thème',
                  subtitle: isDarkTheme ? 'Mode sombre' : 'Mode clair',
                  trailing: Switch(
                    value: isDarkTheme,
                    onChanged: (value) {
                      ref.read(themeNotifierProvider.notifier).setTheme(value);
                    },
                  ),
                ),
                _SettingsTile(
                  title: 'Préférence de couleur',
                  subtitle: 'Utiliser les paramètres système',
                  trailing: Switch(value: false, onChanged: (value) {}),
                ),
              ],
            ),

            // Section Backend
            _SettingsSection(
              title: 'Configuration Backend',
              children: [
                _SettingsTile(
                  title: 'URL du serveur',
                  subtitle: AppConfig.backendUrl,
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('URL: ${AppConfig.backendUrl}')),
                    );
                  },
                ),
                _SettingsTile(
                  title: 'État de la connexion',
                  subtitle: 'En ligne',
                  trailing: Container(
                    width: 12,
                    height: 12,
                    decoration: const BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
              ],
            ),

            // Section Modèle SAM
            _SettingsSection(
              title: 'Modèle SAM',
              children: [
                _SettingsTile(
                  title: 'Type de modèle',
                  subtitle: 'ViT-B (petit, rapide)',
                  onTap: () {},
                ),
                _SettingsTile(
                  title: 'Dispositif',
                  subtitle: 'CPU',
                  onTap: () {},
                ),
                _SettingsTile(
                  title: 'Statut du modèle',
                  subtitle: 'Non chargé',
                  trailing: const Icon(Icons.download, color: Colors.orange),
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Téléchargement du modèle...'),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Section Stockage
            _SettingsSection(
              title: 'Stockage',
              children: [
                _SettingsTile(
                  title: 'Espace utilisé',
                  subtitle: '234 MB / 2 GB',
                  trailing: Expanded(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: LinearProgressIndicator(
                        value: 234 / 2000,
                        minHeight: 6,
                      ),
                    ),
                  ),
                ),
                _SettingsTile(
                  title: 'Vider le cache',
                  subtitle: 'Supprimer les images temporaires',
                  trailing: const Icon(Icons.delete_outline),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) => AlertDialog(
                        title: const Text('Vider le cache'),
                        content: const Text(
                          'Êtes-vous sûr de vouloir supprimer les images temporaires ?',
                        ),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text('Annuler'),
                          ),
                          TextButton(
                            onPressed: () {
                              Navigator.pop(context);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Cache vidé')),
                              );
                            },
                            child: const Text('Supprimer'),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ],
            ),

            // Section À Propos
            _SettingsSection(
              title: 'À Propos',
              children: [
                _SettingsTile(title: 'Version', subtitle: '1.0.0'),
                _SettingsTile(
                  title: 'Vérifier les mises à jour',
                  subtitle: 'Vous avez la dernière version',
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Vous avez la dernière version'),
                      ),
                    );
                  },
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

class _SettingsSection extends StatelessWidget {
  final String title;
  final List<Widget> children;

  const _SettingsSection({required this.title, required this.children});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 24, 16, 12),
          child: Text(
            title,
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Colors.blue,
            ),
          ),
        ),
        ...children,
      ],
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.title,
    required this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: trailing,
      onTap: onTap,
    );
  }
}
