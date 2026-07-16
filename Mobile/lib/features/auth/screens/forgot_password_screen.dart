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

  Future<void> _handleSendRecoveryEmail() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      AppDialogTransitions.showFadeScaleDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Peringatan',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textDark,
              shadows: [],
            ),
          ),
          content: const Text(
            'Harap masukkan alamat email pemulihan Anda yang terdaftar.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: AppColors.textSoft,
              height: 1.4,
              shadows: [],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  shadows: [],
                ),
              ),
            ),
          ],
        ),
      );
      return;
    }

    if (_isSendingEmail) return;
    setState(() => _isSendingEmail = true);

    try {
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      AppDialogTransitions.showFadeScaleDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Email Terkirim',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textDark,
              shadows: [],
            ),
          ),
          content: Text(
            'Instruksi dan link pemulihan kata sandi telah dikirimkan ke alamat email $email.',
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: AppColors.textSoft,
              height: 1.4,
              shadows: [],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                  shadows: [],
                ),
              ),
            ),
          ],
        ),
      );
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
      AppDialogTransitions.showFadeScaleDialog(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            'Peringatan',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontWeight: FontWeight.bold,
              fontSize: 18,
              color: AppColors.textDark,
            ),
          ),
          content: Text(
            e.toString().replaceAll('Exception: ', ''),
            style: const TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              color: AppColors.textSoft,
              height: 1.4,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text(
                'OK',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  color: AppColors.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 15,
                ),
              ),
            ),
          ],
        ),
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
                    shadows: [],
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 12),
                
                // Centered Description
                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    'Masukkan alamat email Anda yang terdaftar untuk menerima link atau instruksi pemulihan kata sandi.',
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 14,
                      height: 1.5,
                      color: AppColors.textSoft,
                      shadows: [],
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

                // Primary Recovery Send Button
                PrimaryButton(
                  text: 'Kirim Link Pemulihan',
                  onPressed: _handleSendRecoveryEmail,
                  isLoading: _isSendingEmail,
                ),
                const SizedBox(height: 28),

                // Divider ("dan baru masuk dengan google itu ditaruh bawah")
                Row(
                  children: [
                    Expanded(child: Divider(color: AppColors.border, thickness: 1)),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Atau masuk dengan',
                        style: const TextStyle(
                          fontFamily: 'Plus Jakarta Sans',
                          fontSize: 13,
                          color: AppColors.textSoft,
                          shadows: [],
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

                // Back to Login Link with touch feedback (no shadow, Login turned green)
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
                                  shadows: [],
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
                                  shadows: [],
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
                  shadows: [],
                ),
              ),
              Text(
                'Login',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primary,
                  shadows: [],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
