import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/routes/app_routes.dart';
import '../widgets/auth_textfield.dart';
import '../../../shared/widgets/app_asset_image.dart';
import '../../../shared/widgets/primary_button.dart';
import '../../../shared/widgets/exit_app_dialog.dart';
import '../../../shared/widgets/scale_tap.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/navigation/app_dialog_transitions.dart';

class LoginScreen extends StatefulWidget {
  final String? initialEmail;
  const LoginScreen({super.key, this.initialEmail});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    if (widget.initialEmail != null) {
      _emailController.text = widget.initialEmail!;
    }
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _showAlertDialog(String title, String message) {
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: Color(0xFF1E293B)),
        ),
        content: Text(
          message,
          style: const TextStyle(fontSize: 14, color: Color(0xFF64748B), height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text(
              'OK',
              style: TextStyle(color: Color(0xFF43C97B), fontWeight: FontWeight.w700, fontSize: 15),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _handleLogin() async {
    final identifier = _emailController.text.trim();
    final password = _passwordController.text;

    if (identifier.isEmpty) {
      _showAlertDialog(
        'Peringatan',
        'Email, Username, atau Nomor Telepon wajib diisi.',
      );
      return;
    }
    if (password.isEmpty) {
      _showAlertDialog(
        'Peringatan',
        'Password wajib diisi.',
      );
      return;
    }

    String loginType = 'username';
    if (identifier.contains('@')) {
      loginType = 'email';
    } else if (RegExp(r'^[0-9+]+$').hasMatch(identifier)) {
      loginType = 'phone';
    }

    setState(() => _isLoading = true);

    try {
      final repo = AuthRepository();
      await repo.login(identifier, password, loginType: loginType);
      
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.main);
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      if (errorMsg.toLowerCase().contains('akun tidak ditemukan') || errorMsg.contains('404')) {
        _showAlertDialog('Akun tidak ditemukan', 'Periksa kembali Username atau Nomor HP Anda.');
      } else if (errorMsg.toLowerCase().contains('password salah') || errorMsg.contains('401')) {
        _showAlertDialog('Password salah', 'Password yang Anda masukkan tidak sesuai.');
      } else {
        _showAlertDialog('Peringatan', errorMsg);
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _handleGoogleLogin() async {
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
      _showAlertDialog('Peringatan', e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        ExitAppDialog.show(context);
      },
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Column(
          children: [
            _buildTopBanner(),
            Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (MediaQuery.of(context).size.width * 0.06).clamp(16.0, 32.0),
                vertical: (MediaQuery.of(context).size.height * 0.035).clamp(16.0, 32.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildWelcomeText(),
                  const SizedBox(height: 32),
                  _buildEmailField(),
                  const SizedBox(height: 20),
                  _buildPasswordField(),
                  const SizedBox(height: 12),
                  _buildForgotPassword(),
                  const SizedBox(height: 32),
                  _buildLoginButton(),
                  const SizedBox(height: 32),
                  _buildRegisterSection(),
                  const SizedBox(height: 32),
                  _buildDivider(),
                  const SizedBox(height: 24),
                  _buildSocialLogin(),
                ],
              ),
            ),
          ],
        ),
      ),
    ),
  );
}

  Widget _buildTopBanner() {
    final double bannerHeight = (MediaQuery.of(context).size.height * 0.33).clamp(180.0, 300.0);
    return Container(
      width: double.infinity,
      height: bannerHeight,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        child: Stack(
          fit: StackFit.expand,
          children: [
            const AppAssetImage(
              assetPath: AppImages.loginBanner,
              fit: BoxFit.cover,
            ),
            Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withValues(alpha: 0.04),
                    Colors.black.withValues(alpha: 0.04),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWelcomeText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Welcome!',
          style: TextStyle(
            fontSize: 32,
            fontWeight: FontWeight.w800,
            color: Color(0xFF1E293B),
            letterSpacing: -1,
          ),
        ),
        SizedBox(height: 8),
        Text(
          'Masuk untuk melanjutkan pengalaman ramah lingkunganmu.',
          style: TextStyle(fontSize: 15, color: Color(0xFF64748B), height: 1.5),
        ),
      ],
    );
  }

  Widget _buildEmailField() {
    return AuthTextField(
      controller: _emailController,
      hintText: 'Email / Username / Nomor Telepon',
      prefixIcon: Icons.person_outline_rounded,
      keyboardType: TextInputType.text,
    );
  }

  Widget _buildPasswordField() {
    return AuthTextField(
      controller: _passwordController,
      hintText: 'Password',
      prefixIcon: Icons.lock_outline_rounded,
      isPassword: true,
    );
  }

  Widget _buildForgotPassword() {
    return Align(
      alignment: Alignment.centerLeft,
      child: ScaleTap(
        onTap: () {
          Navigator.pushNamed(context, AppRoutes.forgotPassword);
        },
        scaleDown: 0.96,
        duration: const Duration(milliseconds: 160),
        executeOnTap: false,
        child: GestureDetector(
          onTap: () {
            HapticFeedback.lightImpact();
            Navigator.pushNamed(context, AppRoutes.forgotPassword);
          },
          behavior: HitTestBehavior.opaque,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 6.0),
            child: Text(
              'Lupa password?',
              style: TextStyle(
                fontFamily: 'Plus Jakarta Sans',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Color(0xFF43C97B),
                shadows: [],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoginButton() {
    return PrimaryButton(
      text: 'Login', 
      onPressed: _handleLogin,
      isLoading: _isLoading,
    );
  }

  Widget _buildRegisterSection() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text(
          'Belum punya akun? ',
          style: TextStyle(fontSize: 14, color: Color(0xFF64748B)),
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, AppRoutes.register);
          },
          child: const Text(
            'Daftar Sekarang',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: Color(0xFF43C97B),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDivider() {
    return Row(
      children: [
        Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 16.0),
          child: Text(
            'Atau lanjutkan dengan',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: Color(0xFF94A3B8),
            ),
          ),
        ),
        Expanded(child: Container(height: 1, color: const Color(0xFFE2E8F0))),
      ],
    );
  }

  Widget _buildSocialLogin() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleGoogleLogin,
        icon: const FaIcon(FontAwesomeIcons.google, color: Color(0xFFEA4335), size: 20),
        label: const Text(
          'Masuk dengan Google',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Color(0xFF1E293B),
          ),
        ),
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.white,
          side: const BorderSide(color: Color(0xFFE2E8F0), width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          elevation: 0,
        ),
      ),
    );
  }
}