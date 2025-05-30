import 'dart:convert';
import 'package:http/http.dart' as http;
import 'auth_service.dart';
import '../constants/app_config.dart';

class ApiService {
  final AuthService _authService = AuthService();

  // GET request with authentication
  Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final token = await _authService.getToken();
      final uri = _buildUri(endpoint);
      final response = await http.get(
        uri,
        headers: await _getHeaders(token),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()} (endpoint: $endpoint)',
      };
    }
  }

  // POST request with authentication
  Future<Map<String, dynamic>> post(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      final uri = _buildUri(endpoint);
      final response = await http.post(
        uri,
        headers: await _getHeaders(token),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()} (endpoint: $endpoint)',
      };
    }
  }

  // PUT request with authentication
  Future<Map<String, dynamic>> put(
      String endpoint, Map<String, dynamic> data) async {
    try {
      final token = await _authService.getToken();
      final uri = _buildUri(endpoint);
      final response = await http.put(
        uri,
        headers: await _getHeaders(token),
        body: jsonEncode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()} (endpoint: $endpoint)',
      };
    }
  }

  // DELETE request with authentication
  Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final token = await _authService.getToken();
      final uri = _buildUri(endpoint);
      final response = await http.delete(
        uri,
        headers: await _getHeaders(token),
      );
      return _handleResponse(response);
    } catch (e) {
      return {
        'success': false,
        'message': 'Connection error: ${e.toString()} (endpoint: $endpoint)',
      };
    }
  }

  // Helper to create properly formatted URI
  Uri _buildUri(String endpoint) {
    String baseUrl = AppConfig.apiBaseUrl;

    // Ensure baseUrl doesn't end with a slash and endpoint starts with one
    if (baseUrl.endsWith('/')) {
      baseUrl = baseUrl.substring(0, baseUrl.length - 1);
    }

    if (!endpoint.startsWith('/')) {
      endpoint = '/$endpoint';
    }

    final url = '$baseUrl$endpoint';
    return Uri.parse(url);
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
