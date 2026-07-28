// ignore_for_file: use_build_context_synchronously, depend_on_referenced_packages, unused_field`nimport 'package:flutter/material.dart';

class ScanOverlayWidget extends StatelessWidget {
  final bool isBlue;
  const ScanOverlayWidget({super.key, this.isBlue = false});

  @override
  Widget build(BuildContext context) {
    // Sesuai instruksi: Hapus semua tulisan "AI ACTIVE", "LAT: ...", "LON: ...", dan "SCAN_READY.EXE" dari area kamera.
    return const SizedBox.shrink();
  }
}
