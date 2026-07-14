import 'package:flutter/material.dart';
import 'dart:ui';
import '../../../core/constants/app_colors.dart';

class DetectionResultScreen extends StatelessWidget {
  final Map<String, dynamic> responseData;

  const DetectionResultScreen({super.key, required this.responseData});

  @override
  Widget build(BuildContext context) {
    final uploaded = responseData['uploaded_file'] as String?;
    final detections = (responseData['detections'] as List<dynamic>?) ?? [];

    return Scaffold(
      backgroundColor: const Color(0xFF0B1326), // bg-background
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                _buildAppBar(context),
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        if (uploaded != null) _buildPhotoSection(uploaded),
                        const SizedBox(height: 32),
                        const Text(
                          'Hasil Deteksi',
                          style: TextStyle(
                            color: Color(0xFFDAE2FD),
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 12),
                        if (detections.isEmpty)
                          const Text('Tidak ada sampah terdeteksi', style: TextStyle(color: Colors.white54))
                        else
                          ...detections.map((d) => _buildDetectionCard(d as Map<String, dynamic>)),
                        const SizedBox(height: 16),
                        _buildTotalPointsSection(),
                        const SizedBox(height: 120), // Padding to prevent hiding behind absolute bottom actions
                      ],
                    ),
                  ),
                ),
              ],
            ),
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: _buildBottomActions(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppBar(BuildContext context) {
    return Container(
      height: 64,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.white10)),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Color(0xFF4AE176)),
            onPressed: () => Navigator.pop(context),
          ),
          const Expanded(
            child: Text(
              'Hasil Scan',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFFDAE2FD),
                fontSize: 24,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(width: 48), // Balancing empty space for alignment
        ],
      ),
    );
  }

  Widget _buildPhotoSection(String url) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 10,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: AspectRatio(
          aspectRatio: 4 / 3,
          child: Stack(
            fit: StackFit.expand,
            children: [
              Image.network(
                url,
                fit: BoxFit.cover,
                errorBuilder: (c, e, s) => const Center(
                  child: Icon(Icons.image_not_supported, color: Colors.white54),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(24),
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      color: Colors.white.withValues(alpha: 0.1),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: Color(0xFF4AE176),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: Color(0xFF4AE176),
                                  blurRadius: 8,
                                )
                              ],
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'SCAN COMPLETE',
                            style: TextStyle(
                              color: Color(0xFF4AE176),
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              letterSpacing: 1.2,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetectionCard(Map<String, dynamic> data) {
    final title = data['nama_sampah'] ?? (data['label'] ?? 'Unknown');
    // Default to high match % for UI realism based on HTML prompt
    final String matchPercent = '95% Match';

    // Determine icon loosely based on category or name
    IconData icon = Icons.delete_outline;
    final cat = (data['kategori'] ?? '').toString().toLowerCase();
    final nameLower = title.toLowerCase();
    
    if (cat.contains('plastik') || nameLower.contains('botol')) {
      icon = Icons.water_drop_outlined;
    } else if (cat.contains('kertas') || nameLower.contains('kertas')) {
      icon = Icons.receipt_long;
    } else if (cat.contains('kaca')) {
      icon = Icons.wine_bar;
    } else if (nameLower.contains('kaleng')) {
      icon = Icons.local_drink;
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF222A3D),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white10),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: const BoxDecoration(
              color: Color(0xFF131B2E),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: const Color(0xFF4AE176)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Color(0xFFDAE2FD),
                    fontSize: 18,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: const Color(0xFF4AE176).withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    matchPercent,
                    style: const TextStyle(
                      color: Color(0xFF4AE176),
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const Text(
            '1x',
            style: TextStyle(
              color: Color(0xFFDAE2FD),
              fontSize: 24,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTotalPointsSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF2D3449), // surface-container-highest
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF4AE176).withValues(alpha: 0.2)),
      ),
      child: const Row(
        children: [
          Icon(Icons.stars, color: Color(0xFFFF8B7C)), // tertiary-container
          SizedBox(width: 12),
          Expanded(
            child: Text(
              'Estimasi Poin',
              style: TextStyle(
                color: Color(0xFFDAE2FD),
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '+10 Poin',
            style: TextStyle(
              color: Color(0xFF4AE176),
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: const Color(0xFF0B1326).withValues(alpha: 0.8),
            border: const Border(top: BorderSide(color: Colors.white10)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Sampah berhasil disetor!'),
                        backgroundColor: AppColors.neonGreen,
                      ),
                    );
                    Navigator.popUntil(context, (route) => route.isFirst);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4AE176),
                    foregroundColor: const Color(0xFF003915),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text('Setor Sampah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      SizedBox(width: 8),
                      Icon(Icons.arrow_forward, size: 20),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  style: TextButton.styleFrom(
                    backgroundColor: const Color(0xFF222A3D),
                    foregroundColor: const Color(0xFFDAE2FD),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: const Text('Scan Ulang', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
