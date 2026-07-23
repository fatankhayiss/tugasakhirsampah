/// Centralized display label mapping for AI-detected waste categories.
///
/// The ONNX model returns raw snake_case labels (e.g. `plastik_hdpe`).
/// Every screen must use [WasteLabels.display] to convert them to a
/// user-friendly string. Do NOT display raw model labels directly.
///
/// To add a new class: add one entry to [_map] here — no other file needs
/// to change.
class WasteLabels {
  WasteLabels._();

  /// Map from raw ONNX model label → user-friendly display string.
  static const Map<String, String> _map = {
    'organik':      'Organik',
    'plastik_hdpe': 'Plastik HDPE',
    'plastik_pet':  'Plastik PET',
    'plastik':      'Plastik',
    'kaca':         'Kaca',
    'kaleng':       'Kaleng',
    'kardus':       'Kardus',
    'kertas':       'Kertas',
    'logam':        'Logam',
    'elektronik':   'Elektronik',
    'lainnya':      'Lainnya',
  };

  /// Returns the user-friendly display label for a raw model label.
  ///
  /// - Performs a case-insensitive lookup in [_map].
  /// - Falls back to a title-cased version if the label is not found,
  ///   so new classes degrade gracefully without crashing.
  /// - Returns `'-'` for null or empty input.
  static String display(String? rawLabel) {
    if (rawLabel == null || rawLabel.trim().isEmpty) return '-';
    final key = rawLabel.trim().toLowerCase();
    return _map[key] ?? _toTitleCase(rawLabel.trim());
  }

  /// Converts `snake_case` or `lowercase` to `Title Case`.
  /// e.g. `plastik_hdpe` → `Plastik Hdpe` (only used as fallback).
  static String _toTitleCase(String s) {
    return s
        .split('_')
        .map((w) => w.isEmpty ? '' : '${w[0].toUpperCase()}${w.substring(1)}')
        .join(' ');
  }

  /// Returns all known display labels, sorted alphabetically.
  /// Useful for building category picker UIs.
  static List<String> get allDisplayLabels {
    final labels = _map.values.toSet().toList();
    labels.sort();
    return labels;
  }
}
