import 'dart:async';
import 'package:flutter/material.dart';
import '../../../core/constants/app_images.dart';
import '../../../core/routes/app_routes.dart';

class SplashIntroScreen extends StatefulWidget {
  const SplashIntroScreen({super.key});

  @override
  State<SplashIntroScreen> createState() => _SplashIntroScreenState();
}

class _SplashIntroScreenState extends State<SplashIntroScreen>
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

  @override
  void initState() {
    super.initState();

    // Master controller running for 2200ms to allow a gorgeous fluid decelerating staggered flow
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
        curve: const Interval(0.12, 0.58, curve: Curves.easeOutBack), // Elegant bounce pop
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

    // Navigate to login after sequence resolves and dots execute some breathing loops (3.8s total)
    Future.delayed(const Duration(milliseconds: 3800), () {
      if (mounted) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      }
    });
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
          child: SafeArea(
            bottom: false,
            child: LayoutBuilder(
              builder: (context, constraints) {
                final height = constraints.maxHeight;

                final bool isShortScreen = height < 700;
                final double logoTop = isShortScreen ? height * 0.03 : height * 0.06;
                final double textTop = isShortScreen ? height * 0.35 : height * 0.44;
                
                final double logoSize = isShortScreen ? 60 : 72;
                final double titleFontSize = isShortScreen ? 28 : 34;
                final double subtitleFontSize = isShortScreen ? 13 : 14.5;
                final double spacingTitleSubtitle = isShortScreen ? 10 : 16;
                final double spacingSubtitleDots = isShortScreen ? 16 : 24;

                return Stack(
                  children: [
                    // Centered Logo & Brand Name at the top
                    Positioned(
                      top: logoTop,
                      left: 0,
                      right: 0,
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
                                    // Circular Logo Frame
                                    Container(
                                      padding: const EdgeInsets.all(18),
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
                                        width: logoSize,
                                        height: logoSize,
                                        fit: BoxFit.contain,
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    
                                    // App Name / Brand Title
                                    const Text(
                                      'iTrashy',
                                      style: TextStyle(
                                        fontSize: 28,
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

                    // Left-aligned Text Block
                    Positioned(
                      top: textTop,
                      left: 28,
                      right: 28,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          // Title: Smart Waste Management Made Easy
                          FadeTransition(
                            opacity: _titleFadeAnimation,
                            child: AnimatedBuilder(
                              animation: _titleSlideAnimation,
                              builder: (context, child) {
                                return Transform.translate(
                                  offset: Offset(0, _titleSlideAnimation.value),
                                  child: Text(
                                    'Smart Waste\nManagement Made\nEasy',
                                    style: TextStyle(
                                      fontSize: titleFontSize,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                      height: 1.25,
                                      letterSpacing: -0.5,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: spacingTitleSubtitle),
                          
                          // Description Subtitle
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
                                      fontSize: subtitleFontSize,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.white.withValues(alpha: 0.85),
                                      height: 1.5,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          SizedBox(height: spacingSubtitleDots),

                          // Dynamic Animated Loading Wave Dots
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

                    // Fixed Bottom Illustration
                    Positioned(
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: FadeTransition(
                        opacity: _illustrationFadeAnimation,
                        child: AnimatedBuilder(
                          animation: _illustrationSlideAnimation,
                          builder: (context, child) {
                            return Transform.translate(
                              offset: Offset(0, _illustrationSlideAnimation.value),
                              child: Image.asset(
                                AppImages.introIllustration,
                                fit: BoxFit.fitWidth,
                                alignment: Alignment.bottomCenter,
                              ),
                            );
                          },
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
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
      mainAxisAlignment: MainAxisAlignment.start,
      children: List.generate(3, (index) {
        return AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            // Wave delay shift per dot
            final delay = index * 0.22;
            double progress = _controller.value - delay;
            if (progress < 0) progress += 1.0;
            if (progress > 1.0) progress -= 1.0;

            // Generate organic breathing curve
            final double factor = (1.0 - (progress - 0.5).abs() * 2).clamp(0.0, 1.0);
            final double scale = 0.82 + (factor * 0.36);
            final double opacity = 0.30 + (factor * 0.70);

            return Container(
              margin: const EdgeInsets.only(right: 8),
              width: 8.5,
              height: 8.5,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: opacity),
              ),
              transform: Matrix4.identity()..scale(scale),
              transformAlignment: Alignment.center,
            );
          },
        );
      }),
    );
  }
}
