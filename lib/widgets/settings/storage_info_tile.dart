import 'dart:io';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:segma/widgets/common/settings_ui.dart';

class StorageInfoTile extends StatefulWidget {
  const StorageInfoTile({super.key});

  @override
  State<StorageInfoTile> createState() => _StorageInfoTileState();
}

class _StorageInfoTileState extends State<StorageInfoTile> {
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
              return const SettingsTile(
                title: 'Espace utilisé',
                subtitle: 'Calcul...',
                trailing: SizedBox(
                  width: 80,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.grey,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.blue,
                      ),
                    ),
                  ),
                ),
              );
            }

            if (!snapshot.hasData) {
              return const SettingsTile(title: 'Espace utilisé', subtitle: 'Erreur');
            }

            final data = snapshot.data!;
            final used = data['used']!.toStringAsFixed(1);
            final percentage = (data['percentage']! * 100).toStringAsFixed(0);

            return SettingsTile(
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
                      Colors.blue,
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
