import 'package:flutter/material.dart';
import 'package:camera/camera.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/permission_modal_widget.dart';
import '../widgets/scan_frame_widget.dart';
import '../widgets/camera_button_widget.dart';

class ScanScreen extends StatefulWidget {
  const ScanScreen({super.key});

  @override
  State<ScanScreen> createState() => _ScanScreenState();
}

class _ScanScreenState extends State<ScanScreen> {
  CameraController? _cameraController;
  bool _isCameraInitialized = false;
  bool _isPermissionGranted = false;
  bool _isPermissionDenied = false;

  @override
  void initState() {
    super.initState();
    _checkCameraPermission();
  }

  Future<void> _checkCameraPermission() async {
    final status = await Permission.camera.status;
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
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => PermissionModalWidget(
        onGrant: () async {
          Navigator.pop(context);
          final result = await Permission.camera.request();
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
      if (cameras.isEmpty) return;

      _cameraController = CameraController(
        cameras.first,
        ResolutionPreset.high,
        enableAudio: false,
      );

      await _cameraController!.initialize();

      if (mounted) {
        setState(() {
          _isCameraInitialized = true;
          _isPermissionGranted = true;
          _isPermissionDenied = false;
        });
      }
    } catch (e) {
      setState(() {
        _isPermissionDenied = true;
      });
    }
  }

  @override
  void dispose() {
    _cameraController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: ClipRRect(
          child: Container(
            color: Colors.transparent,
            child: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: AppColors.neonGreen),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Expanded(
                      child: Text(
                        'Scan Sampah',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const SizedBox(width: 48), // Balance for arrow_back
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 16),
            Expanded(
              child: _buildMainContent(),
            ),
            const SizedBox(height: 32),
            CameraButtonWidget(
              onTap: () {
                // Future handle scan trigger
              },
            ),
            const SizedBox(height: 16),
            const Text(
              'ARAHKAN KAMERA KE SAMPAH',
              style: TextStyle(
                color: Colors.white54,
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 2,
              ),
            ),
            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildMainContent() {
    if (_isPermissionDenied) {
      return _buildEmptyState(
        icon: Icons.videocam_off_outlined,
        title: 'Akses Kamera Ditolak',
        subtitle: 'Izinkan akses kamera di pengaturan perangkat',
        actionLabel: 'Buka Pengaturan',
        onAction: () => openAppSettings(),
      );
    }

    if (!_isPermissionGranted) {
      return _buildEmptyState(
        icon: Icons.photo_camera,
        title: 'Camera Preview',
        subtitle: 'Fitur prediksi AI akan ditampilkan di sini',
      );
    }

    if (!_isCameraInitialized || _cameraController == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(color: AppColors.neonGreen),
            const SizedBox(height: 16),
            Text(
              'Mengaktifkan Kamera...',
              style: TextStyle(color: AppColors.neonGreen.withValues(alpha: 0.04)),
            ),
          ],
        ),
      );
    }

    // Live Camera
    return ScanFrameWidget(
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
      child: Container(
        color: AppColors.darkBackground,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: AppColors.neonGreen, size: 64),
            const SizedBox(height: 16),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
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
                style: const TextStyle(color: Colors.white60, fontSize: 13),
              ),
            ),
            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: onAction,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen.withValues(alpha: 0.04),
                  side: const BorderSide(color: AppColors.neonGreen),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                child: Text(
                  actionLabel,
                  style: const TextStyle(color: AppColors.neonGreen),
                ),
              ),
            ]
          ],
        ),
      ),
    );
  }
}



