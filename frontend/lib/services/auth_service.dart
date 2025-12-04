import '../config/api_config.dart';
import 'api_service.dart';
import 'user_session.dart';

/// Authentication Service
class AuthService {
  /// Login with email and password
  static Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await ApiService.post(
      ApiConfig.login,
      body: {
        'email': email,
        'password': password,
      },
    );
    
    // Set auth token and save user info if login successful
    if (response['success'] == true && response['data'] != null) {
      final data = response['data'];
      final token = data['token'];
      if (token != null) {
        ApiService.setAuthToken(token);
      }
      // Lưu thông tin user vào session
      if (data['user'] != null) {
        UserSession.instance.setUser(data['user'], authToken: token);
      }
    }
    
    return response;
  }
  
  /// Register new user
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    return await ApiService.post(
      ApiConfig.register,
      body: {
        'email': email,
        'password': password,
        'fullName': fullName,
        'phone': phone,
      },
    );
  }
  
  /// Logout - clear token and session
  static void logout() {
    ApiService.clearAuthToken();
    UserSession.instance.clear();
  }
}
