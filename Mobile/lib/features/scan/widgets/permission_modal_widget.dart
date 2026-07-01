import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';

class PermissionModalWidget extends StatelessWidget {
  final VoidCallback onGrant;
  final VoidCallback onDeny;

  const PermissionModalWidget({
    super.key,
    required this.onGrant,
    required this.onDeny,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.darkBackground.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(28),
          border: Border.all(
            color: AppColors.neonGreen.withValues(alpha: 0.04),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: AppColors.neonGreen.withValues(alpha: 0.04),
              blurRadius: 18,
              spreadRadius: 5,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.neonGreen.withValues(alpha: 0.04),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt_outlined,
                color: AppColors.neonGreen,
                size: 32,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Izinkan Akses Kamera',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.w700,
                letterSpacing: 0.5,
              ),
            ),
            const SizedBox(height: 12),
            const Text(
              'Aplikasi membutuhkan akses kamera untuk melakukan scan sampah dan mendeteksi jenis sampah secara realtime.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: onGrant,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.neonGreen,
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                  elevation: 0,
                ),
                child: const Text(
                  'Izinkan Kamera',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),
            TextButton(
              onPressed: onDeny,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white60,
              ),
              child: const Text(
                'Nanti Saja',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


