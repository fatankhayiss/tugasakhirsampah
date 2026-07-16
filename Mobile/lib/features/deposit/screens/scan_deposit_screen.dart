import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:camera/camera.dart';

import 'package:mobile_user/core/repositories/detect_repository.dart';
import 'package:mobile_user/features/deposit/screens/detection_result_screen.dart';
import 'package:mobile_user/core/navigation/app_page_transitions.dart';

class ScanDepositScreen extends StatefulWidget {
  const ScanDepositScreen({super.key});

  @override
  State<ScanDepositScreen> createState() => _ScanDepositScreenState();
}

class _ScanDepositScreenState extends State<ScanDepositScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isUploading = false;

  @override
  void initState() {
    super.initState();
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted || cameras.isEmpty) return;
      
      // Gunakan kamera belakang (kamera utama)
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.medium,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
      });
    } catch (e) {
      debugPrint('Error menginisialisasi kamera: $e');
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scanFrameSize = (MediaQuery.of(context).size.width * 0.72).clamp(220.0, 340.0);
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
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Live Camera Preview
          if (_isCameraInitialized && _cameraController != null)
            SizedBox(
              width: double.infinity,
              height: double.infinity,
              child: CameraPreview(_cameraController!),
            )
          else
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircularProgressIndicator(color: Color(0xFF4AC08D)),
                  const SizedBox(height: 16),
                  Text(
                    'Membuka Kamera...',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.5),
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            
          // Dark Overlay with Cutout
          if (_isCameraInitialized)
            ColorFiltered(
              colorFilter: ColorFilter.mode(
                Colors.black.withValues(alpha: 0.6),
                BlendMode.srcOut,
              ),
              child: Stack(
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      color: Colors.black,
                      backgroundBlendMode: BlendMode.dstOut,
                    ),
                  ),
                  Center(
                    child: Container(
                      width: scanFrameSize,
                      height: scanFrameSize,
                      decoration: BoxDecoration(
                        color: Colors.white, // This part will be transparent due to dstOut
                        borderRadius: BorderRadius.circular(24),
                      ),
                    ),
                  ),
                ],
              ),
            ),

          // Scan Frame (Green Border)
          if (_isCameraInitialized)
            Center(
              child: Container(
                width: scanFrameSize,
                height: scanFrameSize,
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
                    color: _isUploading ? Colors.grey : const Color(0xFF4AC08D),
                    shape: const CircleBorder(),
                    child: InkWell(
                      customBorder: const CircleBorder(),
                      onTap: (_isUploading || !_isCameraInitialized) ? null : () async {
                        setState(() {
                          _isUploading = true;
                        });
                        
                        try {
                          // Ambil foto menggunakan kamera
                          final xFile = await _cameraController!.takePicture();
                          
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Memindai gambar...'),
                              backgroundColor: Color(0xFF4AC08D),
                              duration: Duration(seconds: 2),
                            ),
                          );
                          
                          // Upload foto asli ke backend
                          final repo = DetectRepository();
                          final resp = await repo.uploadFile(xFile.path);

                          if (resp.statusCode == 200) {
                            try {
                              final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
                              if (parsed['success'] == true && parsed.containsKey('data')) {
                                final data = Map<String, dynamic>.from(parsed['data']);
                                if (!context.mounted) return;
                                Navigator.pushReplacement(
                                  context,
                                  CustomPageRoute(
                                    page: DetectionResultScreen(responseData: data),
                                  ),
                                );
                                return;
                              }
                            } catch (e) {
                              debugPrint('JSON parse error: $e');
                            }
                          }

                          // Jika gagal parsing atau respons tidak 200
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Gagal mengenali gambar (Kode: ${resp.statusCode})'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Error kamera: $e'),
                              backgroundColor: Colors.redAccent,
                            ),
                          );
                        } finally {
                          if (mounted) {
                            setState(() {
                              _isUploading = false;
                            });
                          }
                        }
                      },
                      child: _isUploading 
                          ? const Center(child: CircularProgressIndicator(color: Colors.white))
                          : const SizedBox(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  _isUploading ? 'Sedang Menganalisa...' : 'Arahkan kamera ke sampah',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
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
