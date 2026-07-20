import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_user/core/repositories/auth_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/navigation/app_dialog_transitions.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/repositories/auth_repository.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _usernameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _agreedToTerms = false;

  bool _isRegisterPressed = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _usernameController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _showAlertDialog(String title, String message) {
    AppDialogTransitions.showFadeScaleDialog(
      context: context,
      builder:
          (ctx) => AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: Color(0xFF1E293B),
              ),
            ),
            content: Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF64748B),
                height: 1.4,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    color: Color(0xFF43C97B),
                    fontWeight: FontWeight.w700,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
    );
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final username = _usernameController.text.trim();
    final noTelepon = _phoneController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty ||
        email.isEmpty ||
        username.isEmpty ||
        noTelepon.isEmpty ||
        password.isEmpty ||
        confirmPassword.isEmpty) {
      _showAlertDialog('Peringatan', 'Semua kolom wajib diisi.');
      return;
    }

    if (password != confirmPassword) {
      _showAlertDialog(
        'Password Tidak Cocok',
        'Password dan konfirmasi password tidak cocok.',
      );
      return;
    }

    if (!_agreedToTerms) {
      _showAlertDialog(
        'Peringatan',
        'Anda wajib menyetujui Ketentuan Layanan & Kebijakan Privasi.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = AuthRepository();
      await repo.register(
        name,
        email,
        password,
        username: username,
        noTelepon: noTelepon,
      );
      await repo.logout(); // Hapus auto-login agar user terpaksa login manual

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppColors.primaryBlue,
        ),
      );
      Navigator.pushReplacementNamed(
        context,
        AppRoutes.login,
        arguments: email,
      );
    } catch (e) {
      if (!mounted) return;
      _showAlertDialog(
        'Peringatan',
        e.toString().replaceAll('Exception: ', ''),
      );
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
      _showAlertDialog(
        'Peringatan',
        e.toString().replaceAll('Exception: ', ''),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final repo = AuthRepository();
    final content = repo.getRegisterContent();

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: EdgeInsets.symmetric(
              horizontal: (MediaQuery.of(context).size.width * 0.06).clamp(
                16.0,
                32.0,
              ),
              vertical: (MediaQuery.of(context).size.height * 0.02).clamp(
                12.0,
                24.0,
              ),
            ),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SizedBox(
                    height: (MediaQuery.of(context).size.height * 0.01).clamp(
                      4.0,
                      12.0,
                    ),
                  ),
                  // Title
                  Text(
                    content.title,
                    style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.width * 0.08)
                          .clamp(26.0, 34.0),
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  SizedBox(
                    height: (MediaQuery.of(context).size.height * 0.015).clamp(
                      8.0,
                      16.0,
                    ),
                  ),
                  // Subtitle
                  Text(
                    content.subtitle,
                    style: TextStyle(
                      fontSize: (MediaQuery.of(context).size.width * 0.038)
                          .clamp(13.0, 16.0),
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  SizedBox(
                    height: (MediaQuery.of(context).size.height * 0.035).clamp(
                      20.0,
                      36.0,
                    ),
                  ),

                  // Name Field
                  const Text(
                    'Nama Lengkap',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _EcoTextField(
                    controller: _nameController,
                    hintText: 'Masukkan nama lengkap',
                  ),
                  const SizedBox(height: 24),

                  // Username Field
                  const Text(
                    'Username',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _EcoTextField(
                    controller: _usernameController,
                    hintText: 'Masukkan username Anda',
                  ),
                  const SizedBox(height: 24),

                  // Email Field
                  const Text(
                    'Email',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _EcoTextField(
                    controller: _emailController,
                    hintText: content.emailPlaceholder,
                    keyboardType: TextInputType.emailAddress,
                  ),
                  const SizedBox(height: 24),

                  // Phone Number Field
                  const Text(
                    'Nomor HP',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _EcoTextField(
                    controller: _phoneController,
                    hintText: 'Masukkan nomor HP (08xxx / +62xxx)',
                    keyboardType: TextInputType.phone,
                  ),
                  const SizedBox(height: 24),

                  // Password Field
                  const Text(
                    'Password',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _EcoTextField(
                    controller: _passwordController,
                    hintText: content.passwordPlaceholder,
                    obscureText: _obscurePassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscurePassword = !_obscurePassword;
                      });
                    },
                  ),
                  const SizedBox(height: 24),

                  // Confirm Password Field
                  _EcoTextField(
                    controller: _confirmPasswordController,
                    hintText: content.confirmPasswordPlaceholder,
                    obscureText: _obscureConfirmPassword,
                    onToggleObscure: () {
                      setState(() {
                        _obscureConfirmPassword = !_obscureConfirmPassword;
                      });
                    },
                  ),
                  const SizedBox(height: 20),

                  // Terms Checkbox
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: 24,
                        height: 24,
                        child: Checkbox(
                          value: _agreedToTerms,
                          onChanged: (value) {
                            setState(() {
                              _agreedToTerms = value ?? false;
                            });
                          },
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                          activeColor: AppColors.primary,
                          side: const BorderSide(color: AppColors.border),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            Text(
                              ' ',
                              style: const TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                                height: 1.5,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Text(
                                content.termsLinkText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Text(
                              ' and the ',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                            InkWell(
                              onTap: () {},
                              child: Text(
                                content.privacyLinkText,
                                style: const TextStyle(
                                  fontSize: 13,
                                  color: AppColors.primary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            const Text(
                              '.',
                              style: TextStyle(
                                fontSize: 13,
                                color: Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Register Button
                  GestureDetector(
                    onTapDown:
                        (_agreedToTerms && !_isLoading)
                            ? (_) => setState(() => _isRegisterPressed = true)
                            : null,
                    onTapUp:
                        (_agreedToTerms && !_isLoading)
                            ? (_) {
                              setState(() => _isRegisterPressed = false);
                              _handleRegister();
                            }
                            : null,
                    onTapCancel:
                        () => setState(() => _isRegisterPressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform:
                          Matrix4.identity()..scaleByDouble(
                            _isRegisterPressed ? 0.95 : 1.0,
                            _isRegisterPressed ? 0.95 : 1.0,
                            1.0,
                            1.0,
                          ),
                      transformAlignment: Alignment.center,
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient:
                            (_agreedToTerms && !_isLoading)
                                ? const LinearGradient(
                                  colors: [
                                    AppColors.primaryBlue,
                                    AppColors.secondaryBlue,
                                  ],
                                )
                                : LinearGradient(
                                  colors: [
                                    Colors.grey[300]!,
                                    Colors.grey[300]!,
                                  ],
                                ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow:
                            (_agreedToTerms && !_isLoading)
                                ? [
                                  BoxShadow(
                                    color: AppColors.primaryBlue.withValues(
                                      alpha: 0.04,
                                    ),
                                    blurRadius: 18,
                                    offset: const Offset(0, 6),
                                  ),
                                ]
                                : [],
                      ),
                      alignment: Alignment.center,
                      child:
                          _isLoading
                              ? const SizedBox(
                                width: 24,
                                height: 24,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2.5,
                                ),
                              )
                              : Text(
                                content.registerButtonText,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color:
                                      (_agreedToTerms && !_isLoading)
                                          ? Colors.white
                                          : Colors.grey[500],
                                  letterSpacing: 0.5,
                                ),
                              ),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Login Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        content.hasAccountText,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black54,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(width: 4),
                      InkWell(
                        onTap: () {
                          Navigator.pushReplacement(
                            context,
                            PageRouteBuilder(
                              pageBuilder:
                                  (context, animation, secondaryAnimation) =>
                                      const LoginScreen(),
                              transitionsBuilder: (
                                context,
                                animation,
                                secondaryAnimation,
                                child,
                              ) {
                                return FadeTransition(
                                  opacity: animation,
                                  child: child,
                                );
                              },
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 4,
                            vertical: 2,
                          ),
                          child: Text(
                            content.loginLinkText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w700,
                              color: AppColors.primary,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 36),

                  // Divider
                  Row(
                    children: [
                      Expanded(
                        child: Divider(color: Colors.grey[200], thickness: 1.5),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          content.continueWithText,
                          style: TextStyle(
                            fontSize: 13,
                            color: Colors.grey[500],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                      Expanded(
                        child: Divider(color: Colors.grey[200], thickness: 1.5),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Social Buttons (Only Google)
                  SizedBox(
                    width: double.infinity,
                    height: 54,
                    child: OutlinedButton.icon(
                      onPressed: _isLoading ? null : _handleGoogleLogin,
                      icon: const FaIcon(
                        FontAwesomeIcons.google,
                        color: Color(0xFFEA4335),
                        size: 20,
                      ),
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
                        side: const BorderSide(
                          color: Color(0xFFE2E8F0),
                          width: 1.5,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                        elevation: 0,
                      ),
                    ),
                  ),
                  const SizedBox(height: 48),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _EcoTextField extends StatefulWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;
  final bool obscureText;
  final VoidCallback? onToggleObscure;
  final int maxLines;
  final int minLines;
  final IconData? prefixIcon;

  const _EcoTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.onToggleObscure,
    // ignore: unused_element_parameter
    this.maxLines = 1,
    // ignore: unused_element_parameter
    this.minLines = 1,
    // ignore: unused_element_parameter
    this.prefixIcon,
  });

  @override
  State<_EcoTextField> createState() => _EcoTextFieldState();
}

class _EcoTextFieldState extends State<_EcoTextField> {
  final FocusNode _focusNode = FocusNode();
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    _focusNode.addListener(() {
      setState(() {
        _isFocused = _focusNode.hasFocus;
      });
    });
  }

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: _isFocused ? AppColors.primary : AppColors.border,
          width: _isFocused ? 2 : 1,
        ),
        boxShadow:
            _isFocused
                ? [
                  BoxShadow(
                    color: AppColors.primary.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ]
                : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.04),
                    blurRadius: 18,
                    offset: const Offset(0, 6),
                  ),
                ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        maxLines: widget.obscureText ? 1 : widget.maxLines,
        minLines: widget.obscureText ? 1 : widget.minLines,
        style: const TextStyle(fontSize: 15, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 18,
          ),
          prefixIcon:
              widget.prefixIcon != null
                  ? Icon(
                    widget.prefixIcon,
                    color: _isFocused ? AppColors.primary : Colors.grey[400],
                    size: 20,
                  )
                  : null,
          suffixIcon:
              widget.onToggleObscure != null
                  ? IconButton(
                    icon: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 200),
                      transitionBuilder:
                          (child, anim) => RotationTransition(
                            turns:
                                child.key == const ValueKey('icon1')
                                    ? Tween<double>(
                                      begin: 1,
                                      end: 1,
                                    ).animate(anim)
                                    : Tween<double>(
                                      begin: 1,
                                      end: 1,
                                    ).animate(anim),
                            child: FadeTransition(opacity: anim, child: child),
                          ),
                      child: Icon(
                        widget.obscureText
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        key: ValueKey(widget.obscureText ? 'icon1' : 'icon2'),
                        color:
                            _isFocused ? AppColors.primary : Colors.grey[400],
                        size: 20,
                      ),
                    ),
                    onPressed: widget.onToggleObscure,
                  )
                  : null,
        ),
      ),
    );
  }
}
