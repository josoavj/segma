import 'package:material_ui/material_ui.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/features/segmentation/view_models/segmentation_view_model.dart';
import 'package:segma/core/notifications/notification_service.dart';
import 'package:segma/core/config/backend_config.dart' as backend_config;
import 'package:segma/core/errors/error_handler.dart';

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
  bool _initializedFromBackend = false;

  final List<String> _availableModels = [
    backend_config.BackendConfig.sam3Model
  ];

  @override
  void initState() {
    super.initState();
    _selectedModel = backend_config.BackendConfig.sam3Model;
    _selectedDevice = 'cpu';
  }

  Future<void> _changeModel(String model, String device) async {
    setState(() => _isChanging = true);

    try {
      final result =
          await ref.read(changeModelProvider((model, device)).future);

      if (mounted) {
        final actualDevice = result['device'] as String? ?? device;
        final isLoaded = result['is_loaded'] as bool? ?? false;
        setState(() {
          _selectedModel = model;
          _selectedDevice = actualDevice;
        });
        if (isLoaded) {
          ref.read(notificationServiceProvider.notifier).success(
                'Modèle prêt sur $actualDevice',
              );
        } else {
          ref.read(notificationServiceProvider.notifier).error(
                'Le modèle n’a pas pu être chargé sur $actualDevice.',
              );
        }
        ref.invalidate(modelInfoProvider);
        ref.invalidate(healthCheckProvider);
      }
    } catch (e, stack) {
      if (mounted) {
        ref
            .read(notificationServiceProvider.notifier)
            .error(e, stackTrace: stack);
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
    final mpsAvailable = modelInfo?['mps_available'] as bool? ?? false;
    final availableDevices = [
      'cpu',
      if (cudaAvailable) 'cuda',
      if (mpsAvailable) 'mps',
    ];

    if (modelInfo != null && !_initializedFromBackend) {
      _selectedModel = modelInfo['model_type'] as String? ?? _selectedModel;
      final backendDevice = modelInfo['device'] as String?;
      _selectedDevice =
          availableDevices.contains(backendDevice) ? backendDevice! : 'cpu';
      _initializedFromBackend = true;
    }

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
                    backend_config.BackendConfig.modelDescriptions[model] ??
                        model;
                final sizeMb = backend_config.BackendConfig.modelSizes[model];
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
                          style:
                              Theme.of(context).textTheme.bodySmall?.copyWith(
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
                        device == 'cpu' ? Icons.memory : Icons.speed,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(switch (device) {
                        'cuda' => 'GPU (CUDA)',
                        'mps' => 'GPU (Apple Silicon)',
                        _ => 'CPU',
                      }),
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
                AppErrorHandler.getFriendlyMessage(error),
                style: TextStyle(color: Theme.of(context).colorScheme.error),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
