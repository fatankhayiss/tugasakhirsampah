import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;

  const VerificationCodeScreen({super.key, required this.email});

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  final List<FocusNode> _focusNodes = List.generate(4, (_) => FocusNode());
  final List<TextEditingController> _controllers = List.generate(
    4,
    (_) => TextEditingController(),
  );

  @override
  void dispose() {
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void _onChanged(String value, int index) {
    if (value.isNotEmpty && index < 3) {
      _focusNodes[index + 1].requestFocus();
    } else if (value.isEmpty && index > 0) {
      _focusNodes[index - 1].requestFocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFAF9F9), // surface
      appBar: AppBar(
        backgroundColor: const Color(0xFFFAF9F9),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back,
            color: Color(0xFF1B1C1C),
            size: 24,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              const SizedBox(
                height: 48,
              ), // pt-24 roughly translated relative to AppBar
              // Text Content
              const Text(
                'Enter confirmation code',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1B1C1C), // on-surface
                  letterSpacing: -0.01,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              RichText(
                textAlign: TextAlign.center,
                text: TextSpan(
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF5D5F5F), // secondary
                    fontFamily: 'Inter',
                  ),
                  children: [
                    const TextSpan(text: 'A 4-digit code was sent to\n'),
                    TextSpan(
                      text: widget.email,
                      style: const TextStyle(
                        color: Color(0xFF1B1C1C),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Verification Code Inputs
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(4, (index) {
                  return Container(
                    width: 64,
                    height: 64,
                    margin: const EdgeInsets.symmetric(horizontal: 8),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(24),
                      border: Border.all(
                        color:
                            _focusNodes[index].hasFocus
                                ? const Color(0xFF0057C2) // primary
                                : const Color(0xFFC1C6D7), // outline-variant
                      ),
                      boxShadow:
                          _focusNodes[index].hasFocus
                              ? [
                                BoxShadow(
                                  color: const Color(
                                    0xFF0057C2,
                                  ).withValues(alpha: 0.04),
                                  spreadRadius: 2, // focus ring
                                ),
                              ]
                              : [],
                    ),
                    child: Center(
                      child: TextField(
                        controller: _controllers[index],
                        focusNode: _focusNodes[index],
                        keyboardType: TextInputType.number,
                        textAlign: TextAlign.center,
                        maxLength: 1,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFF1B1C1C),
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
                          // select all when tapped for easy replacement
                          _controllers[index].selection = TextSelection(
                            baseOffset: 0,
                            extentOffset: _controllers[index].text.length,
                          );
                        },
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: 32),

              // Resend Link
              TextButton(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Kode telah dikirim ulang')),
                  );
                },
                style: TextButton.styleFrom(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(0, 0),
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
                child: const Text(
                  'Resend code',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: Color(0xFF0057C2), // primary
                  ),
                ),
              ),

              const Spacer(),

              // Fixed Action Area / Continue Button
              Padding(
                padding: const EdgeInsets.only(bottom: 32.0),
                child: SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton(
                    onPressed: () {
                      String code = _controllers.map((c) => c.text).join();
                      if (code.length == 4) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Kode dikonfirmasi: $code')),
                        );
                        // Navigasi ke halaman buat password baru / home sesuai alur Anda
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Masukkan 4 digit kode'),
                          ),
                        );
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0057C2), // primary
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(24),
                      ),
                      elevation: 0,
                    ),
                    child: const Text(
                      'Continue',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


