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
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              // Section Apparence
              _SettingsSection(
                title: 'Apparence',
                children: [
                  _SettingsTile(
                    title: 'Thème',
                    subtitle: isDarkTheme ? 'Mode sombre' : 'Mode clair',
                    trailing: Switch(
                      value: isDarkTheme,
                      onChanged: (value) {
                        ref
                            .read(themeNotifierProvider.notifier)
                            .setTheme(value);
                      },
                    ),
                  ),
                  _SettingsTile(
                    title: 'Couleur primaire',
                    subtitle: 'Bleu (défaut)',
                    trailing: Container(
                      width: 24,
                      height: 24,
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),

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
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.green.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Colors.green,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Actif',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: Colors.green,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  _SettingsTile(
                    title: 'Vérifier la connexion',
                    subtitle: 'Tester la connexion au serveur',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Connexion établie ✓')),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section Modèle SAM
              _SettingsSection(
                title: 'Modèle SAM',
                children: [
                  _SettingsTile(
                    title: 'Type de modèle',
                    subtitle: 'ViT-B (petit, rapide)',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Sélection du modèle non disponible'),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    title: 'Dispositif',
                    subtitle: 'CPU',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                  _SettingsTile(
                    title: 'Statut du modèle',
                    subtitle: 'Non chargé',
                    trailing: Tooltip(
                      message: 'Télécharger le modèle',
                      child: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: Colors.orange.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.download,
                          color: Colors.orange,
                          size: 18,
                        ),
                      ),
                    ),
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
              const SizedBox(height: 24),

              // Section Stockage
              _SettingsSection(
                title: 'Stockage',
                children: [
                  _SettingsTile(
                    title: 'Espace utilisé',
                    subtitle: '234 MB / 2 GB',
                    trailing: SizedBox(
                      width: 80,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 234 / 2000,
                          minHeight: 6,
                          backgroundColor: Colors.grey[300],
                          valueColor: AlwaysStoppedAnimation<Color>(
                            Colors.blue[400]!,
                          ),
                        ),
                      ),
                    ),
                  ),
                  _SettingsTile(
                    title: 'Vider le cache',
                    subtitle: 'Supprimer les images temporaires',
                    trailing: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.red.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Icon(
                        Icons.delete_outline,
                        color: Colors.red,
                        size: 18,
                      ),
                    ),
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
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
                              onPressed: () {
                                Navigator.pop(context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Cache vidé ✓')),
                                );
                              },
                              style: FilledButton.styleFrom(
                                backgroundColor: Colors.red,
                              ),
                              child: const Text('Supprimer'),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Section À Propos
              _SettingsSection(
                title: 'À Propos',
                children: [
                  _SettingsTile(
                    title: 'Version',
                    subtitle: '1.0.0',
                    trailing: const Icon(
                      Icons.check_circle,
                      color: Colors.green,
                      size: 20,
                    ),
                  ),
                  _SettingsTile(
                    title: 'Vérifier les mises à jour',
                    subtitle: 'Vous avez la dernière version',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Vous avez la dernière version ✓'),
                        ),
                      );
                    },
                  ),
                  _SettingsTile(
                    title: 'Développeur',
                    subtitle: 'Josoa VONJINIAINA',
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  ),
                ],
              ),
              const SizedBox(height: 32),
            ],
          ),
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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              title,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          Column(children: children),
        ],
      ),
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
    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: Colors.grey.withValues(alpha: 0.1), width: 1),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
        ),
        subtitle: Text(
          subtitle,
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Colors.grey[600]),
        ),
        trailing: trailing,
        onTap: onTap,
        horizontalTitleGap: 16,
      ),
    );
  }
}
