import '../config/api_config.dart';
import 'api_service.dart';

/// User Service
class UserService {
  /// Get all users
  static Future<Map<String, dynamic>> getAllUsers() async {
    return await ApiService.get(ApiConfig.users);
  }
  
  /// Get user by ID
  static Future<Map<String, dynamic>> getUserById(int id) async {
    return await ApiService.get(ApiConfig.userById(id));
  }
  
  /// Get user by email
  static Future<Map<String, dynamic>> getUserByEmail(String email) async {
    return await ApiService.get(ApiConfig.userByEmail(email));
  }
  
  /// Update user
  static Future<Map<String, dynamic>> updateUser(int id, Map<String, dynamic> data) async {
    return await ApiService.put(ApiConfig.userById(id), body: data);
  }
}
