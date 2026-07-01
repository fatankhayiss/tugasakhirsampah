import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:mobile_user/core/repositories/auth_repository.dart';
import '../../../core/constants/app_colors.dart';
import '../widgets/social_login_button.dart';
import '../../../core/routes/app_routes.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
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
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final password = _passwordController.text;
    final confirmPassword = _confirmPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || confirmPassword.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Semua field wajib diisi')),
      );
      return;
    }

    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Password dan konfirmasi password tidak cocok')),
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final repo = AuthRepository();
      await repo.register(name, email, password);
      await repo.logout(); // Hapus auto-login agar user terpaksa login manual
      
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registrasi berhasil! Silakan login.'),
          backgroundColor: AppColors.primary,
        ),
      );
      Navigator.pushReplacementNamed(context, AppRoutes.login, arguments: email);
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll('Exception: ', '')),
          backgroundColor: Colors.redAccent,
        ),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleSocialLogin(String provider) {
    // TODO: Implement social login
    debugPrint('Social Login: $provider');
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
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  // Title
                  Text(
                    content.title,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textDark,
                      letterSpacing: -0.5,
                    ),
                  ),
                  const SizedBox(height: 12),
                  // Subtitle
                  Text(
                    content.subtitle,
                    style: const TextStyle(
                      fontSize: 15,
                      color: Colors.black54,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 36),

                  // Name Field
                  const Text(
                    'Nama',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  _EcoTextField(
                    controller: _nameController,
                    hintText: content.namePlaceholder,
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
                    onTapDown: (_agreedToTerms && !_isLoading) ? (_) => setState(() => _isRegisterPressed = true) : null,
                    onTapUp: (_agreedToTerms && !_isLoading) ? (_) {
                      setState(() => _isRegisterPressed = false);
                      _handleRegister();
                    } : null,
                    onTapCancel: () => setState(() => _isRegisterPressed = false),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      transform: Matrix4.identity()..scale(_isRegisterPressed ? 0.95 : 1.0),
                      transformAlignment: Alignment.center,
                      width: double.infinity,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: (_agreedToTerms && !_isLoading)
                            ? const LinearGradient(
                                colors: [AppColors.primaryBlue, AppColors.secondaryBlue],
                              )
                            : LinearGradient(
                                colors: [Colors.grey[300]!, Colors.grey[300]!],
                              ),
                        borderRadius: BorderRadius.circular(24),
                        boxShadow: (_agreedToTerms && !_isLoading)
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.04),
                                  blurRadius: 18,
                                  offset: const Offset(0, 6),
                                )
                              ]
                            : [],
                      ),
                      alignment: Alignment.center,
                      child: _isLoading 
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
                              color: (_agreedToTerms && !_isLoading) ? Colors.white : Colors.grey[500],
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
                              pageBuilder: (context, animation, secondaryAnimation) => const LoginScreen(),
                              transitionsBuilder: (context, animation, secondaryAnimation, child) {
                                return FadeTransition(opacity: animation, child: child);
                              },
                            ),
                          );
                        },
                        borderRadius: BorderRadius.circular(4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
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
                      Expanded(child: Divider(color: Colors.grey[200], thickness: 1.5)),
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
                      Expanded(child: Divider(color: Colors.grey[200], thickness: 1.5)),
                    ],
                  ),
                  const SizedBox(height: 32),

                  // Social Buttons
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      SocialLoginButton(
                        icon: FontAwesomeIcons.google,
                        iconColor: Colors.redAccent,
                        onPressed: () => _handleSocialLogin('Google'),
                      ),
                      const SizedBox(width: 20),
                      SocialLoginButton(
                        icon: FontAwesomeIcons.apple,
                        iconColor: Colors.black87,
                        onPressed: () => _handleSocialLogin('Apple'),
                      ),
                      const SizedBox(width: 20),
                      SocialLoginButton(
                        icon: FontAwesomeIcons.facebookF,
                        iconColor: const Color(0xFF1877F2),
                        onPressed: () => _handleSocialLogin('Facebook'),
                      ),
                    ],
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

  const _EcoTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
    this.obscureText = false,
    this.onToggleObscure,
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
        boxShadow: _isFocused
            ? [
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                )
              ]
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.04),
                  blurRadius: 18,
                  offset: const Offset(0, 6),
                )
              ],
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        keyboardType: widget.keyboardType,
        obscureText: widget.obscureText,
        style: const TextStyle(fontSize: 15, color: AppColors.textDark),
        decoration: InputDecoration(
          hintText: widget.hintText,
          hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
          suffixIcon: widget.onToggleObscure != null
              ? IconButton(
                  icon: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    transitionBuilder: (child, anim) => RotationTransition(
                      turns: child.key == const ValueKey('icon1')
                          ? Tween<double>(begin: 1, end: 1).animate(anim)
                          : Tween<double>(begin: 1, end: 1).animate(anim),
                      child: FadeTransition(opacity: anim, child: child),
                    ),
                    child: Icon(
                      widget.obscureText ? Icons.visibility_off_outlined : Icons.visibility_outlined,
                      key: ValueKey(widget.obscureText ? 'icon1' : 'icon2'),
                      color: _isFocused ? AppColors.primary : Colors.grey[400],
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





