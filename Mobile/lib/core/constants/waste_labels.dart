/// Centralized display label mapping for AI-detected waste categories.
///
/// The ONNX model returns raw snake_case labels (e.g. `plastik_hdpe`).
/// Every screen must use [WasteLabels.display] to convert them to a
/// user-friendly string. Do NOT display raw model labels directly.
///
/// To add a new class: add one entry to [_map] here — no other file needs
/// to change.
import 'package:flutter/foundation.dart';

class WasteLabels {
  WasteLabels._();

  /// Map from raw ONNX model label / DB kategori → user-friendly display string.
  ///
  /// This is the Single Source of Truth for the 7 supported classes.
  static const Map<String, String> _map = {
    'organik': 'Organik',
    'plastik_hdpe': 'Plastik HDPE',
    'plastik_pet': 'Plastik PET',
    'kaca': 'Kaca',
    'kaleng': 'Kaleng',
    'kardus': 'Kardus',
    'kertas': 'Kertas',
  };

  /// Returns the user-friendly display label for a raw model label.
  ///
  /// Logs a warning and returns 'Lainnya' if the class is unrecognised.
  static String display(String? rawLabel) {
    if (rawLabel == null || rawLabel.trim().isEmpty) return '-';
    final key = rawLabel.trim().toLowerCase();

    if (_map.containsKey(key)) {
      return _map[key]!;
    }

    // Unrecognised label
    debugPrint('⚠️ [WasteLabels] WARNING: Unrecognised model class received: "$rawLabel". Defaulting to "Lainnya".');
    return 'Lainnya';
  }

  /// Returns all known display labels, sorted alphabetically.
  static List<String> get allDisplayLabels {
    final labels = _map.values.toSet().toList();
    labels.add('Lainnya');
    labels.sort();
    return labels;
  }

  /// Returns the raw ONNX model label for a given user-friendly display string.
  /// 
  /// Used when sending manual category updates back to the backend so the DB
  /// stores the raw key.
  static String reverseDisplay(String? displayName) {
    if (displayName == null || displayName.trim().isEmpty) return 'lainnya';
    final name = displayName.trim().toLowerCase();
    
    for (final entry in _map.entries) {
      if (entry.value.toLowerCase() == name) {
        return entry.key;
      }
    }
    return 'lainnya';
  }
}
