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

  /// Map from raw ONNX model label / DB kategori → user-friendly display string.
  ///
  /// Keys should be lowercase. Includes English AI label variants,
  /// Indonesian DB kategori values, and common aliases.
  static const Map<String, String> _map = {
    // ── Indonesian ONNX labels ──────────────────────────────────
    'organik':           'Organik',
    'plastik_hdpe':      'Plastik HDPE',
    'plastik_pet':       'Plastik PET',
    'plastik':           'Plastik',
    'kaca':              'Kaca',
    'kaleng':            'Kaleng',
    'kardus':            'Kardus',
    'kertas':            'Kertas',
    'logam':             'Logam',
    'elektronik':        'Elektronik',
    'lainnya':           'Lainnya',

    // ── English AI model labels ─────────────────────────────────
    'plastic':           'Plastik',
    'plastic_pet':       'Plastik PET',
    'plastic_hdpe':      'Plastik HDPE',
    'bottle_pet':        'Botol Plastik PET',
    'bottle':            'Botol Plastik',
    'glass':             'Kaca',
    'cardboard':         'Kardus',
    'paper':             'Kertas',
    'metal':             'Logam',
    'can':               'Kaleng',
    'tin_can':           'Kaleng',
    'organic':           'Organik',
    'electronic':        'Elektronik',
    'e-waste':           'Elektronik',
    'other':             'Lainnya',
    'trash':             'Lainnya',

    // ── DB kategori variations (from jenis_sampah table) ───────
    'plastik pet':       'Plastik PET',
    'plastik hdpe':      'Plastik HDPE',
    'botol plastik':     'Botol Plastik',
    'botol plastik pet': 'Botol Plastik PET',
    'kaca bening':       'Kaca',
    'kertas hvs':        'Kertas',
    'sampah organik':    'Organik',
    'sampah elektronik': 'Elektronik',
    'logam besi':        'Logam',
    'logam aluminium':   'Logam',
  };

  /// Returns the user-friendly display label for a raw model label.
  ///
  /// - Performs a case-insensitive exact lookup first.
  /// - If no exact match, tries a partial/contains match for common roots.
  /// - Falls back to a title-cased version so new classes degrade gracefully.
  /// - Returns `'-'` for null or empty input.
  static String display(String? rawLabel) {
    if (rawLabel == null || rawLabel.trim().isEmpty) return '-';
    final key = rawLabel.trim().toLowerCase();

    // 1. Exact match
    if (_map.containsKey(key)) return _map[key]!;

    // 2. Partial match — iterate map keys, check if the incoming label
    //    contains a known key OR the key contains the label.
    for (final entry in _map.entries) {
      if (key.contains(entry.key) || entry.key.contains(key)) {
        return entry.value;
      }
    }

    // 3. Root-word heuristic for unrecognised labels
    if (key.contains('plastik') || key.contains('plastic') || key.contains('pet') || key.contains('hdpe')) {
      return 'Plastik';
    }
    if (key.contains('kardus') || key.contains('cardboard') || key.contains('karton')) return 'Kardus';
    if (key.contains('kertas') || key.contains('paper')) return 'Kertas';
    if (key.contains('kaca') || key.contains('glass')) return 'Kaca';
    if (key.contains('logam') || key.contains('metal') || key.contains('besi') || key.contains('baja')) return 'Logam';
    if (key.contains('kaleng') || key.contains('can') || key.contains('tin')) return 'Kaleng';
    if (key.contains('organik') || key.contains('organic')) return 'Organik';
    if (key.contains('elektronik') || key.contains('electronic') || key.contains('e-waste')) return 'Elektronik';

    // 4. Title-case fallback
    return _toTitleCase(rawLabel.trim());
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
