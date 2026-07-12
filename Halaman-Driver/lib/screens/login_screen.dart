import 'package:flutter/material.dart';
import '../services/auth_service.dart';

const _primary = Color(0xFF006D36);
const _mint = Color(0xFF4ADE80);
const _bg = Color(0xFFF9FAFB);

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _authService = AuthService();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _obscurePassword = true;

  void _showAlertDialog({
    required String title,
    required String description,
    required IconData icon,
    required Color iconColor,
  }) {
    if (!mounted) return;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          icon: Icon(icon, color: iconColor, size: 48),
          title: Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            textAlign: TextAlign.center,
          ),
          content: Text(
            description,
            style: const TextStyle(fontSize: 14, color: Colors.black87),
            textAlign: TextAlign.center,
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: iconColor,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text('Mengerti', style: TextStyle(fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<void> _login() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text;

    if (username.isEmpty) {
      _showAlertDialog(
        title: 'Username belum diisi',
        description: 'Silakan masukkan Username atau Nomor HP.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
      return;
    }

    if (password.isEmpty) {
      _showAlertDialog(
        title: 'Password belum diisi',
        description: 'Silakan masukkan password akun Anda.',
        icon: Icons.error_outline,
        iconColor: Colors.red,
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final response = await _authService.login(username, password);

    setState(() {
      _isLoading = false;
    });

    if (!mounted) return;

    if (response.success && response.data != null) {
      Navigator.of(context).pushReplacementNamed('/dashboard');
    } else {
      final message = response.message.toLowerCase();
      final statusCode = response.statusCode;

      if (statusCode == 404 || message.contains('tidak ditemukan')) {
        _showAlertDialog(
          title: 'Akun Driver tidak ditemukan.',
          description: 'Pastikan akun telah dibuat oleh Admin.',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      } else if (statusCode == 401 || message.contains('password salah') || message.contains('salah')) {
        _showAlertDialog(
          title: 'Password salah.',
          description: 'Kata sandi yang Anda masukkan tidak sesuai.',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      } else if (statusCode == 403 && message.contains('aktif')) {
        _showAlertDialog(
          title: 'Akun Driver belum aktif.',
          description: 'Silakan hubungi Admin.',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      } else if (statusCode == 500 || message.contains('koneksi') || message.contains('timeout') || message.contains('server')) {
        _showAlertDialog(
          title: 'Tidak dapat terhubung ke server.',
          description: 'Periksa koneksi internet Anda atau coba sesaat lagi.',
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      } else {
        _showAlertDialog(
          title: 'Login Gagal',
          description: response.message,
          icon: Icons.error_outline,
          iconColor: Colors.red,
        );
      }
    }
  }

  void _showForgotPasswordInfo() {
    _showAlertDialog(
      title: 'Lupa Password?',
      description: 'Untuk keamanan sistem, perubahan atau reset password Driver hanya dapat dilakukan oleh Web Admin. Silakan hubungi Admin kantor.',
      icon: Icons.info_outline,
      iconColor: Colors.blue,
    );
  }

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 60),
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: _mint.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.local_shipping,
                      size: 64,
                      color: _primary,
                    ),
                  ),
                ),
                const SizedBox(height: 32),
                const Text(
                  'Selamat Datang',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: _primary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Masuk ke akun driver Anda',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 48),
                TextField(
                  controller: _usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username atau Nomor HP',
                    prefixIcon: const Icon(
                      Icons.person_outline,
                      color: _primary,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _passwordController,
                  obscureText: _obscurePassword,
                  decoration: InputDecoration(
                    labelText: 'Password',
                    prefixIcon: const Icon(Icons.lock_outline, color: _primary),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: const BorderSide(color: _primary, width: 2),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Align(
                  alignment: Alignment.centerRight,
                  child: TextButton(
                    onPressed: _showForgotPasswordInfo,
                    style: TextButton.styleFrom(
                      foregroundColor: _primary,
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    ),
                    child: const Text(
                      'Lupa Password?',
                      style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                ElevatedButton(
                  onPressed: _isLoading ? null : _login,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child:
                      _isLoading
                          ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                          : const Text(
                            'Masuk',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
