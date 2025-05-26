import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor.dart';

class AuthService {
  // Local storage keys
  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // Register a new doctor
  Future<Map<String, dynamic>> register({
    required String username,
    required String password,
    required String email,
    String? fullName,
    String? specialty,
  }) async {
    try {
      debugPrint('Processing local registration');
      debugPrint(
          'Register data: username=$username, email=$email, fullName=$fullName, specialty=$specialty');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // Check if username already exists (you could extend this to check email too)
      final prefs = await SharedPreferences.getInstance();
      final allUsers = prefs.getStringList('all_users') ?? [];

      if (allUsers.contains(username)) {
        return {
          'success': false,
          'message': 'Username already exists',
        };
      }

      // Generate a mock token
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // Create user data
      final userData = {
        'id': DateTime.now().millisecondsSinceEpoch.toString(),
        'username': username,
        'email': email,
        'full_name': fullName ?? '',
        'specialty': specialty ?? '',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Save the new user
      allUsers.add(username);
      await prefs.setStringList('all_users', allUsers);

      // Save user specific data
      await _saveAuthData(token, userData);

      debugPrint('Registration successful, saving auth data');

      return {
        'success': true,
        'message': 'Registration successful',
        'token': token,
        'user': userData,
      };
    } catch (e) {
      debugPrint('Error during registration: $e');
      return {
        'success': false,
        'message': 'Registration error: ${e.toString()}',
      };
    }
  }

  // Login a doctor
  Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    try {
      debugPrint('Processing local login');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 800));

      // For simplicity, we're not actually checking passwords in this mock implementation
      // In a real app, you would verify credentials properly

      // Check if user exists
      final prefs = await SharedPreferences.getInstance();
      final allUsers = prefs.getStringList('all_users') ?? [];

      if (!allUsers.contains(username)) {
        return {
          'success': false,
          'message': 'Invalid username or password',
        };
      }

      // Generate a mock token
      final token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

      // Mock user data - in a real implementation you would retrieve this from storage
      final userData = {
        'id': '123456',
        'username': username,
        'email': '$username@example.com',
        'full_name': 'Dr. $username',
        'specialty': 'Cardiology',
        'created_at': DateTime.now().toIso8601String(),
      };

      // Save auth data
      await _saveAuthData(token, userData);

      debugPrint('Login successful');

      return {
        'success': true,
        'message': 'Login successful',
        'token': token,
        'user': userData,
      };
    } catch (e) {
      debugPrint('Error during login: $e');
      return {
        'success': false,
        'message': 'Login error: ${e.toString()}',
      };
    }
  }

  // Logout a doctor
  Future<bool> logout() async {
    try {
      debugPrint('Processing local logout');

      // Simulate network delay
      await Future.delayed(const Duration(milliseconds: 500));

      // Clear saved authentication data
      await _clearAuthData();

      return true;
    } catch (e) {
      debugPrint('Error during logout: $e');
      // If logout fails, still clear local data
      await _clearAuthData();
      return true;
    }
  }

  // Get current doctor profile
  Future<Map<String, dynamic>?> getCurrentDoctor() async {
    try {
      final doctor = await getSavedDoctor();
      if (doctor == null) {
        return null;
      }

      return doctor.toJson();
    } catch (e) {
      debugPrint('Error getting current doctor: $e');
      return null;
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await getToken();
    return token != null;
  }

  // Get saved authentication token
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // Get saved user data
  Future<Doctor?> getSavedDoctor() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData == null) {
      return null;
    }

    try {
      return Doctor.fromJson(jsonDecode(userData));
    } catch (e) {
      debugPrint('Error parsing saved doctor data: $e');
      return null;
    }
  }

  // Save authentication data
  Future<void> _saveAuthData(
      String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userKey, jsonEncode(userData));
  }

  // Clear authentication data
  Future<void> _clearAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }
}
