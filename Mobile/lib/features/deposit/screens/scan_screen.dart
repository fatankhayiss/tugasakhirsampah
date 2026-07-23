import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:convert';
import '../../../core/navigation/app_dialog_transitions.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/repositories/detect_repository.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/constants/waste_labels.dart';
import '../widgets/permission_modal_widget.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/scan_frame_widget.dart';
import '../widgets/camera_button_widget.dart';
import 'manual_deposit_screen.dart';

class ScanScreen extends StatefulWidget {
  final List<WasteItem>? existingCartItems;

  const ScanScreen({super.key, this.existingCartItems});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  bool _isPermissionDenied = false;
  bool _isUploading = false;
  late AnimationController _fadeSlideController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _fadeSlideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );
    _fadeAnimation = CurvedAnimation(parent: _fadeSlideController, curve: Curves.easeOut);
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0.0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _fadeSlideController, curve: Curves.easeOut));
    _fadeSlideController.forward();

    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
    if (!mounted) return;
    if (status.isGranted) {
      _initializeCamera();
    } else if (status.isDenied) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _showPermissionModal();
      });
    } else if (status.isPermanentlyDenied) {
      setState(() {
        _isPermissionDenied = true;
      });
    }
  }

  void _showPermissionModal() {
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionModalWidget(
        onGrant: () async {
          Navigator.pop(context);
          final result = await Permission.camera.request();
          if (!mounted) return;
          if (result.isGranted) {
            _initializeCamera();
          } else {
            setState(() {
              _isPermissionDenied = true;
            });
          }
        },
        onDeny: () {
          Navigator.pop(context);
          setState(() {
            _isPermissionDenied = true;
          });
        },
      ),
    );
  }

  Future<void> _initializeCamera() async {
    try {
      final cameras = await availableCameras();
      if (!mounted || cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;

      setState(() {
        _isCameraInitialized = true;
        _isPermissionGranted = true;
        _isPermissionDenied = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isPermissionDenied = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    _fadeSlideController.dispose();
    super.dispose();
  }

  Future<void> _handleCapture() async {
    if (_isUploading || !_isCameraInitialized) return;
    setState(() {
      _isUploading = true;
    });

    try {
      final xFile = await _cameraController!.takePicture();
      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (ctx) => AlertDialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          contentPadding: const EdgeInsets.all(24),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF22C55E)),
              SizedBox(height: 20),
              Text(
                'Foto berhasil diambil.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Memproses identifikasi AI...',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 13,
                  color: Color(0xFF6B7280),
                ),
              ),
            ],
          ),
        ),
      );

      final repo = DetectRepository();
      final resp = await repo.uploadFile(xFile.path);

      if (mounted) {
        Navigator.of(context, rootNavigator: true).pop();
      }

      if (resp.statusCode == 200) {
        try {
          final parsed = jsonDecode(resp.body) as Map<String, dynamic>;
          if (parsed['success'] == true && parsed.containsKey('data')) {
            final data = Map<String, dynamic>.from(parsed['data']);
            
            final uploadedUrl = data['uploaded_file'] as String? ?? xFile.path;
            final detections = (data['detections'] as List<dynamic>?) ?? [];
            String name = '-';
            String category = '-';
            String confidence = '-';
            double price = 250.0;

            if (detections.isNotEmpty) {
              final first = detections.first as Map<String, dynamic>;
              final rawLabel = first['label']?.toString();
              final rawKategori = first['kategori']?.toString();
              final namaSampah = first['nama_sampah']?.toString();

              // Use DB name if available, otherwise friendly display label
              if (namaSampah != null && namaSampah.isNotEmpty) {
                name = namaSampah;
              } else if (rawLabel != null) {
                name = WasteLabels.display(rawLabel);
              } else {
                name = WasteLabels.display(rawKategori) ;
              }

              // Friendly category display
              category = WasteLabels.display(rawLabel ?? rawKategori);

              // Confidence
              if (first['confidence'] != null) {
                final confVal = double.tryParse(first['confidence'].toString()) ?? 0.0;
                // API may return 0-1 or 0-100
                confidence = confVal > 1
                    ? '${confVal.toInt()}%'
                    : '${(confVal * 100).toInt()}%';
              }

              // Price — detect.php returns 'harga_per_kg'
              final rawPrice = first['harga_per_kg'] ?? first['harga'];
              if (rawPrice != null) {
                price = double.tryParse(rawPrice.toString()) ?? price;
              } else {
                // Category-based fallback
                final c = (rawKategori ?? '').toLowerCase();
                if (c.contains('logam') || c.contains('kaleng')) {
                  price = 300.0;
                } else if (c.contains('elektronik')) {
                  price = 400.0;
                } else if (c.contains('kaca')) {
                  price = 100.0;
                } else if (c.contains('kertas') || c.contains('kardus')) {
                  price = 150.0;
                } else if (c.contains('organik')) {
                  price = 50.0;
                }
              }
            } else if (data['label'] != null) {
              final rawLabel = data['label']?.toString();
              name = WasteLabels.display(rawLabel);
              category = WasteLabels.display(rawLabel ?? data['kategori']?.toString());
            }

            final newItem = WasteItem(
              id: 'scan_${DateTime.now().millisecondsSinceEpoch}',
              name: name,
              imageAsset: 'water_bottle',
              pricePerKg: price,
              weight: 1.0,
              imageUrl: uploadedUrl,
              category: category,
              confidence: confidence,
              isScanned: true,
            );

            if (!mounted) return;
            Navigator.pushReplacement(
              context,
              CustomPageRoute(
                page: ManualDepositScreen(
                  initialCartItems: widget.existingCartItems,
                  activeScannedItem: newItem,
                ),
              ),
            );
            return;
          }
        } catch (e) {
          debugPrint('JSON parse error: $e');
        }
      }

      if (!mounted) return;
      _showRecognitionErrorDialog();
    } catch (e) {
      if (mounted && _isUploading) {
        Navigator.of(context, rootNavigator: true).pop();
      }
      if (!mounted) return;
      _showRecognitionErrorDialog();
    } finally {
      if (mounted) {
        setState(() {
          _isUploading = false;
        });
      }
    }
  }

  void _showRecognitionErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Tidak dapat mengenali sampah.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Color(0xFF1F2937),
          ),
        ),
        content: const Text(
          'Silakan ambil foto kembali dengan pencahayaan yang jelas.',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            color: Color(0xFF6B7280),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            style: TextButton.styleFrom(foregroundColor: const Color(0xFF6B7280)),
            child: const Text('Tutup', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              if (_isCameraInitialized && !_isUploading) {
                _handleCapture();
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Scan Lagi', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Sesuai desain UI perbaikan:
    // Background halaman: #FFFFFF (putih)
    // Primary Green: #22C55E
    // Teks Instruksi: #6B7280 (abu-abu gelap)
    const primaryGreen = Color(0xFF22C55E);
    const textGray = Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: Container(
          color: Colors.white,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back_rounded, color: primaryGreen),
                    onPressed: () => Navigator.pop(context),
                  ),
                  const Expanded(
                    child: Text(
                      'Scan Sampah',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: Color(0xFF1F2937),
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(width: 48), // Balance spacing for centered title
                ],
              ),
            ),
          ),
        ),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SafeArea(
            child: Column(
              children: [
                const SizedBox(height: 12),
                Expanded(
                  child: _buildMainContent(),
                ),
                const SizedBox(height: 28),
                CameraButtonWidget(
                  isBlue: false,
                  onTap: () {
                    if (_isUploading || !_isCameraInitialized) return;
                    _handleCapture();
                  },
                ),
                const SizedBox(height: 16),
                Text(
                  _isUploading ? 'SEDANG MENGANALISA...' : 'ARAHKAN KAMERA KE SAMPAH',
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    color: textGray,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isPermissionDenied) {
      return _buildEmptyState(
        icon: Icons.videocam_off_outlined,
        title: 'Akses Kamera Ditolak',
        subtitle: 'Izinkan akses kamera di pengaturan perangkat agar AI dapat mendeteksi sampah',
        actionLabel: 'Buka Pengaturan',
        onAction: () => openAppSettings(),
      );
    }

    if (!_isPermissionGranted) {
      return _buildEmptyState(
        icon: Icons.photo_camera_rounded,
        title: 'Siap Melakukan Scan',
        subtitle: 'Fitur prediksi AI akan ditampilkan pada kamera live preview ini',
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Color(0xFF22C55E)),
            SizedBox(height: 16),
            Text(
              'Mengaktifkan Kamera...',
              style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600),
            ),
          ],
        ),
      );
    }

    return ScanFrameWidget(
      isBlue: false,
      child: CameraPreview(_cameraController!),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return ScanFrameWidget(
      isBlue: false,
      child: Container(
        color: const Color(0xFFF8FAFC),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: const Color(0xFF22C55E), size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                color: Color(0xFF1F2937),
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                subtitle,
                textAlign: TextAlign.center,
                style: const TextStyle(fontFamily: 'Plus Jakarta Sans', color: Color(0xFF6B7280), fontSize: 13),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(actionLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
              ),
            ]
          ],
        ),
      ),
    );
  }
}
