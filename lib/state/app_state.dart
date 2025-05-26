import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor.dart';
import '../services/auth_service.dart';

class AppState extends ChangeNotifier {
  // Add your app-wide state variables here
  bool _isLoggedIn = false;
  int _currentTabIndex = 0;
  bool _isDarkMode = false;
  Doctor? _currentDoctor;
  bool _isLoading = false;
  String? _authError;

  // Auth service
  final _authService = AuthService();

  // Keys for SharedPreferences
  static const String _isDarkModeKey = 'isDarkMode';

  // Constructor that initializes the state
  AppState() {
    _loadPreferences();
    _checkAuth();
  }

  // Load saved preferences
  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    _isDarkMode = prefs.getBool(_isDarkModeKey) ?? false;
    notifyListeners();
  }

  // Save preferences
  Future<void> _savePreferences() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isDarkModeKey, _isDarkMode);
  }

  // Check authentication status
  Future<void> _checkAuth() async {
    _isLoading = true;
    notifyListeners();

    try {
      _isLoggedIn = await _authService.isAuthenticated();
      if (_isLoggedIn) {
        _currentDoctor = await _authService.getSavedDoctor();
      }
    } catch (e) {
      _isLoggedIn = false;
      _currentDoctor = null;
    }

    _isLoading = false;
    notifyListeners();
  }

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  int get currentTabIndex => _currentTabIndex;
  bool get isDarkMode => _isDarkMode;
  ThemeMode get themeMode => _isDarkMode ? ThemeMode.dark : ThemeMode.light;
  Doctor? get currentDoctor => _currentDoctor;
  bool get isLoading => _isLoading;
  String? get authError => _authError;

  // Methods to update state
  Future<bool> login(String username, String password) async {
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      final response = await _authService.login(
        username: username,
        password: password,
      );

      if (response['success'] == true) {
        _isLoggedIn = true;
        _currentDoctor = await _authService.getSavedDoctor();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _authError = response['message'] ?? 'Unknown error occurred';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      _authError = 'Connection error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String password,
    required String email,
    String? fullName,
    String? specialty,
  }) async {
    debugPrint('AppState: register method called');
    _isLoading = true;
    _authError = null;
    notifyListeners();

    try {
      debugPrint('AppState: calling _authService.register()');
      final response = await _authService.register(
        username: username,
        password: password,
        email: email,
        fullName: fullName,
        specialty: specialty,
      );
      debugPrint('AppState: register response: $response');

      if (response['success'] == true) {
        debugPrint('AppState: registration successful');
        _isLoggedIn = true;
        _currentDoctor = await _authService.getSavedDoctor();
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('AppState: registration failed: ${response['message']}');
        _authError = response['message'] ?? 'Unknown error occurred';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      debugPrint('AppState: registration error: $e');
      _authError = 'Connection error: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await _authService.logout();
    } catch (e) {
      // Ignore errors during logout
    } finally {
      _isLoggedIn = false;
      _currentDoctor = null;
      _isLoading = false;
      notifyListeners();
    }
  }

  void setCurrentTab(int index) {
    _currentTabIndex = index;
    notifyListeners();
  }

  void toggleTheme() {
    _isDarkMode = !_isDarkMode;
    _savePreferences();
    notifyListeners();
  }

  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  void setDarkMode(bool value) {
    if (_isDarkMode != value) {
      _isDarkMode = value;
      _savePreferences();
      notifyListeners();
    }
  }
}

class AppStateProvider extends InheritedNotifier<AppState> {
  const AppStateProvider({
    Key? key,
    required AppState notifier,
    required Widget child,
  }) : super(key: key, notifier: notifier, child: child);

  static AppState of(BuildContext context) {
    final AppStateProvider? provider =
        context.dependOnInheritedWidgetOfExactType<AppStateProvider>();
    return provider!.notifier!;
  }
}
