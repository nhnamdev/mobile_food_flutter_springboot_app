import '../config/api_config.dart';
import 'api_service.dart';

/// Shop Service
class ShopService {
  /// Get all shops
  static Future<Map<String, dynamic>> getAllShops() async {
    return await ApiService.get(ApiConfig.shops);
  }
  
  /// Get active shops
  static Future<Map<String, dynamic>> getActiveShops() async {
    return await ApiService.get(ApiConfig.activeShops);
  }
  
  /// Get top rated shops
  static Future<Map<String, dynamic>> getTopRatedShops() async {
    return await ApiService.get(ApiConfig.topRatedShops);
  }
  
  /// Get shop by ID
  static Future<Map<String, dynamic>> getShopById(int id) async {
    return await ApiService.get(ApiConfig.shopById(id));
  }
  
  /// Get shops by user ID
  static Future<Map<String, dynamic>> getShopsByUser(int userId) async {
    return await ApiService.get(ApiConfig.shopsByUser(userId));
  }
  
  /// Get shops by category
  static Future<Map<String, dynamic>> getShopsByCategory(int categoryId) async {
    return await ApiService.get(ApiConfig.shopsByCategory(categoryId));
  }
  
  /// Search shops
  static Future<Map<String, dynamic>> searchShops(String keyword) async {
    return await ApiService.get(ApiConfig.searchShops(keyword));
  }
  
  /// Create shop
  static Future<Map<String, dynamic>> createShop(int userId, Map<String, dynamic> data) async {
    return await ApiService.post(
      ApiConfig.shopsByUser(userId),
      body: data,
    );
  }
  
  /// Update shop
  static Future<Map<String, dynamic>> updateShop(int id, Map<String, dynamic> data) async {
    return await ApiService.put(ApiConfig.shopById(id), body: data);
  }
}
