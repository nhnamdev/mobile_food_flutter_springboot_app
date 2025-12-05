import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service để sync user từ Supabase Auth vào backend database
class UserSyncService {
  
  /// Sync user từ Google OAuth vào backend
  /// Gọi sau khi đăng nhập Google thành công
  static Future<Map<String, dynamic>> syncGoogleUser({
    required String supabaseUid,
    required String email,
    required String fullName,
    String? avatar,
    String? phone,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('${ApiConfig.baseUrl}/auth/google/sync'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'supabaseUid': supabaseUid,
          'email': email,
          'fullName': fullName,
          'avatar': avatar,
          'phone': phone,
        }),
      );
      
      final data = jsonDecode(response.body);
      
      if (response.statusCode == 200 && data['success'] == true) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['data'], // UserResponse từ backend
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? 'Sync failed',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi kết nối: $e',
      };
    }
  }
}
