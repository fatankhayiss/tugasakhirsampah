import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';
import '../constants/app_colors.dart';
import '../navigation/app_dialog_transitions.dart';
import '../navigation/app_dialog_transitions.dart';
import '../../shared/widgets/location_picker_map.dart';

/// Helper class to verify mandatory address requirement before initiating pickup/deposit requests.
class AddressVerificationHelper {
  AddressVerificationHelper._();

  /// Checks whether the citizen has filled in their Full Address.
  /// If valid, executes [onValid] and returns true.
  /// If empty/'-', shows Material 3 Alert Dialog prompting the user to complete their address on ProfileScreen.
  static Future<bool> checkAndPrompt(BuildContext context, {required VoidCallback onValid}) async {
    final profile = await ProfileRepository().getProfile();
    final address = profile.address?.trim() ?? '';
    final lat = profile.latitude;
    final lng = profile.longitude;
    
    if (address.isNotEmpty && address != '-' && address.toLowerCase() != 'null' && lat != null && lng != null) {
      onValid();
      return true;
    }

    if (!context.mounted) return false;

    final proceed = await AppDialogTransitions.showFadeScaleDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Lengkapi Lokasi Penjemputan',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1E293B),
          ),
        ),
        content: const Text(
          'Sebelum membuat permintaan penjemputan sampah, Anda perlu menentukan lokasi rumah agar petugas dapat menemukan alamat Anda dengan akurat.',
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text(
              'Batal',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Tambahkan Lokasi'),
          ),
        ],
      ),
    );

    if (proceed == true) {
      if (!context.mounted) return false;
      final result = await Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const LocationPickerMap()),
      );

      if (result != null && result is Map<String, dynamic>) {
        final newLat = result['latitude'];
        final newLng = result['longitude'];
        final newAddress = result['address'];

        // Update profile silently
        await ProfileRepository().updateProfile(
          alamat: newAddress,
          latitude: newLat,
          longitude: newLng,
        );
        
        // After successfully picking and saving location, invoke onValid directly
        onValid();
        return true;
      }
    }

    return false;
  }
}
