import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/config/backend_config.dart' as backend_config;
import 'package:segma/providers/segmentation_provider.dart';

class ModelConfigPage extends ConsumerWidget {
  const ModelConfigPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scheme = Theme.of(context).colorScheme;
    final modelInfoAsync = ref.watch(modelInfoProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Configuration du modèle'),
        centerTitle: true,
      ),
      body: modelInfoAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Erreur: $err')),
        data: (modelInfo) {
          final currentModel =
              modelInfo['model_type'] as String? ??
              backend_config.AppConfig.sam3Model;
          final currentDevice = modelInfo['device'] as String? ?? 'cpu';
          final availableModels =
              (modelInfo['available_models'] as List?)?.cast<String>() ??
              [backend_config.AppConfig.sam3Model];
          final cudaAvailable = modelInfo['cuda_available'] as bool? ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // État du serveur
                Card(
                  color: scheme.tertiaryContainer,
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: scheme.tertiary,
                          size: 32,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Serveur connecté',
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                'Backend: ${backend_config.AppConfig.backendUrl}',
                                style: TextStyle(
                                  color: scheme.onSurfaceVariant,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Configuration actuelle
                const Text(
                  'Configuration actuelle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Modèle'),
                            Text(
                              currentModel.toUpperCase(),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('Device'),
                            Text(
                              currentDevice.toUpperCase(),
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: scheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text('CUDA disponible'),
                            Icon(
                              cudaAvailable ? Icons.check : Icons.close,
                              color: cudaAvailable
                                  ? scheme.tertiary
                                  : scheme.error,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Sélection du modèle
                const Text(
                  'Changer le modèle',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                ...availableModels.map((model) {
                  final isSelected = model == currentModel;
                  return ModelTile(
                    model: model,
                    isSelected: isSelected,
                    onTap: () {
                      // Appeler le endpoint change model
                      _changeModel(context, ref, model, currentDevice);
                    },
                  );
                }).toList(),
                const SizedBox(height: 24),

                // Sélection du device
                const Text(
                  'Changer le device',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                DeviceTile(
                  device: 'cpu',
                  isSelected: currentDevice == 'cpu',
                  onTap: () {
                    _changeModel(context, ref, currentModel, 'cpu');
                  },
                ),
                if (cudaAvailable)
                  DeviceTile(
                    device: 'cuda',
                    isSelected: currentDevice == 'cuda',
                    onTap: () {
                      _changeModel(context, ref, currentModel, 'cuda');
                    },
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _changeModel(
    BuildContext context,
    WidgetRef ref,
    String model,
    String device,
  ) async {
    final messenger = ScaffoldMessenger.of(context);
    try {
      await ref.read(changeModelProvider((model, device)).future);
      messenger.showSnackBar(
        SnackBar(
          content: Text('Modèle changé: $model sur $device'),
          duration: const Duration(seconds: 2),
        ),
      );
      // Invalider le cache pour recharger les infos
      ref.invalidate(modelInfoProvider);
    } catch (e) {
      messenger.showSnackBar(
        SnackBar(content: Text('Erreur: $e'), backgroundColor: Colors.red),
      );
    }
  }
}

class ModelTile extends StatelessWidget {
  final String model;
  final bool isSelected;
  final VoidCallback onTap;

  const ModelTile({
    Key? key,
    required this.model,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: isSelected ? scheme.primaryContainer.withValues(alpha: 0.75) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      model.toUpperCase(),
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      _getModelDescription(model),
                      style: TextStyle(
                        fontSize: 12,
                        color: scheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.radio_button_checked,
                  color: scheme.onPrimaryContainer,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _getModelDescription(String model) {
    final description = backend_config.AppConfig.modelDescriptions[model];
    final sizeMb = backend_config.AppConfig.modelSizes[model];
    if (description == null) {
      return model;
    }
    if (sizeMb == null) {
      return description;
    }
    return '$description - ${sizeMb}MB';
  }
}

class DeviceTile extends StatelessWidget {
  final String device;
  final bool isSelected;
  final VoidCallback onTap;

  const DeviceTile({
    Key? key,
    required this.device,
    required this.isSelected,
    required this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Card(
      color: isSelected ? scheme.primaryContainer.withValues(alpha: 0.75) : null,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    device.toUpperCase(),
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    device == 'cpu'
                        ? 'Processeur central'
                        : 'GPU NVIDIA (rapide)',
                    style: TextStyle(
                      fontSize: 12,
                      color: scheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
              if (isSelected)
                Icon(
                  Icons.radio_button_checked,
                  color: scheme.onPrimaryContainer,
                )
              else
                Icon(
                  Icons.radio_button_unchecked,
                  color: scheme.onSurfaceVariant,
                ),
            ],
          ),
        ),
      ),
    );
  }
}
