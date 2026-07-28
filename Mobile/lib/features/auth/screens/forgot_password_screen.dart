import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/navigation/app_dialog_transitions.dart';
import '../../../shared/widgets/scale_tap.dart';
import '../../../shared/widgets/primary_button.dart';
import '../widgets/auth_textfield.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  bool _isLoading = false;
  bool _isSendingEmail = false;
  final TextEditingController _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
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

  Future<void> _handleSendRecoveryEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      _showM3Dialog(
        title: 'Gagal',
        message: 'Harap masukkan alamat email pemulihan Anda yang terdaftar.',
      );
      return;
    }

    if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(email)) {
      _showM3Dialog(
        title: 'Gagal',
        message: 'Format alamat email yang Anda masukkan tidak valid.',
      );
      return;
    }

    if (_isSendingEmail) return;
    setState(() => _isSendingEmail = true);

    try {
      final repo = AuthRepository();
      final response = await repo.forgotPassword(email);
      if (!mounted) return;

      final isGoogleAccount = (response.data is Map && response.data['code'] == 'GOOGLE_ACCOUNT') ||
          response.message.toLowerCase().contains('google sign-in');

      if (isGoogleAccount) {
        AppDialogTransitions.showFadeScaleDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.transparent,
            titlePadding: const EdgeInsets.fromLTRB(24, 24, 24, 8),
            contentPadding: const EdgeInsets.fromLTRB(24, 8, 24, 24),
            actionsPadding: const EdgeInsets.fromLTRB(24, 0, 24, 20),
            title: const Text(
              'Google Account Detected',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontWeight: FontWeight.w700,
                fontSize: 18,
                color: AppColors.textDark,
              ),
            ),
            content: const Text(
              'This account uses Google Sign-In. Please continue using Google to sign in.',
              style: TextStyle(
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
                    _handleGoogleSignIn();
                  },
                  child: const Text(
                    'Sign in with Google',
                    style: TextStyle(
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
      } else if (response.success) {
        if (!mounted) return;
        _showM3Dialog(
          title: 'Berhasil',
          message: 'Kode OTP berhasil dikirim ke email Anda.',
          buttonText: 'OK',
          barrierDismissible: false,
          onPressed: () {
            Navigator.pushNamed(context, AppRoutes.verification, arguments: email);
          },
        );
      } else {
        final lowerMsg = response.message.toLowerCase();
        if (lowerMsg.contains('tidak ditemukan')) {
          _showM3Dialog(
            title: 'Gagal',
            message: 'Email tidak ditemukan.',
          );
        } else if (lowerMsg.contains('smtp') || lowerMsg.contains('gagal mengirim')) {
          _showM3Dialog(
            title: 'Gagal Mengirim OTP',
            message: response.message,
          );
        } else {
          _showM3Dialog(
            title: 'Gagal',
            message: response.message.isNotEmpty ? response.message : 'Gagal mengirimkan instruksi reset password.',
          );
        }
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
      if (mounted) {
        setState(() => _isSendingEmail = false);
      }
    }
  }

  Future<void> _handleGoogleSignIn() async {
    if (_isLoading) return;
    setState(() => _isLoading = true);
    try {
      final repo = AuthRepository();
      final userData = await repo.loginWithGoogle();
      if (!mounted) return;
      if (userData != null) {
        Navigator.pushReplacementNamed(context, AppRoutes.main);
      }
    } catch (e) {
      if (!mounted) return;
      _showM3Dialog(
        title: 'Peringatan',
        message: e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        leading: ScaleTap(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pop(context);
          },
          scaleDown: 0.98,
          duration: const Duration(milliseconds: 160),
          executeOnTap: false,
          child: Material(
            color: Colors.transparent,
            shape: const CircleBorder(),
            child: InkWell(
              onTap: () {
                HapticFeedback.lightImpact();
                Navigator.pop(context);
              },
              customBorder: const CircleBorder(),
              child: const Center(
                child: Icon(Icons.arrow_back, color: AppColors.textDark),
              ),
            ),
          ),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            fontFamily: 'Plus Jakarta Sans',
            color: AppColors.textDark,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 32.0,
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Title Section
                const Text(
                  'Lupa Password',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: AppColors.textDark,
                    letterSpacing: -0.02,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Centered Description
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Masukkan alamat email Anda yang terdaftar untuk menerima kode OTP pemulihan kata sandi.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSoft,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(height: 28),

                // Email Pemulihan Input Field
                AuthTextField(
                  controller: _emailController,
                  hintText: 'Email Pemulihan',
                  prefixIcon: Icons.email_outlined,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 20),

                // Primary Recovery Send Button (Blue color enforced via isGreen: false)
                PrimaryButton(
                  text: 'Kirim OTP',
                  onPressed: _handleSendRecoveryEmail,
                  isLoading: _isSendingEmail,
                  isGreen: false,
                ),
                const SizedBox(height: 28),

                // Divider ("dan baru masuk dengan google itu ditaruh bawah")
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Atau masuk dengan',
                        style: TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: AppColors.textSoft,
                        ),
                      ),
                    ),
                    Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                  ],
                ),
                const SizedBox(height: 28),

                // Google Primary Login Button placed below
                _buildGoogleRecoveryButton(),
                const SizedBox(height: 32),

                // Back to Login Link with touch feedback (Login using blue CTA color)
                _buildBackToLogin(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGoogleRecoveryButton() {
    final bool isDisabled = _isLoading;

    return ScaleTap(
      onTap: isDisabled ? null : _handleGoogleSignIn,
      scaleDown: 0.98,
      duration: const Duration(milliseconds: 160),
      executeOnTap: false,
      child: AnimatedPhysicalModel(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        shape: BoxShape.rectangle,
        borderRadius: BorderRadius.circular(24),
        elevation: 0,
        color: Colors.transparent,
        shadowColor: Colors.transparent,
        child: Container(
          width: double.infinity,
          height: 56,
          decoration: BoxDecoration(
            gradient: isDisabled && !_isLoading
                ? LinearGradient(
                    colors: [Colors.grey[300]!, Colors.grey[400]!],
                  )
                : const LinearGradient(
                    colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                  ),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(24),
            child: InkWell(
              onTap: isDisabled
                  ? null
                  : () {
                      HapticFeedback.lightImpact();
                      _handleGoogleSignIn();
                    },
              borderRadius: BorderRadius.circular(24),
              splashColor: Colors.white.withValues(alpha: 0.2),
              highlightColor: Colors.white.withValues(alpha: 0.1),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 250),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _isLoading
                        ? Row(
                            key: const ValueKey('loading'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              SizedBox(
                                width: 22,
                                height: 22,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Menghubungkan...',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          )
                        : Row(
                            key: const ValueKey('content'),
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              FaIcon(
                                FontAwesomeIcons.google,
                                color: Colors.white,
                                size: 20,
                              ),
                              SizedBox(width: 12),
                              Text(
                                'Masuk dengan Google',
                                style: TextStyle(
                                  fontFamily: 'Plus Jakarta Sans',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBackToLogin() {
    return ScaleTap(
      onTap: () => Navigator.pop(context),
      scaleDown: 0.96,
      duration: const Duration(milliseconds: 160),
      executeOnTap: false,
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          Navigator.pop(context);
        },
        behavior: HitTestBehavior.opaque,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: const [
              Text(
                'Sudah ingat password? ',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  color: AppColors.textSoft,
                ),
              ),
              Text(
                'Login',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryBlue,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

