import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Base API Service for handling HTTP requests to Spring Boot backend
class ApiService {
  static String? _authToken;
  
  /// Set authentication token
  static void setAuthToken(String token) {
    _authToken = token;
  }
  
  /// Clear authentication token
  static void clearAuthToken() {
    _authToken = null;
  }
  
  /// Get default headers
  static Map<String, String> get _headers => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    if (_authToken != null) 'Authorization': 'Bearer $_authToken',
  };
  
  /// Build full URL from endpoint
  static Uri _buildUrl(String endpoint) {
    return Uri.parse('${ApiConfig.baseUrl}$endpoint');
  }
  
  /// Handle API response
  static Map<String, dynamic> _handleResponse(http.Response response) {
    final body = json.decode(response.body);
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return body;
    } else {
      throw ApiException(
        statusCode: response.statusCode,
        message: body['message'] ?? 'Unknown error occurred',
      );
    }
  }
  
  /// GET request
  static Future<Map<String, dynamic>> get(String endpoint) async {
    try {
      final response = await http.get(
        _buildUrl(endpoint),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
  
  /// POST request
  static Future<Map<String, dynamic>> post(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.post(
        _buildUrl(endpoint),
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
  
  /// PUT request
  static Future<Map<String, dynamic>> put(String endpoint, {Map<String, dynamic>? body}) async {
    try {
      final response = await http.put(
        _buildUrl(endpoint),
        headers: _headers,
        body: body != null ? json.encode(body) : null,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
  
  /// DELETE request
  static Future<Map<String, dynamic>> delete(String endpoint) async {
    try {
      final response = await http.delete(
        _buildUrl(endpoint),
        headers: _headers,
      );
      return _handleResponse(response);
    } catch (e) {
      if (e is ApiException) rethrow;
      throw ApiException(message: e.toString());
    }
  }
}

/// API Exception class
class ApiException implements Exception {
  final int? statusCode;
  final String message;
  
  ApiException({this.statusCode, required this.message});
  
  @override
  String toString() => 'ApiException: $message (Status: $statusCode)';
}
