import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/navigation/app_dialog_transitions.dart';
import '../../../shared/widgets/primary_button.dart';
import '../widgets/auth_textfield.dart';

class ResetPasswordScreen extends StatefulWidget {
  final String email;
  final String resetToken;

  const ResetPasswordScreen({
    super.key,
    required this.email,
    required this.resetToken,
  });

  @override
  State<ResetPasswordScreen> createState() => _ResetPasswordScreenState();
}

class _ResetPasswordScreenState extends State<ResetPasswordScreen> {
  final _newPasswordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showM3Dialog({
    required String title,
    required String message,
    String buttonText = 'OK',
    VoidCallback? onPressed,
    bool barrierDismissible = true,
  }) {
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.transparent,
        titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
        contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
        actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
        title: Text(
          title,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontWeight: FontWeight.w700,
            fontSize: 18,
            color: AppColors.textDark,
          ),
        ),
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            fontSize: 14,
            color: AppColors.textSoft,
            height: 1.5,
          ),
        ),
        actions: [
          SizedBox(
            width: double.infinity,
            height: 46,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primaryBlue,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                if (onPressed != null) onPressed();
              },
              child: Text(
                buttonText,
                style: const TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontWeight: FontWeight.w600,
                  fontSize: 15,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleSavePassword() async {
    final newPassword = _newPasswordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      _showM3Dialog(
        title: 'Gagal',
        message: 'Password Baru dan Konfirmasi Password wajib diisi.',
      );
      return;
    }

    if (newPassword.length < 8) {
      _showM3Dialog(
        title: 'Gagal',
        message: 'Password minimal 8 karakter.',
      );
      return;
    }

    if (newPassword != confirmPassword) {
      _showM3Dialog(
        title: 'Gagal',
        message: 'Konfirmasi Password tidak cocok.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = AuthRepository();
      final response = await repo.resetPassword(widget.email, widget.resetToken, newPassword);
      if (!mounted) return;
      if (response.success) {
        _showM3Dialog(
          title: 'Berhasil',
          message: 'Password berhasil diperbarui.',
          buttonText: 'Kembali ke Login',
          barrierDismissible: false,
          onPressed: () {
            Navigator.pushNamedAndRemoveUntil(
              context,
              AppRoutes.login,
              (route) => false,
              arguments: widget.email,
            );
          },
        );
      } else {
        _showM3Dialog(
          title: 'Gagal',
          message: response.message.isNotEmpty ? response.message : 'Gagal memperbarui password.',
        );
      }
    } catch (e) {
      if (!mounted) return;
      final errorStr = e.toString().replaceAll('Exception: ', '');
      final lowerErr = errorStr.toLowerCase();
      if (lowerErr.contains('socket') || lowerErr.contains('network') || lowerErr.contains('koneksi') || lowerErr.contains('connection')) {
        _showM3Dialog(
          title: 'Terjadi Kesalahan',
          message: 'Periksa koneksi internet Anda lalu coba lagi.',
        );
      } else {
        _showM3Dialog(
          title: 'Terjadi Kesalahan',
          message: errorStr,
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_rounded,
            color: AppColors.textDark,
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 12),
              const Text(
                'Buat Password Baru',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 26,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Kata sandi baru Anda harus unik dan minimal terdiri dari 8 karakter untuk menjaga keamanan akun Anda.',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: AppColors.textSoft,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 32),

              const Text(
                'Password Baru',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              AuthTextField(
                controller: _newPasswordController,
                hintText: 'Minimal 8 karakter',
                prefixIcon: Icons.lock_outline_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 20),

              const Text(
                'Konfirmasi Password',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textDark,
                ),
              ),
              const SizedBox(height: 8),
              AuthTextField(
                controller: _confirmPasswordController,
                hintText: 'Ulangi password baru',
                prefixIcon: Icons.lock_reset_rounded,
                isPassword: true,
              ),
              const SizedBox(height: 40),

              PrimaryButton(
                text: 'Simpan Password Baru',
                onPressed: _isLoading ? null : _handleSavePassword,
                isLoading: _isLoading,
                isGreen: false,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
