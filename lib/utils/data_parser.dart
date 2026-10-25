import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:segma/models/models.dart';

/// Utilitaire pour le parsing de données lourdes sur des threads séparés (Isolates)
class DataParser {
  /// Parse un message de mise à jour de batch complet en Isolate
  static Future<Map<String, dynamic>> parseBatchUpdate(String jsonString) async {
    return compute(_decodeBatchUpdate, jsonString);
  }

  /// Convertit une Map volumineuse en SegmentationResult en Isolate
  static Future<SegmentationResult> convertToSegmentationResult(Map<String, dynamic> map) async {
    return compute(_convertMapToResult, map);
  }

  // Fonctions de décodage isolées (doivent être top-level ou statiques)

  static Map<String, dynamic> _decodeBatchUpdate(String source) {
    final Map<String, dynamic> update = jsonDecode(source);
    if (update['status'] == 'success' && update['result'] != null) {
      update['result_model'] = SegmentationResult.fromJson(update['result']);
    }
    return update;
  }

  static SegmentationResult _convertMapToResult(Map<String, dynamic> map) {
    return SegmentationResult.fromJson(map);
  }
}
