import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service quản lý thông báo
class NotificationService {
  
  /// Lấy danh sách thông báo của user
  static Future<List<Map<String, dynamic>>> getNotifications(String supabaseUid) async {
    try {
      // TODO: Implement real API call
      // final response = await http.get(
      //   Uri.parse('${ApiConfig.baseUrl}/notifications?userId=$supabaseUid'),
      // );
      
      await Future.delayed(const Duration(milliseconds: 300));
      return [];
    } catch (e) {
      return [];
    }
  }
  
  /// Đánh dấu thông báo đã đọc
  static Future<bool> markAsRead(String notificationId) async {
    try {
      // TODO: Implement real API call
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Đánh dấu tất cả đã đọc
  static Future<bool> markAllAsRead(String supabaseUid) async {
    try {
      // TODO: Implement real API call
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Xóa thông báo
  static Future<bool> deleteNotification(String notificationId) async {
    try {
      // TODO: Implement real API call
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Xóa tất cả thông báo
  static Future<bool> clearAll(String supabaseUid) async {
    try {
      // TODO: Implement real API call
      await Future.delayed(const Duration(milliseconds: 100));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Đếm số thông báo chưa đọc
  static Future<int> getUnreadCount(String supabaseUid) async {
    try {
      // TODO: Implement real API call
      return 3; // Demo
    } catch (e) {
      return 0;
    }
  }
  
  /// Đăng ký nhận push notification
  static Future<bool> registerPushToken(String supabaseUid, String token) async {
    try {
      // TODO: Implement real API call
      return true;
    } catch (e) {
      return false;
    }
  }
}
