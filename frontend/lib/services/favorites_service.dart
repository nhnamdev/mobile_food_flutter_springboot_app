import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';

/// Service quản lý favorites (yêu thích)
class FavoritesService {
  
  /// Lấy danh sách yêu thích của user
  static Future<Map<String, dynamic>> getFavorites(String supabaseUid) async {
    try {
      // TODO: Implement real API call
      // Giả lập data demo
      await Future.delayed(const Duration(milliseconds: 300));
      
      return {
        'foods': [
          {
            'id': 1,
            'foodName': 'Phở Bò Đặc Biệt',
            'price': 65000,
            'image': 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=400',
            'rating': 4.8,
            'shopName': 'Phở Hà Nội',
          },
          {
            'id': 2,
            'foodName': 'Cơm Tấm Sườn Bì',
            'price': 45000,
            'image': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
            'rating': 4.5,
            'shopName': 'Cơm Tấm Sài Gòn',
          },
          {
            'id': 3,
            'foodName': 'Bánh Mì Thịt Nướng',
            'price': 30000,
            'image': 'https://images.unsplash.com/photo-1600628421055-4d30de868b8f?w=400',
            'rating': 4.9,
            'shopName': 'Bánh Mì Huỳnh Hoa',
          },
        ],
        'shops': [
          {
            'id': 1,
            'shopName': 'Quán Phở Hà Nội',
            'logo': 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=400',
            'address': '45 Lê Văn Sỹ, Q.3, TP.HCM',
            'rating': 4.8,
            'shopStatus': 'active',
          },
          {
            'id': 2,
            'shopName': 'Cơm Tấm Sài Gòn',
            'logo': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
            'address': '78 Hai Bà Trưng, Q.1, TP.HCM',
            'rating': 4.5,
            'shopStatus': 'active',
          },
        ],
      };
    } catch (e) {
      return {'foods': [], 'shops': []};
    }
  }
  
  /// Thêm vào yêu thích
  static Future<bool> addFavorite(String supabaseUid, String type, int itemId) async {
    try {
      // TODO: Implement real API call
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Xóa khỏi yêu thích
  static Future<bool> removeFavorite(String supabaseUid, String type, int itemId) async {
    try {
      // TODO: Implement real API call
      await Future.delayed(const Duration(milliseconds: 200));
      return true;
    } catch (e) {
      return false;
    }
  }
  
  /// Kiểm tra đã yêu thích chưa
  static Future<bool> isFavorite(String supabaseUid, String type, int itemId) async {
    try {
      // TODO: Implement real API call
      return false;
    } catch (e) {
      return false;
    }
  }
}
