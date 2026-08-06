import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/segmentation_provider.dart';
import 'package:segma/services/notification_service.dart';
import 'package:segma/config/backend_config.dart' as backend_config;

class ModelConfigurationTile extends ConsumerStatefulWidget {
  const ModelConfigurationTile({super.key});

  @override
  ConsumerState<ModelConfigurationTile> createState() =>
      _ModelConfigurationTileState();
}

class _ModelConfigurationTileState
    extends ConsumerState<ModelConfigurationTile> {
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
        ref.read(notificationServiceProvider.notifier).success('Modèle changé: $model sur $device');
        // Invalider les providers pour forcer la mise à jour
        ref.invalidate(modelInfoProvider);
      }
    } catch (e) {
      if (mounted) {
        ref.read(notificationServiceProvider.notifier).error('Erreur: $e');
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
                final scheme = Theme.of(context).colorScheme;

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
                              color: scheme.tertiaryContainer,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              'Chargé',
                              style: TextStyle(
                                fontSize: 11,
                                color: scheme.onTertiaryContainer,
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
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
