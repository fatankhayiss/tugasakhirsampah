import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/repositories/auth_repository.dart';
import '../../../core/navigation/app_dialog_transitions.dart';
import '../../../shared/widgets/primary_button.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({super.key, required this.email});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    6,
    (_) => TextEditingController(),
  );

  Timer? _timer;
  int _remainingSeconds = 300;
  bool _canResend = false;
  bool _isLoading = false;
  bool _isResending = false;

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  @override
  void dispose() {
    _timer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _startCountdown() {
    _timer?.cancel();
    setState(() {
      _remainingSeconds = 300;
      _canResend = false;
    });
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) return;
      if (_remainingSeconds > 0) {
        setState(() => _remainingSeconds--);
      } else {
        timer.cancel();
        setState(() => _canResend = true);
      }
    });
  }

  String get _formattedTime {
    final minutes = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final seconds = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$minutes:$seconds';
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 5) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
    // Auto verify if 6 digits entered
    final code = _controllers.map((c) => c.text).join();
    if (code.length == 6) {
      _focusNodes[index].unfocus();
    }
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

  Future<void> _handleResend() async {
    if (!_canResend || _isResending) return;
    setState(() => _isResending = true);
    try {
      final repo = AuthRepository();
      final response = await repo.forgotPassword(widget.email);
      if (!mounted) return;
      if (response.success) {
        _startCountdown();
        _showM3Dialog(
          title: 'Berhasil',
          message: 'Kode OTP baru telah dikirim ke email Anda.',
        );
      } else {
        _showM3Dialog(
          title: 'Gagal Mengirim OTP',
          message: response.message.isNotEmpty ? response.message : 'Gagal mengirim ulang kode OTP.',
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
          title: 'Gagal Mengirim OTP',
          message: errorStr,
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  Future<void> _handleVerifyOtp() async {
    final code = _controllers.map((c) => c.text).join();
    if (code.length < 6) {
      _showM3Dialog(
        title: 'Peringatan',
        message: 'Harap masukkan 6 digit kode verifikasi.',
      );
      return;
    }
    setState(() => _isLoading = true);
    try {
      final repo = AuthRepository();
      final response = await repo.verifyOtp(widget.email, code);
      if (!mounted) return;
      if (response.success) {
        final resetToken = (response.data != null && response.data is Map)
            ? (response.data['reset_token'] ?? '')
            : '';
        _showM3Dialog(
          title: 'Berhasil',
          message: 'Kode OTP berhasil diverifikasi.',
          buttonText: 'Lanjut',
          barrierDismissible: false,
          onPressed: () {
            Navigator.pushReplacementNamed(
              context,
              AppRoutes.resetPassword,
              arguments: {
                'email': widget.email,
                'reset_token': resetToken.toString(),
              },
            );
          },
        );
      } else {
        final errorMsg = response.message;
        final isExpired = (response.data is Map && response.data['expired'] == true) ||
            errorMsg.toLowerCase().contains('kedaluwarsa');
        if (isExpired) {
          setState(() {
            _canResend = true;
            _remainingSeconds = 0;
            _timer?.cancel();
          });
          _showM3Dialog(
            title: 'Kode Kedaluwarsa',
            message: 'Kode OTP telah habis masa berlaku. Silakan kirim ulang OTP.',
          );
        } else {
          _showM3Dialog(
            title: 'Kode OTP Salah',
            message: errorMsg.isNotEmpty && !errorMsg.toLowerCase().contains('tidak valid')
                ? errorMsg
                : 'Kode OTP yang Anda masukkan tidak valid.',
          );
        }
      }
    } catch (e) {
      if (!mounted) return;
      final errorMsg = e.toString().replaceAll('Exception: ', '');
      final lowerErr = errorMsg.toLowerCase();
      if (lowerErr.contains('kedaluwarsa')) {
        setState(() {
          _canResend = true;
          _remainingSeconds = 0;
          _timer?.cancel();
        });
        _showM3Dialog(
          title: 'Kode Kedaluwarsa',
          message: 'Kode OTP telah habis masa berlaku. Silakan kirim ulang OTP.',
        );
      } else if (lowerErr.contains('socket') || lowerErr.contains('network') || lowerErr.contains('koneksi') || lowerErr.contains('connection')) {
        _showM3Dialog(
          title: 'Terjadi Kesalahan',
          message: 'Periksa koneksi internet Anda lalu coba lagi.',
        );
      } else {
        _showM3Dialog(
          title: 'Kode OTP Salah',
          message: errorMsg.isNotEmpty && !errorMsg.toLowerCase().contains('tidak valid')
              ? errorMsg
              : 'Kode OTP yang Anda masukkan tidak valid.',
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
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 16),
              Container(
                width: 64,
                height: 64,
                decoration: const BoxDecoration(
                  color: AppColors.softBlue,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.mark_email_read_outlined,
                  color: AppColors.primaryBlue,
                  size: 32,
                ),
              ),
              const SizedBox(height: 24),
              const Text(
                'Verifikasi Kode OTP',
                style: TextStyle(
                  fontFamily: 'Plus Jakarta Sans',
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: AppColors.textDark,
                  letterSpacing: -0.5,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontSize: 14,
                    color: AppColors.textSoft,
                    height: 1.5,
                  ),
                  children: [
                    const TextSpan(text: 'Masukkan 6 digit kode verifikasi yang telah dikirimkan ke email\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        color: AppColors.textDark,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 36),

              // 6-digit OTP Inputs (Focus styling uses AppColors.primaryBlue)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(6, (index) {
                  return Expanded(
                    child: Container(
                      height: 54,
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: _focusNodes[index].hasFocus
                              ? AppColors.primaryBlue
                              : AppColors.border,
                          width: _focusNodes[index].hasFocus ? 1.8 : 1.0,
                        ),
                        boxShadow: _focusNodes[index].hasFocus
                            ? [
                                BoxShadow(
                                  color: AppColors.primaryBlue.withValues(alpha: 0.1),
                                  spreadRadius: 2,
                                  blurRadius: 4,
                                ),
                              ]
                            : [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.02),
                                  blurRadius: 4,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                      ),
                      child: Center(
                        child: TextField(
                          controller: _controllers[index],
                          focusNode: _focusNodes[index],
                          keyboardType: TextInputType.number,
                          textAlign: TextAlign.center,
                          maxLength: 1,
                          style: const TextStyle(
                            fontFamily: 'Plus Jakarta Sans',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: AppColors.textDark,
                          ),
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          decoration: const InputDecoration(
                            counterText: '',
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (value) => _onChanged(value, index),
                          onTap: () {
                            _controllers[index].selection = TextSelection(
                              baseOffset: 0,
                              extentOffset: _controllers[index].text.length,
                            );
                          },
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Countdown Timer & Resend Button (Styled using primaryBlue)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.timer_outlined, size: 18, color: AppColors.textSoft),
                  const SizedBox(width: 6),
                  Text(
                    _formattedTime,
                    style: TextStyle(
                      fontFamily: 'Plus Jakarta Sans',
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                      color: _remainingSeconds > 0 ? AppColors.primaryBlue : AppColors.textSoft,
                    ),
                  ),
                  const SizedBox(width: 16),
                  TextButton(
                    onPressed: _canResend && !_isResending ? _handleResend : null,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: _isResending
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryBlue),
                          )
                        : Text(
                            'Kirim Ulang OTP',
                            style: TextStyle(
                              fontFamily: 'Plus Jakarta Sans',
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: _canResend ? AppColors.primaryBlue : AppColors.border,
                            ),
                          ),
                  ),
                ],
              ),

              const SizedBox(height: 48),

              // Verify Button enforced to Blue via isGreen: false
              PrimaryButton(
                text: 'Verifikasi OTP',
                onPressed: _isLoading ? null : _handleVerifyOtp,
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
