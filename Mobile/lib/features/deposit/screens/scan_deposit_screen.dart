import 'package:flutter/material.dart';
import 'dart:convert';

import 'package:mobile_user/core/constants/app_images.dart';
import 'package:mobile_user/core/repositories/detect_repository.dart';
import 'package:mobile_user/features/deposit/screens/detection_result_screen.dart';
import 'package:mobile_user/core/navigation/app_page_transitions.dart';

class ScanDepositScreen extends StatelessWidget {
  const ScanDepositScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back, color: Colors.white),
        ),
        title: const Text(
          'Scan Sampah',
          style: TextStyle(
            color: Colors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // Camera Preview Placeholder
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  Icons.camera_alt_outlined,
                  size: 100,
                  color: Colors.white.withValues(alpha: 0.04),
                ),
                const SizedBox(height: 24),
                Text(
                  'Camera Preview',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.04),
                    fontSize: 18,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  'Fitur prediksi akan ditambahkan',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.04),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
          // Scan Frame
          Center(
            child: Container(
              width: 280,
              height: 280,
              decoration: BoxDecoration(
                border: Border.all(color: const Color(0xFF4AC08D), width: 3),
                borderRadius: BorderRadius.circular(24),
              ),
            ),
          ),
          // Bottom Actions
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                Container(
                  width: 70,
                  height: 70,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                  ),
                  child: Material(
                    color: const Color(0xFF4AC08D),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: () async {
                        final repo = DetectRepository();
                        if (!context.mounted) return;
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Mengunggah...'),
                            backgroundColor: Color(0xFF4AC08D),
                          ),
                        );
                        try {
                          final resp = await repo.uploadAsset(
                            AppImages.botolPlastik,
                          );
                          // Debug prints
                          // ignore: avoid_print
                          print('Upload status: ${resp.statusCode}');
                          // ignore: avoid_print
                          print(resp.body);

                          // Parse responsebody and navigate to result screen if possible
                          try {
                            final parsed =
                                jsonDecode(resp.body) as Map<String, dynamic>;
                            if (parsed['success'] == true &&
                                parsed.containsKey('data')) {
                              final data = Map<String, dynamic>.from(
                                parsed['data'],
                              );
                              if (!context.mounted) return;
                              Navigator.push(
                                context,
                                CustomPageRoute(
                                  page: DetectionResultScreen(
                                    responseData: data,
                                  ),
                                ),
                              );
                              return;
                            }
                          } catch (e) {
                            // JSON parse failed, will show fallback snack
                            // ignore: avoid_print
                            print('JSON parse error: $e');
                          }

                          // Fallback: show confirmation message
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('contoh gambar sudah ke upload'),
                              backgroundColor: Color(0xFF4AC08D),
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Upload gagal: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        }
                      },
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  'Arahkan kamera ke sampah',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.04),
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
