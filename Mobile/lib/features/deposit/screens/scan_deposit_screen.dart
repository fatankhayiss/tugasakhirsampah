// ignore_for_file: use_build_context_synchronously
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/navigation/app_page_transitions.dart';
import '../../../core/repositories/detect_repository.dart';
import '../../../core/models/waste_item.dart';
import '../../../core/constants/app_colors.dart';
import 'waste_scan_result_screen.dart';

class ScanDepositScreen extends StatefulWidget {
  final List<WasteItem>? existingCartItems;
  const ScanDepositScreen({super.key, this.existingCartItems});

  @override
  State<ScanDepositScreen> createState() => _ScanDepositScreenState();
}

class _ScanDepositScreenState extends State<ScanDepositScreen> with WidgetsBindingObserver {
  CameraController? _cameraController;
  List<CameraDescription> _cameras = [];
  bool _isCameraInitialized = false;
  bool _isPermissionDenied = false;
  bool _isUploading = false;
  FlashMode _flashMode = FlashMode.off;
  int _currentCameraIndex = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeCamera();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final CameraController? cameraController = _cameraController;
    if (cameraController == null || !cameraController.value.isInitialized) {
      return;
    }
    if (state == AppLifecycleState.inactive || state == AppLifecycleState.paused) {
      cameraController.dispose();
      _isCameraInitialized = false;
      if (mounted) setState(() {});
    } else if (state == AppLifecycleState.resumed) {
      _initCamera(_cameras[_currentCameraIndex]);
    }
  }

  Future<void> _initializeCamera() async {
    try {
      final status = await Permission.camera.request();
      if (!status.isGranted) {
        if (mounted) setState(() => _isPermissionDenied = true);
        return;
      }
      _cameras = await availableCameras();
      if (!mounted || _cameras.isEmpty) return;
      
      // Default to back camera
      _currentCameraIndex = _cameras.indexWhere((c) => c.lensDirection == CameraLensDirection.back);
      if (_currentCameraIndex == -1) _currentCameraIndex = 0;
      
      await _initCamera(_cameras[_currentCameraIndex]);
    } catch (e) {
      if (mounted) setState(() => _isPermissionDenied = true);
      debugPrint('Error menginisialisasi kamera: $e');
    }
  }

  Future<void> _initCamera(CameraDescription cameraDescription) async {
    if (_cameraController != null) {
      await _cameraController!.dispose();
    }
    _cameraController = CameraController(
      cameraDescription,
      ResolutionPreset.high,
      enableAudio: false,
    );
    try {
      await _cameraController!.initialize();
      await _cameraController!.setFlashMode(_flashMode);
      if (!mounted) return;
      setState(() {
        _isCameraInitialized = true;
        _isPermissionDenied = false;
      });
    } catch (e) {
      debugPrint('Error init camera: $e');
    }
  }

  void _toggleFlash() async {
    if (_cameraController == null) return;
    final newMode = _flashMode == FlashMode.off ? FlashMode.torch : FlashMode.off;
    await _cameraController!.setFlashMode(newMode);
    setState(() {
      _flashMode = newMode;
    });
  }

  void _switchCamera() async {
    if (_cameras.length < 2) return;
    _currentCameraIndex = (_currentCameraIndex + 1) % _cameras.length;
    _isCameraInitialized = false;
    setState(() {});
    await _initCamera(_cameras[_currentCameraIndex]);
  }

  Future<void> _handleCapture() async {
    if (_isUploading || !_isCameraInitialized) return;
    setState(() => _isUploading = true);

    try {
      final xFile = await _cameraController!.takePicture();
      if (!mounted) return;

      final permanentDir = Directory('${xFile.path.split('/').take(xFile.path.split('/').length - 1).join('/')}/scan_captured');
      if (!permanentDir.existsSync()) permanentDir.createSync(recursive: true);
      final permanentPath = '${permanentDir.path}/img_${DateTime.now().millisecondsSinceEpoch}.jpg';
      await File(xFile.path).copy(permanentPath);

      if (!mounted) return;
      _showLoadingDialog();

      final repo = DetectRepository();
      final result = await repo.detectImage(permanentPath);
      
      if (!mounted) return;
      await Future.delayed(const Duration(milliseconds: 300));
      Navigator.of(context, rootNavigator: true).pop(); // pop loading

      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        CustomPageRoute(
          page: WasteScanResultScreen(
            detectionId: result.detectionId,
            localImagePath: permanentPath,
            existingCartItems: widget.existingCartItems,
          ),
        ),
      );
    } catch (e) {
      debugPrint('ERROR Capture: $e');
      if (mounted) {
        await Future.delayed(const Duration(milliseconds: 300));
        try { Navigator.of(context, rootNavigator: true).pop(); } catch (_) {}
        _showRecognitionErrorDialog();
      }
    } finally {
      if (mounted) setState(() => _isUploading = false);
    }
  }

  void _showLoadingDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        contentPadding: const EdgeInsets.all(24),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: const [
            CircularProgressIndicator(color: Color(0xFF22C55E)),
            SizedBox(height: 20),
            Text(
              'Mendeteksi jenis sampah...',
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 16, fontWeight: FontWeight.w700, color: Color(0xFF1F2937)),
            ),
            SizedBox(height: 8),
            Text(
              'Mohon tunggu, AI sedang menganalisa gambar.',
              textAlign: TextAlign.center,
              style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 13, color: Color(0xFF6B7280)),
            ),
          ],
        ),
      ),
    );
  }

  void _showRecognitionErrorDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Tidak dapat mengenali sampah.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 18, fontWeight: FontWeight.w700, color: Color(0xFF1F2937))),
        content: const Text('Silakan ambil foto kembali dengan pencahayaan yang jelas.', style: TextStyle(fontFamily: 'Plus Jakarta Sans', fontSize: 14, color: Color(0xFF6B7280))),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            child: const Text('Scan Lagi', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    const primaryGreen = Color(0xFF22C55E);
    
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: primaryGreen),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Sampah',
          style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.w700),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (_isPermissionDenied) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.videocam_off_outlined, color: Color(0xFF22C55E), size: 64),
            const SizedBox(height: 16),
            const Text('Akses Kamera Ditolak', style: TextStyle(fontFamily: 'Plus Jakarta Sans', color: Color(0xFF1F2937), fontSize: 18, fontWeight: FontWeight.w700)),
            const SizedBox(height: 8),
            const Padding(padding: EdgeInsets.symmetric(horizontal: 32), child: Text('Izinkan akses kamera di pengaturan perangkat agar AI dapat mengenali sampah.', textAlign: TextAlign.center, style: TextStyle(color: Color(0xFF6B7280), fontSize: 13))),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => openAppSettings(),
              style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24))),
              child: const Text('Buka Pengaturan', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
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
            Text('Mengaktifkan Kamera...', style: TextStyle(color: Color(0xFF6B7280), fontWeight: FontWeight.w600)),
          ],
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 8),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Full cover preview using FittedBox and AspectRatio
                  SizedBox.expand(
                    child: FittedBox(
                      fit: BoxFit.cover,
                      child: SizedBox(
                        width: 100, // arbitrary base width
                        height: 100 * _cameraController!.value.aspectRatio, // Native aspect ratio
                        child: CameraPreview(_cameraController!),
                      ),
                    ),
                  ),
                  
                  // Frame (Border Tipis Hijau) and center transparency
                  Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: const Color(0xFF22C55E), width: 2.5),
                      borderRadius: BorderRadius.circular(24),
                    ),
                  ),
                  
                  // Flash & Switch Camera buttons on overlay
                  Positioned(
                    bottom: 16,
                    right: 16,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _buildGlassButton(
                          icon: Icons.flip_camera_ios_rounded,
                          onTap: _switchCamera,
                        ),
                        const SizedBox(height: 12),
                        _buildGlassButton(
                          icon: _flashMode == FlashMode.torch ? Icons.flash_on_rounded : Icons.flash_off_rounded,
                          onTap: _toggleFlash,
                          isActive: _flashMode == FlashMode.torch,
                        ),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 32.0, vertical: 20.0),
          child: Text(
            _isUploading ? 'SEDANG MENGANALISA...' : 'Arahkan kamera ke sampah agar sistem dapat mengenali jenis sampah.',
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              color: Color(0xFF6B7280),
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        
        // Capture Button
        Padding(
          padding: const EdgeInsets.only(bottom: 32.0),
          child: GestureDetector(
            onTap: _handleCapture,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: _isUploading ? 70 : 80,
              height: _isUploading ? 70 : 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: const Color(0xFF22C55E).withValues(alpha: 0.5), width: 4),
              ),
              child: Center(
                child: Container(
                  width: _isUploading ? 54 : 64,
                  height: _isUploading ? 54 : 64,
                  decoration: const BoxDecoration(
                    color: Color(0xFF22C55E),
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGlassButton({required IconData icon, required VoidCallback onTap, bool isActive = false}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isActive ? Colors.white : Colors.black.withValues(alpha: 0.4),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: isActive ? const Color(0xFF22C55E) : Colors.white, size: 24),
      ),
    );
  }
}
