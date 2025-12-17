import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:segma/providers/segmentation_provider.dart';

class ModelConfigPage extends ConsumerWidget {
  const ModelConfigPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          final currentModel = modelInfo['model_type'] as String? ?? 'vit_b';
          final currentDevice = modelInfo['device'] as String? ?? 'cpu';
          final availableModels =
              (modelInfo['available_models'] as List?)?.cast<String>() ??
              ['vit_b', 'vit_l', 'vit_h'];
          final cudaAvailable = modelInfo['cuda_available'] as bool? ?? false;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // État du serveur
                Card(
                  color: Colors.green[50],
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green[700],
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
                                'Backend: localhost:8000',
                                style: TextStyle(
                                  color: Colors.grey[600],
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
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
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
                              color: cudaAvailable ? Colors.green : Colors.red,
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
                if (cudaAvailable) ...[
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
                  DeviceTile(
                    device: 'cuda',
                    isSelected: currentDevice == 'cuda',
                    onTap: () {
                      _changeModel(context, ref, currentModel, 'cuda');
                    },
                  ),
                ],
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
    return Card(
      color: isSelected ? Colors.blue[50] : null,
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
                      style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(Icons.radio_button_checked, color: Colors.blue[700])
              else
                Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }

  String _getModelDescription(String model) {
    switch (model) {
      case 'vit_b':
        return '96MB - Rapide (CPU recommandé)';
      case 'vit_l':
        return '312MB - Équilibré';
      case 'vit_h':
        return '1.2GB - Très précis (GPU recommandé)';
      default:
        return '';
    }
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
    return Card(
      color: isSelected ? Colors.blue[50] : null,
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
                    style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                  ),
                ],
              ),
              if (isSelected)
                Icon(Icons.radio_button_checked, color: Colors.blue[700])
              else
                Icon(Icons.radio_button_unchecked, color: Colors.grey[400]),
            ],
          ),
        ),
      ),
    );
  }
}
