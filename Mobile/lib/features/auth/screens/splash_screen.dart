import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/routes/app_routes.dart';

/// Entry gate — checks onboarding flag, then routes with smooth fade.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with TickerProviderStateMixin {
  late final AnimationController _fadeController;
  late final AnimationController _pulseController;
  late final AnimationController _progressController;
  
  late final Animation<double> _fadeAnimation;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _pulseAnimation;

  final List<String> _loadingSteps = [
    'Preparing Application...',
    'Loading User Session...',
    'Synchronizing Data...',
    'Almost Ready...',
  ];
  int _currentStepIndex = 0;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat(reverse: true);
    _progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );
    _scaleAnimation = Tween<double>(begin: 0.9, end: 1.0).animate(
      CurvedAnimation(parent: _fadeController, curve: Curves.easeOutCubic),
    );
    _pulseAnimation = Tween<double>(begin: 0.98, end: 1.03).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _fadeController.forward();
    _progressController.forward();
    _runLoadingSequence();
  }

  Future<void> _runLoadingSequence() async {
    for (int i = 0; i < _loadingSteps.length; i++) {
      if (!mounted) return;
      setState(() {
        _currentStepIndex = i;
      });
      await Future.delayed(const Duration(milliseconds: 600));
    }

    if (!mounted) return;

    final prefs = await SharedPreferences.getInstance();
    final hasCompletedOnboarding = prefs.getBool('onboarding_completed') ?? false;

    if (!mounted) return;

    final targetRoute = hasCompletedOnboarding
        ? AppRoutes.login
        : AppRoutes.intro;

    Navigator.pushReplacementNamed(context, targetRoute);
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _pulseController.dispose();
    _progressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.primary.withValues(alpha: 0.88),
            ],
          ),
        ),
        child: SafeArea(
          child: LayoutBuilder(
            builder: (context, constraints) {
              final double maxLogoSize = (constraints.maxWidth * 0.28).clamp(80.0, 140.0);

              return FadeTransition(
                opacity: _fadeAnimation,
                child: ScaleTransition(
                  scale: _scaleAnimation,
                  child: Column(
                    children: [
                      const Spacer(flex: 3),
                      
                      // Animated Logo
                      ScaleTransition(
                        scale: _pulseAnimation,
                        child: Container(
                          padding: const EdgeInsets.all(24),
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.14),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.1),
                                blurRadius: 24,
                                offset: const Offset(0, 10),
                              ),
                            ],
                          ),
                          child: Image.asset(
                            AppImages.logoItrashy1,
                            width: maxLogoSize,
                            height: maxLogoSize,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),

                      // App Name
                      FittedBox(
                        fit: BoxFit.scaleDown,
                        child: Text(
                          'iTrashy',
                          style: TextStyle(
                            fontSize: (constraints.maxWidth * 0.08).clamp(28.0, 42.0),
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            letterSpacing: -0.5,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Tagline
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 24),
                        child: Text(
                          'Smart Waste Management',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: (constraints.maxWidth * 0.038).clamp(13.0, 16.0),
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withValues(alpha: 0.8),
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),

                      const Spacer(flex: 3),

                      // Sequence Text & Progress Animation
                      Padding(
                        padding: EdgeInsets.symmetric(
                          horizontal: (constraints.maxWidth * 0.15).clamp(32.0, 120.0),
                        ),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            AnimatedSwitcher(
                              duration: const Duration(milliseconds: 250),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              child: Text(
                                _loadingSteps[_currentStepIndex],
                                key: ValueKey<int>(_currentStepIndex),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: (constraints.maxWidth * 0.035).clamp(12.0, 15.0),
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white.withValues(alpha: 0.9),
                                ),
                              ),
                            ),
                            const SizedBox(height: 14),
                            AnimatedBuilder(
                              animation: _progressController,
                              builder: (context, _) {
                                return ClipRRect(
                                  borderRadius: BorderRadius.circular(8),
                                  child: LinearProgressIndicator(
                                    value: _progressController.value,
                                    minHeight: 5,
                                    backgroundColor: Colors.white.withValues(alpha: 0.2),
                                    valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                                  ),
                                );
                              },
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 36),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
