import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/repositories/detect_repository.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/scan_frame_widget.dart';
import '../widgets/camera_button_widget.dart';
import 'waste_scan_result_screen.dart';

class ScanDepositScreen extends StatefulWidget {
  final List<WasteItem>? existingCartItems;

  const ScanDepositScreen({super.key, this.existingCartItems});

  @override
  State<ScanDepositScreen> createState() => _ScanDepositScreenState();
}

class _ScanDepositScreenState extends State<ScanDepositScreen> with SingleTickerProviderStateMixin {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
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

    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) setState(() => _isPermissionDenied = true);
        return;
      }

      final cameras = await availableCameras();
      if (!mounted || cameras.isEmpty) return;
      
      final backCamera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );

      _cameraController = CameraController(
        backCamera,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
        _isPermissionDenied = false;
      });
    } catch (e) {
      if (mounted) setState(() => _isPermissionDenied = true);
      debugPrint('Error menginisialisasi kamera: $e');
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
    setState(() => _isUploading = true);

    try {
      final xFile = await _cameraController!.takePicture();
      if (!mounted) return;

      // ignore: use_build_context_synchronously
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
                'Mendeteksi jenis sampah...',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              SizedBox(height: 8),
              Text(
                'Mohon tunggu, AI sedang menganalisa gambar.',
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
      final result = await repo.detectImage(xFile.path);

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.of(context, rootNavigator: true).pop();

      if (!mounted) return;
      // ignore: use_build_context_synchronously
      Navigator.pushReplacement(
        context,
        CustomPageRoute(
          page: WasteScanResultScreen(
            result: result.withLocalImagePath(xFile.path),
            existingCartItems: widget.existingCartItems,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        try { Navigator.of(context, rootNavigator: true).pop(); } catch (_) {}
      }
      if (!mounted) return;
      // ignore: use_build_context_synchronously
      _showRecognitionErrorDialog();
    } finally {
      if (mounted) setState(() => _isUploading = false);
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
                  const SizedBox(width: 48),
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
                  onTap: _handleCapture,
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
      return ScanFrameWidget(
        isBlue: false,
        child: Container(
          color: const Color(0xFFF8FAFC),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.videocam_off_outlined, color: Color(0xFF22C55E), size: 64),
              const SizedBox(height: 16),
              const Text(
                'Akses Kamera Ditolak',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: Color(0xFF1F2937),
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  'Izinkan akses kamera di pengaturan perangkat agar AI dapat mengenali sampah.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Color(0xFF6B7280), fontSize: 13),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => openAppSettings(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryBlue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: const Text('Buka Pengaturan', style: TextStyle(fontWeight: FontWeight.w700)),
              ),
            ],
          ),
        ),
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
}
