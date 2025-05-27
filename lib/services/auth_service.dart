import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/doctor.dart' as user_model;

class AuthService {
  static const String baseUrl = 'http://localhost:8080';
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
      debugPrint('Sending register request to: $baseUrl/register');
      final response = await http.post(
        Uri.parse('$baseUrl/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'password': password,
          'email': email,
          if (fullName != null && fullName.isNotEmpty) 'full_name': fullName,
          if (specialty != null && specialty.isNotEmpty) 'specialty': specialty,
        }),
      );
      debugPrint('Register response status code: \\${response.statusCode}');
      debugPrint('Register response body: \\${response.body}');
      final data = jsonDecode(response.body);
      if (data['success'] == true && data['token'] != null) {
        await _saveAuthData(data['token'], data['user']);
      }
      return data;
    } catch (e) {
      debugPrint('Error during registration: $e');
      return {
        'success': false,
        'message': 'Registration error: \\${e.toString()}',
      };
    }
  }

  // Login a doctor
  Future<Map<String, dynamic>> login({
    required String username, // username is actually email for backend
    required String password,
  }) async {
    try {
      debugPrint('Sending login request to: $baseUrl/login');
      final response = await http.post(
        Uri.parse('$baseUrl/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': username, // username field is actually email for backend
          'password': password,
        }),
      );
      debugPrint('Login response status code: \\${response.statusCode}');
      debugPrint('Login response body: \\${response.body}');
      Map<String, dynamic> data = {};
      if (response.statusCode == 200) {
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          data = {
            'success': false,
            'message': 'Invalid response from server',
          };
        }
        if (data['token'] != null) {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(tokenKey, data['token']);
          // Fetch user info with token
          final userInfoResponse = await http.get(
            Uri.parse('$baseUrl/me'),
            headers: {
              'Authorization': 'Bearer ${data['token']}',
              'Content-Type': 'application/json',
            },
          );
          debugPrint(
              'User info response status code: \\${userInfoResponse.statusCode}');
          debugPrint('User info response body: \\${userInfoResponse.body}');
          if (userInfoResponse.statusCode == 200) {
            try {
              final userInfo = jsonDecode(userInfoResponse.body);
              data['user'] = userInfo;
              await prefs.setString(userKey, jsonEncode(userInfo));
              // Download and save profile picture if present
              if (userInfo['profilePictureUrl'] != null &&
                  userInfo['profilePictureUrl'].toString().isNotEmpty &&
                  userInfo['profilePictureUrl'] !=
                      '/static/default_profile.png') {
                final userId = userInfo['id'] ?? userInfo['_id'];
                final fullUrl = 'http://localhost:8080/profile_picture/$userId';
                try {
                  final ppResponse = await http.get(Uri.parse(fullUrl));
                  if (ppResponse.statusCode == 200 &&
                      ppResponse.headers['content-type']
                              ?.startsWith('image/') ==
                          true) {
                    // Save the raw bytes to shared preferences as base64
                    await prefs.setString('profile_picture_bytes',
                        base64Encode(ppResponse.bodyBytes));
                  } else {
                    await prefs.remove('profile_picture_bytes');
                  }
                } catch (e) {
                  debugPrint('Error downloading profile picture: $e');
                  await prefs.remove('profile_picture_bytes');
                }
              } else {
                await prefs.remove('profile_picture_bytes');
              }
            } catch (e) {
              debugPrint('Error parsing user info: $e');
            }
          }
          data['success'] = true;
        } else {
          data['success'] = false;
          data['message'] = data['message'] ?? 'No token received from server.';
        }
      } else {
        // Handle non-200 responses
        try {
          data = jsonDecode(response.body);
        } catch (e) {
          data = {
            'success': false,
            'message': response.body,
          };
        }
        data['success'] = false;
        data['message'] = data['message'] ??
            'Login failed with status ${response.statusCode}.';
      }
      return data;
    } catch (e) {
      debugPrint('Error during login: $e');
      return {
        'success': false,
        'message': 'Login error: \\${e.toString()}',
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

  // Get saved user data
  Future<user_model.User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userData = prefs.getString(userKey);
    if (userData == null) {
      return null;
    }
    try {
      return user_model.User.fromJson(jsonDecode(userData));
    } catch (e) {
      debugPrint('Error parsing saved user data: $e');
      return null;
    }
  }

  // Get current user profile
  Future<Map<String, dynamic>?> getCurrentUser() async {
    try {
      final user = await getSavedUser();
      if (user == null) {
        return null;
      }
      return user.toJson();
    } catch (e) {
      debugPrint('Error getting current user: $e');
      return null;
    }
  }

  // Fetch user data from backend and update local storage
  Future<user_model.User?> getCurrentUserFromBackend() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('auth_token');
      if (token == null) return null;
      final response = await http.get(
        Uri.parse('http://localhost:8080/me'),
        headers: {'Authorization': 'Bearer $token'},
      );
      if (response.statusCode == 200) {
        final userJson = response.body;
        final userMap = userJson.isNotEmpty
            ? Map<String, dynamic>.from(jsonDecode(userJson))
            : null;
        if (userMap != null) {
          final user = user_model.User.fromJson(userMap);
          await prefs.setString('user_data', userJson);
          return user;
        }
      }
      return null;
    } catch (e) {
      debugPrint('Error fetching user from backend: $e');
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
