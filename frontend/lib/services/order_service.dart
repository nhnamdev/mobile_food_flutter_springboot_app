import '../config/api_config.dart';
import 'api_service.dart';

/// Order Service
class OrderService {
  /// Get orders by customer
  static Future<Map<String, dynamic>> getOrdersByCustomer(int customerId) async {
    return await ApiService.get(ApiConfig.ordersByCustomer(customerId));
  }
  
  /// Get orders by shop
  static Future<Map<String, dynamic>> getOrdersByShop(int shopId) async {
    return await ApiService.get(ApiConfig.ordersByShop(shopId));
  }
  
  /// Get order by ID
  static Future<Map<String, dynamic>> getOrderById(int id) async {
    return await ApiService.get(ApiConfig.orderById(id));
  }
  
  /// Get order by code
  static Future<Map<String, dynamic>> getOrderByCode(String code) async {
    return await ApiService.get(ApiConfig.orderByCode(code));
  }
  
  /// Create order from cart
  static Future<Map<String, dynamic>> createOrder({
    required int customerId,
    required int shopId,
    required String deliveryAddress,
    required String deliveryPhone,
    String? deliveryNote,
    required String paymentMethod, // COD, Momo, Banking
  }) async {
    return await ApiService.post(
      ApiConfig.orders,
      body: {
        'customerId': customerId,
        'shopId': shopId,
        'deliveryAddress': deliveryAddress,
        'deliveryPhone': deliveryPhone,
        'deliveryNote': deliveryNote,
        'paymentMethod': paymentMethod,
      },
    );
  }
  
  /// Update order status
  static Future<Map<String, dynamic>> updateOrderStatus(int id, String status) async {
    return await ApiService.put(
      ApiConfig.updateOrderStatus(id),
      body: {'status': status},
    );
  }
  
  /// Cancel order
  static Future<Map<String, dynamic>> cancelOrder(int id, int cancelledById, String reason) async {
    return await ApiService.put(
      ApiConfig.cancelOrder(id),
      body: {
        'cancelledById': cancelledById,
        'reason': reason,
      },
    );
  }
}
