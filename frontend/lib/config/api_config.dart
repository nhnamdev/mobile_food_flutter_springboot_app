/// API Configuration for connecting to Spring Boot Backend
class ApiConfig {
  // Base URL cho backend API
  // Khi chạy local trên Android emulator, sử dụng 10.0.2.2 thay vì localhost
  // Khi chạy trên iOS simulator hoặc web, sử dụng localhost
  // Khi chạy trên thiết bị thật, sử dụng IP của máy tính
  
  static const String _localAndroidEmulator = 'http://10.0.2.2:8080/api';
  static const String _localIosSimulator = 'http://localhost:8080/api';
  static const String _localWeb = 'http://localhost:8080/api';
  static const String _localDevice = 'http://172.16.16.46:8080/api'; // IP máy tính
  
  // ĐỔI URL THEO MÔI TRƯỜNG:
  // - Android Emulator: _localAndroidEmulator
  // - iOS Simulator: _localIosSimulator  
  // - Web Browser: _localWeb
  // - Điện thoại thật: _localDevice
  static const String baseUrl = _localWeb; // ĐỔI THEO THIẾT BỊ BẠN ĐANG DÙNG
  
  // API Endpoints
  static const String auth = '/auth';
  static const String users = '/users';
  static const String categories = '/categories';
  static const String shops = '/shops';
  static const String foodItems = '/food-items';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String reviews = '/reviews';
  
  // Auth endpoints
  static String get login => '$auth/login';
  static String get register => '$auth/register';
  static String get googleSignIn => '$auth/google';
  
  // Profile endpoints
  static const String profile = '/profile';
  static String profileById(int userId) => '$profile/$userId';
  static String changePassword(int userId) => '$profile/$userId/change-password';
  
  // User endpoints
  static String userById(int id) => '$users/$id';
  static String userByEmail(String email) => '$users/email/$email';
  static String usersByRole(String role) => '$users/role/$role';
  
  // Category endpoints
  static String categoryById(int id) => '$categories/$id';
  
  // Shop endpoints
  static String shopById(int id) => '$shops/$id';
  static String shopsByUser(int userId) => '$shops/user/$userId';
  static String shopsByCategory(int categoryId) => '$shops/category/$categoryId';
  static String get activeShops => '$shops/active';
  static String get topRatedShops => '$shops/top-rated';
  static String searchShops(String keyword) => '$shops/search?keyword=$keyword';
  
  // Food Item endpoints
  static String foodItemById(int id) => '$foodItems/$id';
  static String foodItemsByShop(int shopId) => '$foodItems/shop/$shopId';
  static String foodItemsByCategory(int categoryId) => '$foodItems/category/$categoryId';
  static String searchFoodItems(String keyword) => '$foodItems/search?keyword=$keyword';
  
  // Cart endpoints
  static String cartByUser(int userId) => '$cart/user/$userId';
  static String cartByUserAndShop(int userId, int shopId) => '$cart/user/$userId/shop/$shopId';
  static String cartItemById(int cartId) => '$cart/$cartId';
  
  // Order endpoints
  static String orderById(int id) => '$orders/$id';
  static String orderByCode(String code) => '$orders/code/$code';
  static String ordersByCustomer(int customerId) => '$orders/customer/$customerId';
  static String ordersByShop(int shopId) => '$orders/shop/$shopId';
  static String updateOrderStatus(int id) => '$orders/$id/status';
  static String cancelOrder(int id) => '$orders/$id/cancel';
  
  // Review endpoints
  static String reviewById(int id) => '$reviews/$id';
  static String reviewsByShop(int shopId) => '$reviews/shop/$shopId';
  static String reviewsByCustomer(int customerId) => '$reviews/customer/$customerId';
  static String replyToReview(int id) => '$reviews/$id/reply';
}
