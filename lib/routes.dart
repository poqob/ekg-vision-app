import 'package:flutter/material.dart';
import 'screens/index.dart';
import 'state/app_state.dart' as app_state;

// Route names as constants
class Routes {
  static const String splash = '/';
  static const String home = '/home';
  static const String settings = '/settings';
  static const String login = '/login';
  static const String register = '/register';

  // Add more routes as needed
  // static const String detail = '/detail';
}

// Route generator function
class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    debugPrint('Generating route for: ${settings.name}');

    switch (settings.name) {
      case Routes.splash:
        debugPrint('Building splash screen route');
        return MaterialPageRoute(
          builder: (_) => const SplashScreen(),
        );

      case Routes.home:
        debugPrint('Building home screen route');
        return PageRouteBuilder(
          pageBuilder: (context, animation, secondaryAnimation) =>
              const HomeScreen(),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            return FadeTransition(
              opacity: animation,
              child: child,
            );
          },
          transitionDuration: const Duration(milliseconds: 500),
        );

      case Routes.settings:
        debugPrint('Building settings screen route');
        return MaterialPageRoute(
          builder: (_) => const SettingsScreen(),
        );

      case Routes.login:
        debugPrint('Building login screen route');
        return MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        );

      case Routes.register:
        debugPrint('Building register screen route');
        return MaterialPageRoute(
          builder: (_) => const RegisterScreen(),
        );

      // Add more routes as your app grows

      default:
        // If route is not found, show an error page
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('No route defined for ${settings.name}'),
            ),
          ),
        );
    }
  }

  // Helper method to check if user is authenticated
  static Future<bool> checkAuth(BuildContext context) async {
    final appState = app_state.AppStateProvider.of(context);
    return appState.isLoggedIn;
  }
}
