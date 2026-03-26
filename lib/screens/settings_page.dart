import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/navigation_provider.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/config/app_config.dart';
import 'package:segma/config/backend_config.dart' as backend_config;
import 'dart:io';
import 'package:path_provider/path_provider.dart';

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
                  _HealthCheckTile(),
                ],
              ),
              const SizedBox(height: 24),

              // Section Modèle SAM
              _SettingsSection(
                title: 'Modèle SAM',
                children: [
                  _ModelInfoTile(),
                  const Divider(height: 1, indent: 0, endIndent: 0),
                  _ModelConfigurationTile(),
                ],
              ),
              const SizedBox(height: 24),

              // Section Stockage
              _SettingsSection(
                title: 'Stockage',
                children: [
                  _StorageInfoTile(),
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
                              onPressed: () async {
                                Navigator.pop(context);
                                try {
                                  final appDir =
                                      await getApplicationDocumentsDirectory();
                                  final uploadsDir = Directory(
                                    '${appDir.path}/uploads',
                                  );

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

/// Widget pour afficher l'état de la connexion (Health Check)
class _HealthCheckTile extends ConsumerWidget {
  const _HealthCheckTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final healthAsync = ref.watch(healthCheckProvider);

    return healthAsync.when(
      loading: () => _SettingsTile(
        title: 'Vérifier la connexion',
        subtitle: 'Vérification...',
        trailing: SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
          ),
        ),
      ),
      error: (err, _) => _SettingsTile(
        title: 'Vérifier la connexion',
        subtitle: 'Erreur de connexion ❌',
        trailing: Icon(Icons.error, color: Colors.red[700]),
        onTap: () async {
          ref.invalidate(healthCheckProvider);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Reconnexion en cours...')),
          );
        },
      ),
      data: (health) {
        final status = health['status'] as String? ?? 'unknown';
        final isHealthy = status == 'healthy';
        return _SettingsTile(
          title: 'Vérifier la connexion',
          subtitle: isHealthy ? 'Connecté ✓' : 'Déconnecté',
          trailing: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: isHealthy
                  ? Colors.green.withValues(alpha: 0.2)
                  : Colors.red.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: isHealthy ? Colors.green : Colors.red,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 6),
                Text(
                  isHealthy ? 'Actif' : 'Inactif',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    color: isHealthy ? Colors.green : Colors.red,
                  ),
                ),
              ],
            ),
          ),
          onTap: () {
            ref.invalidate(healthCheckProvider);
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Status: $status'),
                duration: const Duration(seconds: 2),
              ),
            );
          },
        );
      },
    );
  }
}

/// Widget pour afficher les infos du modèle SAM
class _ModelInfoTile extends ConsumerWidget {
  const _ModelInfoTile();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final modelAsync = ref.watch(modelInfoProvider);

    return modelAsync.when(
      loading: () => Column(
        children: [
          _SettingsTile(
            title: 'Type de modèle',
            subtitle: 'Chargement...',
            trailing: SizedBox(
              width: 24,
              height: 24,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
              ),
            ),
          ),
        ],
      ),
      error: (err, _) => Column(
        children: [
          _SettingsTile(
            title: 'Type de modèle',
            subtitle: 'Erreur: $err',
            trailing: Icon(Icons.error, color: Colors.red[700]),
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
            _SettingsTile(
              title: 'Type de modèle',
              subtitle: modelType.toUpperCase(),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Allez à "Configuration du modèle" pour changer',
                    ),
                  ),
                );
              },
            ),
            _SettingsTile(
              title: 'Dispositif',
              subtitle: device.toUpperCase(),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: device == 'cuda'
                      ? Colors.green.withValues(alpha: 0.2)
                      : Colors.blue.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  device == 'cuda' ? '⚡ GPU' : '💻 CPU',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    color: device == 'cuda'
                        ? Colors.green[700]
                        : Colors.blue[700],
                  ),
                ),
              ),
            ),
            _SettingsTile(
              title: 'Statut du modèle',
              subtitle: isLoaded ? 'Chargé ✓' : 'Non chargé',
              trailing: Icon(
                isLoaded ? Icons.check_circle : Icons.download,
                color: isLoaded ? Colors.green : Colors.orange,
              ),
            ),
            if (!cudaAvailable)
              _SettingsTile(
                title: 'CUDA',
                subtitle: 'Non disponible (GPU requis)',
                trailing: Icon(Icons.close, color: Colors.red[700]),
              ),
          ],
        );
      },
    );
  }
}

/// Widget pour afficher l'utilisation du stockage
class _StorageInfoTile extends StatefulWidget {
  const _StorageInfoTile();

  @override
  State<_StorageInfoTile> createState() => _StorageInfoTileState();
}

class _StorageInfoTileState extends State<_StorageInfoTile> {
  late Future<Map<String, double>> _storageFuture;

  @override
  void initState() {
    super.initState();
    _storageFuture = _getStorageInfo();
  }

  Future<Map<String, double>> _getStorageInfo() async {
    try {
      final appDir = await getApplicationDocumentsDirectory();
      final uploadsDir = Directory('${appDir.path}/uploads');

      double usedBytes = 0;

      if (await uploadsDir.exists()) {
        await for (var entity in uploadsDir.list(
          recursive: true,
          followLinks: false,
        )) {
          if (entity is File) {
            usedBytes += await entity.length();
          }
        }
      }

      final usedMB = usedBytes / (1024 * 1024);
      const totalMB = 2000.0; // 2GB

      return {'used': usedMB, 'total': totalMB, 'percentage': usedMB / totalMB};
    } catch (e) {
      return {'used': 0, 'total': 2000.0, 'percentage': 0};
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        FutureBuilder<Map<String, double>>(
          future: _storageFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return _SettingsTile(
                title: 'Espace utilisé',
                subtitle: 'Calcul...',
                trailing: SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey[300],
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue[400]!,
                      ),
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return _SettingsTile(title: 'Espace utilisé', subtitle: 'Erreur');
            }

            final data = snapshot.data!;
            final used = data['used']!.toStringAsFixed(1);
            final percentage = (data['percentage']! * 100).toStringAsFixed(0);

            return _SettingsTile(
              title: 'Espace utilisé',
              subtitle: '$used MB / 2000 MB ($percentage%)',
              trailing: SizedBox(
                width: 80,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: data['percentage'],
                    minHeight: 6,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Colors.blue[400]!,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// Widget de configuration du modèle SAM
class _ModelConfigurationTile extends ConsumerStatefulWidget {
  const _ModelConfigurationTile();

  @override
  ConsumerState<_ModelConfigurationTile> createState() =>
      _ModelConfigurationTileState();
}

class _ModelConfigurationTileState
    extends ConsumerState<_ModelConfigurationTile> {
  late String _selectedModel;
  late String _selectedDevice;
  bool _isChanging = false;

  final List<String> _availableModels = [backend_config.AppConfig.sam3Model];

  @override
  void initState() {
    super.initState();
    _selectedModel = backend_config.AppConfig.sam3Model;
    _selectedDevice = 'cpu';
  }

  Future<void> _changeModel(String model, String device) async {
    setState(() => _isChanging = true);

    try {
      await ref.read(changeModelProvider((model, device)).future);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Modèle changé: $model sur $device'),
            duration: const Duration(seconds: 3),
          ),
        );
        // Invalider les providers pour forcer la mise à jour
        ref.invalidate(modelInfoProvider);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erreur: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isChanging = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final modelInfoAsync = ref.watch(modelInfoProvider);
    final modelInfo = modelInfoAsync.asData?.value;
    final cudaAvailable = modelInfo?['cuda_available'] as bool? ?? false;
    final availableDevices = cudaAvailable ? ['cpu', 'cuda'] : ['cpu'];

    if (!availableDevices.contains(_selectedDevice)) {
      _selectedDevice = 'cpu';
    }

    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Configuration du modèle',
            style: Theme.of(
              context,
            ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),

          // Sélection du modèle
          Text('Modèle', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedModel,
              isExpanded: true,
              underline: const SizedBox(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items: _availableModels.map((model) {
                final label =
                    backend_config.AppConfig.modelDescriptions[model] ?? model;
                final sizeMb = backend_config.AppConfig.modelSizes[model];
                final size = sizeMb != null ? '$sizeMb MB' : null;

                return DropdownMenuItem(
                  value: model,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(label),
                      if (size != null)
                        Text(
                          size,
                          style: Theme.of(context).textTheme.bodySmall
                              ?.copyWith(
                                color: Theme.of(
                                  context,
                                ).colorScheme.onSurfaceVariant,
                              ),
                        ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isChanging
                  ? null
                  : (value) {
                      if (value != null && value != _selectedModel) {
                        setState(() => _selectedModel = value);
                      }
                    },
            ),
          ),
          const SizedBox(height: 16),

          // Sélection du device
          Text('Dispositif', style: Theme.of(context).textTheme.labelMedium),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              border: Border.all(
                color: Theme.of(context).colorScheme.outlineVariant,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: DropdownButton<String>(
              value: _selectedDevice,
              isExpanded: true,
              underline: const SizedBox(),
              padding: const EdgeInsets.symmetric(horizontal: 12),
              items: availableDevices.map((device) {
                return DropdownMenuItem(
                  value: device,
                  child: Row(
                    children: [
                      Icon(
                        device == 'cuda' ? Icons.speed : Icons.memory,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(device == 'cuda' ? 'GPU (CUDA)' : 'CPU'),
                    ],
                  ),
                );
              }).toList(),
              onChanged: _isChanging
                  ? null
                  : (value) {
                      if (value != null && value != _selectedDevice) {
                        setState(() => _selectedDevice = value);
                      }
                    },
            ),
          ),
          const SizedBox(height: 16),

          // Bouton de confirmation
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isChanging
                  ? null
                  : () => _changeModel(_selectedModel, _selectedDevice),
              icon: _isChanging
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Theme.of(context).colorScheme.onPrimary,
                        ),
                      ),
                    )
                  : const Icon(Icons.check),
              label: Text(_isChanging ? 'Changement en cours...' : 'Appliquer'),
            ),
          ),
          const SizedBox(height: 16),

          // Infos du modèle actuel
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainer,
              borderRadius: BorderRadius.circular(8),
            ),
            child: modelInfoAsync.when(
              data: (modelInfo) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'État actuel',
                      style: Theme.of(context).textTheme.labelSmall,
                    ),
                    const SizedBox(height: 8),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Modèle: ${modelInfo['model_type'] ?? 'N/A'}',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        if (modelInfo['is_loaded'] == true)
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.green.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Chargé',
                              style: TextStyle(
                                fontSize: 11,
                                color: Colors.green[700],
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Device: ${modelInfo['device'] ?? 'N/A'}',
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                );
              },
              loading: () => const CircularProgressIndicator(strokeWidth: 2),
              error: (error, _) => Text(
                'Erreur: $error',
                style: TextStyle(color: Colors.red[400]),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
