import 'package:flutter/material.dart';
import '../repositories/profile_repository.dart';
import '../constants/app_colors.dart';
import '../../features/home/screens/main_navigation_screen.dart';
import '../navigation/app_dialog_transitions.dart';

/// Helper class to verify mandatory address requirement before initiating pickup/deposit requests.
class AddressVerificationHelper {
  AddressVerificationHelper._();

  /// Checks whether the citizen has filled in their Full Address.
  /// If valid, executes [onValid] and returns true.
  /// If empty/'-', shows Material 3 Alert Dialog prompting the user to complete their address on ProfileScreen.
  static Future<bool> checkAndPrompt(BuildContext context, {required VoidCallback onValid}) async {
    final profile = await ProfileRepository().getProfile();
    final address = profile.address?.trim() ?? '';
    
    if (address.isNotEmpty && address != '-' && address.toLowerCase() != 'null') {
      onValid();
      return true;
    }

    if (!context.mounted) return false;

    await AppDialogTransitions.showFadeScaleDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Alamat Belum Lengkap',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: Color(0xFF1E293B),
          ),
        ),
        content: const Text(
          'Anda harus melengkapi alamat terlebih dahulu sebelum membuat permintaan penjemputan sampah.',
          style: TextStyle(
            fontSize: 14,
            height: 1.4,
            color: Color(0xFF64748B),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Nanti',
              style: TextStyle(color: Colors.grey, fontWeight: FontWeight.w600),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              MainNavigationScreen.switchTab(context, 3, autoOpenEditAddress: true);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primary,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
            child: const Text('Lengkapi Sekarang'),
          ),
        ],
      ),
    );
    return false;
  }
}
