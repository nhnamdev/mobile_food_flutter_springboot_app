import '../config/api_config.dart';
import 'api_service.dart';

/// Review Service
class ReviewService {
  /// Get reviews by shop
  static Future<Map<String, dynamic>> getReviewsByShop(int shopId) async {
    return await ApiService.get(ApiConfig.reviewsByShop(shopId));
  }
  
  /// Get reviews by customer
  static Future<Map<String, dynamic>> getReviewsByCustomer(int customerId) async {
    return await ApiService.get(ApiConfig.reviewsByCustomer(customerId));
  }
  
  /// Get review by ID
  static Future<Map<String, dynamic>> getReviewById(int id) async {
    return await ApiService.get(ApiConfig.reviewById(id));
  }
  
  /// Create review
  static Future<Map<String, dynamic>> createReview({
    required int orderId,
    required int customerId,
    required int rating,
    String? comment,
    String? images,
  }) async {
    return await ApiService.post(
      ApiConfig.reviews,
      body: {
        'orderId': orderId,
        'customerId': customerId,
        'rating': rating,
        if (comment != null) 'comment': comment,
        if (images != null) 'images': images,
      },
    );
  }
  
  /// Reply to review (shop owner)
  static Future<Map<String, dynamic>> replyToReview(int reviewId, String reply) async {
    return await ApiService.put(
      ApiConfig.replyToReview(reviewId),
      body: {'reply': reply},
    );
  }
}
