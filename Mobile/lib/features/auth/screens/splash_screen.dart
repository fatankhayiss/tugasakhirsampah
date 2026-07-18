import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/routes/app_routes.dart';
import '../../../core/services/app_initializer_service.dart';

/// Single unified entry screen: acts as the Application Initializer layer.
/// 
/// Displays the high-end branding animations while asynchronously initializing
/// all core dependencies (Flutter, Firebase, Google Auth, Session, Profile,
/// Local Storage, Settings, Notification, API, Connectivity, and Config).
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _mainController;
  
  late final Animation<double> _backgroundFadeAnimation;
  late final Animation<double> _logoFadeAnimation;
  late final Animation<double> _logoSlideAnimation;
  late final Animation<double> _logoScaleAnimation;
  late final Animation<double> _titleFadeAnimation;
  late final Animation<double> _titleSlideAnimation;
  late final Animation<double> _subtitleFadeAnimation;
  late final Animation<double> _subtitleSlideAnimation;
  late final Animation<double> _dotsFadeAnimation;
  late final Animation<double> _dotsSlideAnimation;
  late final Animation<double> _illustrationFadeAnimation;
  late final Animation<double> _illustrationSlideAnimation;

  bool _isInitializing = false;

  @override
  void initState() {
    super.initState();

    // Master controller running for 2200ms to allow a fluid decelerating staggered flow
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2200),
    );

    const curve = Curves.easeOutCubic;

    // 1. Background fades in first
    _backgroundFadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.0, 0.30, curve: Curves.easeOut),
    );

    // 2. Logo slides and pops with a premium spring decel
    _logoFadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.12, 0.52, curve: curve),
    );
    _logoSlideAnimation = Tween<double>(begin: 40.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.12, 0.52, curve: curve),
      ),
    );
    _logoScaleAnimation = Tween<double>(begin: 0.80, end: 1.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.12, 0.58, curve: Curves.easeOutBack),
      ),
    );

    // 3. Illustration reveals quickly afterwards
    _illustrationFadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.18, 0.78, curve: curve),
    );
    _illustrationSlideAnimation = Tween<double>(begin: 60.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.18, 0.78, curve: curve),
      ),
    );

    // 4. Title fades and slides up
    _titleFadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.28, 0.68, curve: curve),
    );
    _titleSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.28, 0.68, curve: curve),
      ),
    );

    // 5. Subtitle fades and slides up
    _subtitleFadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.38, 0.78, curve: curve),
    );
    _subtitleSlideAnimation = Tween<double>(begin: 30.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.38, 0.78, curve: curve),
      ),
    );

    // 6. Active loading dots reveal
    _dotsFadeAnimation = CurvedAnimation(
      parent: _mainController,
      curve: const Interval(0.48, 0.88, curve: curve),
    );
    _dotsSlideAnimation = Tween<double>(begin: 20.0, end: 0.0).animate(
      CurvedAnimation(
        parent: _mainController,
        curve: const Interval(0.48, 0.88, curve: curve),
      ),
    );

    // Execute master timeline once
    _mainController.forward();

    // Run the comprehensive 12-step initialization sequence without artificial delay
    _runInitializationSequence();
  }

  Future<void> _runInitializationSequence() async {
    if (_isInitializing) return;
    setState(() => _isInitializing = true);

    try {
      // Execute background application initialization AND ensure visual splash animation completes 100%
      final initFuture = AppInitializerService.instance.initializeApp();
      final animFuture = _mainController.forward();

      await Future.wait<dynamic>([initFuture, animFuture]);
      final destination = await initFuture;

      if (!mounted) return;
      // Single navigation decision point once required tasks and animation are finished
      if (destination == AppInitDestination.dashboard) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.main);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() => _isInitializing = false);
      _showInitializationErrorDialog();
    }
  }

  void _showInitializationErrorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          backgroundColor: Colors.white,
          title: const Row(
            children: [
              Icon(Icons.error_outline, color: Color(0xFFDC2626), size: 28),
              SizedBox(width: 12),
              Expanded(
                child: Text(
                  'Initialization Error',
                  style: TextStyle(
                    fontFamily: 'Plus Jakarta Sans',
                    fontWeight: FontWeight.w700,
                    fontSize: 18,
                    color: Color(0xFF1B233A),
                  ),
                ),
              ),
            ],
          ),
          content: const Text(
            'Unable to initialize the application.\nPlease check your internet connection.',
            style: TextStyle(
              fontFamily: 'Plus Jakarta Sans',
              fontSize: 14,
              height: 1.5,
              color: Color(0xFF7B8190),
            ),
          ),
          actionsPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
          actions: [
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      if (Platform.isAndroid || Platform.isIOS) {
                        SystemNavigator.pop();
                      } else {
                        exit(0);
                      }
                    },
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      side: const BorderSide(color: Color(0xFFE2E8F0)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Exit',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF7B8190),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      _runInitializationSequence();
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF2DAA63),
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: const Text(
                      'Retry',
                      style: TextStyle(
                        fontFamily: 'Plus Jakarta Sans',
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }

  @override
  void dispose() {
    _mainController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1B6A41), // Foundation deep green
      body: FadeTransition(
        opacity: _backgroundFadeAnimation,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Color(0xFF2C9F63), // Rich Eco Green
                Color(0xFF1B6A41), // Deeper Green Shadow
              ],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Stack(
            children: [
              // Bottom Illustration (Touches left, right, bottom edges without margins, clipping, or stretching)
              Align(
                alignment: Alignment.bottomCenter,
                child: FadeTransition(
                  opacity: _illustrationFadeAnimation,
                  child: AnimatedBuilder(
                    animation: _illustrationSlideAnimation,
                    builder: (context, child) {
                      return Transform.translate(
                        offset: Offset(0, _illustrationSlideAnimation.value),
                        child: SizedBox(
                          width: double.infinity,
                          child: Image.asset(
                            AppImages.loadingScreen,
                            fit: BoxFit.fitWidth,
                            alignment: Alignment.bottomCenter,
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ),

              // Top Content (Logo, Title, Subtitle, Dots)
              SafeArea(
                bottom: false,
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final double minDim = constraints.maxWidth < constraints.maxHeight
                        ? constraints.maxWidth
                        : constraints.maxHeight;
                    final double maxLogoSize = (minDim * 0.16).clamp(42.0, 75.0);
                    final double vGapSmall = (constraints.maxHeight * 0.012).clamp(4.0, 12.0);
                    final double vGapMedium = (constraints.maxHeight * 0.02).clamp(8.0, 18.0);

                    return Column(
                      children: [
                        SizedBox(height: vGapSmall),
                        // Centered Logo & Brand Name at the top
                        SizedBox(
                          width: double.infinity,
                          child: Center(
                            child: FadeTransition(
                              opacity: _logoFadeAnimation,
                              child: AnimatedBuilder(
                                animation: _logoSlideAnimation,
                                builder: (context, child) {
                                  return Transform.translate(
                                    offset: Offset(0, _logoSlideAnimation.value),
                                    child: ScaleTransition(
                                      scale: _logoScaleAnimation,
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Container(
                                            padding: EdgeInsets.all((minDim * 0.035).clamp(8.0, 14.0)),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: Colors.white.withValues(alpha: 0.12),
                                              border: Border.all(
                                                color: Colors.white.withValues(alpha: 0.15),
                                                width: 1.5,
                                              ),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: const Color(0xFF0F4227).withValues(alpha: 0.10),
                                                  blurRadius: 16,
                                                  offset: const Offset(0, 4),
                                                ),
                                              ],
                                            ),
                                            child: Image.asset(
                                              AppImages.introLogo,
                                              width: maxLogoSize,
                                              height: maxLogoSize,
                                              fit: BoxFit.contain,
                                            ),
                                          ),
                                          SizedBox(height: vGapSmall),
                                          Text(
                                            'I-Trashy',
                                            style: TextStyle(
                                              fontSize: (constraints.maxWidth * 0.052).clamp(16.0, 22.0),
                                              fontWeight: FontWeight.w800,
                                              color: Colors.white,
                                              letterSpacing: -0.5,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ),
                        ),

                        const Spacer(flex: 2),

                        // Left-aligned Text Block
                        Padding(
                          padding: EdgeInsets.symmetric(
                            horizontal: (constraints.maxWidth * 0.07).clamp(20.0, 48.0),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              FadeTransition(
                                opacity: _titleFadeAnimation,
                                child: AnimatedBuilder(
                                  animation: _titleSlideAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _titleSlideAnimation.value),
                                      child: FittedBox(
                                        fit: BoxFit.scaleDown,
                                        alignment: Alignment.centerLeft,
                                        child: Text(
                                          'Smart Waste\nManagement Made\nEasy',
                                          style: TextStyle(
                                            fontSize: (constraints.maxWidth * 0.082).clamp(24.0, 38.0),
                                            fontWeight: FontWeight.w800,
                                            color: Colors.white,
                                            height: 1.25,
                                            letterSpacing: -0.5,
                                          ),
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: vGapSmall + 4),
                              FadeTransition(
                                opacity: _subtitleFadeAnimation,
                                child: AnimatedBuilder(
                                  animation: _subtitleSlideAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _subtitleSlideAnimation.value),
                                      child: Text(
                                        'Ayo setor sampahmu, jadwalkan pickup\nsampahmu dan dapatkan rewards.',
                                        style: TextStyle(
                                          fontSize: (constraints.maxWidth * 0.036).clamp(11.0, 15.0),
                                          fontWeight: FontWeight.w500,
                                          color: Colors.white.withValues(alpha: 0.85),
                                          height: 1.5,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              SizedBox(height: vGapMedium),
                              FadeTransition(
                                opacity: _dotsFadeAnimation,
                                child: AnimatedBuilder(
                                  animation: _dotsSlideAnimation,
                                  builder: (context, child) {
                                    return Transform.translate(
                                      offset: Offset(0, _dotsSlideAnimation.value),
                                      child: const _AnimatedLoadingDots(),
                                    );
                                  },
                                ),
                              ),
                            ],
                          ),
                        ),

                        const Spacer(flex: 7),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// A premium, dynamically staggered infinite repeating loading dots indicator
class _AnimatedLoadingDots extends StatefulWidget {
  const _AnimatedLoadingDots();

  @override
  State<_AnimatedLoadingDots> createState() => _AnimatedLoadingDotsState();
}

class _AnimatedLoadingDotsState extends State<_AnimatedLoadingDots>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Calculate a sine wave pulse offset per dot
            final double progress = (_controller.value + (index * 0.2)) % 1.0;
            final double opacity = 0.3 + (0.7 * (1 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0));
            final double scale = 0.8 + (0.4 * (1 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0));

            return Transform.scale(
              scale: scale,
              child: Container(
                margin: const EdgeInsets.only(right: 8),
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: opacity),
                ),
              ),
            );
          },
        );
      }),
    );
  }
}
