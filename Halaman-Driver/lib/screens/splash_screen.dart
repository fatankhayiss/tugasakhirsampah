import 'dart:async';

import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _fadeAnim = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();

    // Simulate loading, then check auth status.
    Timer(const Duration(seconds: 3), () async {
      if (!mounted) return;
      final authService = AuthService();
      final isLoggedIn = await authService.isLoggedIn();
      if (!mounted) return;
      if (isLoggedIn) {
        Navigator.of(context).pushReplacementNamed('/dashboard');
      } else {
        Navigator.of(context).pushReplacementNamed('/login');
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      backgroundColor: const Color(0xFF4ADE80), // Mint green from design
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  // Top content (logo + texts)
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 16,
                    ),
                    child: Column(
                      children: [
                        const Spacer(flex: 1),
                        Center(
                          child: Image.asset(
                            'assets/splash/logo.png',
                            width: 96,
                            height: 96,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'iTrashy',
                          textAlign: TextAlign.center,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 22,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Text(
                            'Smart Waste Management Made Easy',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                        const Spacer(flex: 2),
                      ],
                    ),
                  ),

                  // Full-width illustration anchored to bottom and taking half the screen height
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 0,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: constraints.maxHeight * 0.5,
                      child: Image.asset(
                        'assets/splash/illustration.png',
                        fit: BoxFit.fitWidth,
                        alignment: Alignment.bottomCenter,
                      ),
                    ),
                  ),

                  // Progress indicator above the bottom edge
                  Positioned(
                    bottom: constraints.maxHeight * 0.06,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation(Colors.white),
                      ),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
