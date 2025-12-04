import '../config/api_config.dart';
import 'api_service.dart';

/// Food Item Service
class FoodItemService {
  /// Get all food items
  static Future<Map<String, dynamic>> getAllFoodItems() async {
    return await ApiService.get(ApiConfig.foodItems);
  }
  
  /// Get food item by ID
  static Future<Map<String, dynamic>> getFoodItemById(int id) async {
    return await ApiService.get(ApiConfig.foodItemById(id));
  }
  
  /// Get food items by shop
  static Future<Map<String, dynamic>> getFoodItemsByShop(int shopId) async {
    return await ApiService.get(ApiConfig.foodItemsByShop(shopId));
  }
  
  /// Get food items by category
  static Future<Map<String, dynamic>> getFoodItemsByCategory(int categoryId) async {
    return await ApiService.get(ApiConfig.foodItemsByCategory(categoryId));
  }
  
  /// Search food items
  static Future<Map<String, dynamic>> searchFoodItems(String keyword) async {
    return await ApiService.get(ApiConfig.searchFoodItems(keyword));
  }
  
  /// Create food item
  static Future<Map<String, dynamic>> createFoodItem({
    required int shopId,
    required int categoryId,
    required String name,
    String? description,
    required double price,
    double? discountPrice,
    String? image,
  }) async {
    return await ApiService.post(
      ApiConfig.foodItems,
      body: {
        'shopId': shopId,
        'categoryId': categoryId,
        'foodName': name,
        'foodDescription': description,
        'price': price,
        if (discountPrice != null) 'discountPrice': discountPrice,
        if (image != null) 'image': image,
      },
    );
  }
  
  /// Update food item
  static Future<Map<String, dynamic>> updateFoodItem(int id, Map<String, dynamic> data) async {
    return await ApiService.put(ApiConfig.foodItemById(id), body: data);
  }
  
  /// Delete food item
  static Future<Map<String, dynamic>> deleteFoodItem(int id) async {
    return await ApiService.delete(ApiConfig.foodItemById(id));
  }
}
