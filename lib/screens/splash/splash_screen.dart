import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../routes.dart' as app_routes;
import '../../constants/app_constants.dart';
import '../../constants/app_theme.dart';
import '../../state/app_state.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isZoomingIn = true;

  @override
  void initState() {
    super.initState();
    debugPrint('SplashScreen initState called');

    _controller = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: AppConstants.splashAnimationDurationMs),
    );

    // Debug print to verify animation completion
    _controller.addListener(() {
      if (_controller.isCompleted) {
        debugPrint('Animation completed, value: ${_controller.value}');
      }
      if (_controller.isDismissed && !_isZoomingIn) {
        debugPrint(
            'Animation reversed completely, value: ${_controller.value}');
      }
    });

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        if (_isZoomingIn) {
          _isZoomingIn = false;
          _controller.reverse();
        } else {
          // Navigate to the login screen or home screen based on authentication status
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              // Check if user is logged in
              final isLoggedIn = AppStateProvider.of(context).isLoggedIn;

              if (isLoggedIn) {
                Navigator.of(context)
                    .pushReplacementNamed(app_routes.Routes.home);
              } else {
                Navigator.of(context)
                    .pushReplacementNamed(app_routes.Routes.login);
              }
              print('Navigating after animation completed');
            }
          });
        }
      } else if (status == AnimationStatus.dismissed) {
        // This triggers when the animation reverses completely
        // Add this to ensure the navigation happens
        if (!_isZoomingIn) {
          Future.delayed(const Duration(milliseconds: 500), () {
            if (mounted) {
              // Check if user is logged in
              final isLoggedIn = AppStateProvider.of(context).isLoggedIn;

              if (isLoggedIn) {
                Navigator.of(context)
                    .pushReplacementNamed(app_routes.Routes.home);
              } else {
                Navigator.of(context)
                    .pushReplacementNamed(app_routes.Routes.login);
              }
              print('Navigating after animation dismissed');
            }
          });
        }
      }
    });

    // Start the animation
    _controller.forward();

    // Fallback navigation trigger after a fixed delay
    // This ensures navigation happens even if animation status listeners fail
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted && Navigator.of(context).canPop() == false) {
        debugPrint('Fallback navigation triggered');
        final isLoggedIn = AppStateProvider.of(context).isLoggedIn;

        if (isLoggedIn) {
          Navigator.of(context).pushReplacementNamed(app_routes.Routes.home);
        } else {
          Navigator.of(context).pushReplacementNamed(app_routes.Routes.login);
        }
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
    // Create animations for zoom in and out
    debugPrint('Building SplashScreen');
    final zoomAnimation = Tween<double>(begin: 0.8, end: 1.2).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeInOut,
      ),
    );

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.darkBackgroundColor
          : Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // SVG with zoom animation
            AnimatedBuilder(
              animation: _controller,
              builder: (context, child) {
                return Transform.scale(
                  scale: zoomAnimation.value,
                  child: SvgPicture.asset(
                    AppConstants.healthSvgPath,
                    height: AppConstants.splashLogoSize,
                    width: AppConstants.splashLogoSize,
                  ),
                );
              },
            )
                .animate()
                .fade(duration: 800.ms)
                .slideY(begin: -0.2, end: 0, duration: 800.ms),

            SizedBox(height: AppConstants.largeSpacing),

            // Application name with characteristic style
            Text(
              AppConstants.appName,
              style: AppTheme.headingStyle(
                  isDark: Theme.of(context).brightness == Brightness.dark),
            )
                .animate()
                .fade(delay: 400.ms, duration: 800.ms)
                .slideY(begin: 0.2, end: 0, delay: 400.ms, duration: 800.ms),

            SizedBox(height: AppConstants.smallSpacing),

            // Tagline or subtitle
            Text(
              AppConstants.appTagline,
              style: AppTheme.subheadingStyle(
                  isDark: Theme.of(context).brightness == Brightness.dark),
            )
                .animate()
                .fade(delay: 600.ms, duration: 800.ms)
                .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 800.ms),
          ],
        ),
      ),
    );
  }
}
