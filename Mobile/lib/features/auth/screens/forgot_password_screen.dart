import 'package:flutter/material.dart';
import '../widgets/social_login_button.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'verification_code_screen.dart';
import '../../../core/navigation/app_page_transitions.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleReset() {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Masukkan email terlebih dahulu')),
      );
      return;
    }
    Navigator.push(
      context,
      CustomPageRoute(
        page: VerificationCodeScreen(email: email),
      ),
    );
  }

  void _handleSocialLogin(String provider) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('Login with $provider')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9), // surface-lowest / surface
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Color(0xFF1B1C1C)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Forgot Password',
          style: TextStyle(
            color: Color(0xFF1B1C1C),
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        titleSpacing: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 20.0,
              vertical: 24.0,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title Section
                const Text(
                  'Lupa Password',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF1B1C1C),
                    letterSpacing: -0.02,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masukkan email akunmu dan kami akan mengirimkan kode untuk reset password.',
                  style: TextStyle(
                    fontSize: 14,
                    height: 1.4,
                    color: Color(0xFF5D5F5F),
                  ),
                ),
                const SizedBox(height: 32),

                // Form Section
                const Text(
                  'Email',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF1B1C1C),
                  ),
                ),
                const SizedBox(height: 8),
                Container(
                  height: 52,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(
                      color: const Color(0xFFC1C6D7),
                    ), // outline-variant
                  ),
                  child: TextField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      hintText: 'name@email.com',
                      hintStyle: TextStyle(
                        color: Color(0xFF727786), // outline color
                        fontSize: 14,
                      ),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.symmetric(horizontal: 16),
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: _handleReset,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1677FF), // primary
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Kirim Kode',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // Footer Link
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Sudah ingat password? ',
                      style: TextStyle(fontSize: 14, color: Color(0xFF5D5F5F)),
                    ),
                    GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: const Text(
                        'Login',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1677FF),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Divider
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(
                          0xFFE3E2E2,
                        ), // surface-container-highest
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16.0),
                      child: Text(
                        'Or continue with',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          color: Color(0xFF5D5F5F),
                        ),
                      ),
                    ),
                    Expanded(
                      child: Container(
                        height: 1,
                        color: const Color(0xFFE3E2E2),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // Social Login Buttons
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SocialLoginButton(
                      icon: FontAwesomeIcons.google,
                      iconColor: Colors.redAccent,
                      onPressed: () => _handleSocialLogin('Google'),
                    ),
                    const SizedBox(width: 24),
                    SocialLoginButton(
                      icon: FontAwesomeIcons.apple,
                      iconColor: Colors.black87,
                      onPressed: () => _handleSocialLogin('Apple'),
                    ),
                    const SizedBox(width: 24),
                    SocialLoginButton(
                      icon: FontAwesomeIcons.facebookF,
                      iconColor: const Color(0xFF1877F2),
                      onPressed: () => _handleSocialLogin('Facebook'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}




