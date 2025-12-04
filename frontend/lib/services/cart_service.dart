import '../config/api_config.dart';
import 'api_service.dart';

/// Cart Service
class CartService {
  /// Get cart by user ID
  static Future<Map<String, dynamic>> getCartByUser(int userId) async {
    return await ApiService.get(ApiConfig.cartByUser(userId));
  }
  
  /// Get cart by user and shop
  static Future<Map<String, dynamic>> getCartByUserAndShop(int userId, int shopId) async {
    return await ApiService.get(ApiConfig.cartByUserAndShop(userId, shopId));
  }
  
  /// Add item to cart
  static Future<Map<String, dynamic>> addToCart({
    required int userId,
    required int shopId,
    required int foodItemId,
    required int quantity,
  }) async {
    return await ApiService.post(
      ApiConfig.cart,
      body: {
        'userId': userId,
        'shopId': shopId,
        'foodItemId': foodItemId,
        'quantity': quantity,
      },
    );
  }
  
  /// Update cart quantity
  static Future<Map<String, dynamic>> updateCartQuantity(int cartId, int quantity) async {
    return await ApiService.put(
      ApiConfig.cartItemById(cartId),
      body: {'quantity': quantity},
    );
  }
  
  /// Remove item from cart
  static Future<Map<String, dynamic>> removeFromCart(int cartId) async {
    return await ApiService.delete(ApiConfig.cartItemById(cartId));
  }
  
  /// Clear cart
  static Future<Map<String, dynamic>> clearCart(int userId) async {
    return await ApiService.delete(ApiConfig.cartByUser(userId));
  }
  
  /// Clear cart by shop
  static Future<Map<String, dynamic>> clearCartByShop(int userId, int shopId) async {
    return await ApiService.delete(ApiConfig.cartByUserAndShop(userId, shopId));
  }
}
