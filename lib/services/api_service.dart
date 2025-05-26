import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:8080'; // Change if needed
  final AuthService _authService = AuthService();

  // GET request with authentication
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await _authService.getToken();
      final response = await http.get(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(token),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // POST request with authentication
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      final response = await http.post(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(token),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // PUT request with authentication
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      final response = await http.put(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(token),
        body: jsonEncode(data),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // DELETE request with authentication
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await _authService.getToken();
      final response = await http.delete(
        Uri.parse('$baseUrl$endpoint'),
        headers: await _getHeaders(token),
      );

      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()}',
      };
    }
  }

  // Helper to create headers with authentication token if available
  Future<Map<String, String>> _getHeaders(String? token) async {
    final headers = {
      'Content-Type': 'application/json',
    };

    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }

    return headers;
  }

  // Helper to handle HTTP responses
  Map<String, dynamic> _handleResponse(http.Response response) {
    final data = jsonDecode(response.body);

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else if (response.statusCode == 401) {
      // Unauthorized - token might be expired
      return {
        'success': false,
        'message': 'Authentication error: ${data['message'] ?? 'Unauthorized'}',
        'unauthorized': true,
      };
    } else {
      return {
        'success': false,
        'message': data['message'] ??
            'Request failed with status: ${response.statusCode}',
      };
    }
  }
}
