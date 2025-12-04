import '../config/api_config.dart';
import 'api_service.dart';

/// Category Service
class CategoryService {
  /// Get all categories
  static Future<Map<String, dynamic>> getAllCategories() async {
    return await ApiService.get(ApiConfig.categories);
  }
  
  /// Get category by ID
  static Future<Map<String, dynamic>> getCategoryById(int id) async {
    return await ApiService.get(ApiConfig.categoryById(id));
  }
  
  /// Create category
  static Future<Map<String, dynamic>> createCategory({
    required String name,
    String? description,
  }) async {
    return await ApiService.post(
      ApiConfig.categories,
      body: {
        'categoryName': name,
        'categoryDescription': description,
      },
    );
  }
  
  /// Update category
  static Future<Map<String, dynamic>> updateCategory(int id, {
    String? name,
    String? description,
  }) async {
    return await ApiService.put(
      ApiConfig.categoryById(id),
      body: {
        if (name != null) 'categoryName': name,
        if (description != null) 'categoryDescription': description,
      },
    );
  }
  
  /// Delete category
  static Future<Map<String, dynamic>> deleteCategory(int id) async {
    return await ApiService.delete(ApiConfig.categoryById(id));
  }
}
