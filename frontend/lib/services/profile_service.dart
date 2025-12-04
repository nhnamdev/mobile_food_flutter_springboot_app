import '../config/api_config.dart';
import 'api_service.dart';

/// Profile Service - Quản lý thông tin người dùng
class ProfileService {
  /// Lấy thông tin profile theo userId
  static Future<Map<String, dynamic>> getProfile(int userId) async {
    return await ApiService.get(ApiConfig.profileById(userId));
  }
  
  /// Cập nhật profile
  static Future<Map<String, dynamic>> updateProfile({
    required int userId,
    String? fullName,
    String? phone,
    String? avatar,
  }) async {
    final Map<String, dynamic> body = {};
    if (fullName != null) body['fullName'] = fullName;
    if (phone != null) body['phone'] = phone;
    if (avatar != null) body['avatar'] = avatar;
    
    return await ApiService.put(
      ApiConfig.profileById(userId),
      body: body,
    );
  }
  
  /// Đổi mật khẩu
  static Future<Map<String, dynamic>> changePassword({
    required int userId,
    required String currentPassword,
    required String newPassword,
  }) async {
    return await ApiService.put(
      '${ApiConfig.changePassword(userId)}?currentPassword=$currentPassword&newPassword=$newPassword',
    );
  }
}
