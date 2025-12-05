import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Service quản lý favorites local với sync lên server
class LocalFavoritesManager {
  static final LocalFavoritesManager _instance = LocalFavoritesManager._internal();
  static LocalFavoritesManager get instance => _instance;
  
  LocalFavoritesManager._internal();
  
  static const String _foodFavoritesKey = 'food_favorites';
  static const String _shopFavoritesKey = 'shop_favorites';
  
  Set<int> _foodFavorites = {};
  Set<int> _shopFavorites = {};
  bool _isInitialized = false;
  
  /// Khởi tạo và load từ local storage
  Future<void> init() async {
    if (_isInitialized) return;
    
    final prefs = await SharedPreferences.getInstance();
    
    // Load food favorites
    final foodFavJson = prefs.getString(_foodFavoritesKey);
    if (foodFavJson != null) {
      final List<dynamic> foodList = jsonDecode(foodFavJson);
      _foodFavorites = foodList.map((e) => e as int).toSet();
    }
    
    // Load shop favorites
    final shopFavJson = prefs.getString(_shopFavoritesKey);
    if (shopFavJson != null) {
      final List<dynamic> shopList = jsonDecode(shopFavJson);
      _shopFavorites = shopList.map((e) => e as int).toSet();
    }
    
    _isInitialized = true;
  }
  
  /// Lưu vào local storage
  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_foodFavoritesKey, jsonEncode(_foodFavorites.toList()));
    await prefs.setString(_shopFavoritesKey, jsonEncode(_shopFavorites.toList()));
  }
  
  /// Kiểm tra món ăn có được yêu thích không
  bool isFoodFavorite(int foodId) {
    return _foodFavorites.contains(foodId);
  }
  
  /// Kiểm tra cửa hàng có được yêu thích không
  bool isShopFavorite(int shopId) {
    return _shopFavorites.contains(shopId);
  }
  
  /// Toggle yêu thích món ăn
  Future<bool> toggleFoodFavorite(int foodId) async {
    await init();
    
    if (_foodFavorites.contains(foodId)) {
      _foodFavorites.remove(foodId);
    } else {
      _foodFavorites.add(foodId);
    }
    
    await _save();
    
    // TODO: Sync với server nếu user đã đăng nhập
    _syncWithServer('food', foodId, _foodFavorites.contains(foodId));
    
    return _foodFavorites.contains(foodId);
  }
  
  /// Toggle yêu thích cửa hàng
  Future<bool> toggleShopFavorite(int shopId) async {
    await init();
    
    if (_shopFavorites.contains(shopId)) {
      _shopFavorites.remove(shopId);
    } else {
      _shopFavorites.add(shopId);
    }
    
    await _save();
    
    // TODO: Sync với server nếu user đã đăng nhập
    _syncWithServer('shop', shopId, _shopFavorites.contains(shopId));
    
    return _shopFavorites.contains(shopId);
  }
  
  /// Thêm vào yêu thích
  Future<void> addFoodFavorite(int foodId) async {
    await init();
    _foodFavorites.add(foodId);
    await _save();
    _syncWithServer('food', foodId, true);
  }
  
  /// Xóa khỏi yêu thích
  Future<void> removeFoodFavorite(int foodId) async {
    await init();
    _foodFavorites.remove(foodId);
    await _save();
    _syncWithServer('food', foodId, false);
  }
  
  /// Lấy danh sách food favorites
  Set<int> get foodFavorites => Set.from(_foodFavorites);
  
  /// Lấy danh sách shop favorites
  Set<int> get shopFavorites => Set.from(_shopFavorites);
  
  /// Số lượng favorites
  int get totalFavorites => _foodFavorites.length + _shopFavorites.length;
  int get foodFavoritesCount => _foodFavorites.length;
  int get shopFavoritesCount => _shopFavorites.length;
  
  /// Sync với server (background, không block UI)
  Future<void> _syncWithServer(String type, int itemId, bool isFavorite) async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      
      // TODO: Implement API call to sync favorites
      // final response = await http.post(
      //   Uri.parse('${ApiConfig.baseUrl}/favorites'),
      //   body: jsonEncode({
      //     'userId': user.id,
      //     'type': type,
      //     'itemId': itemId,
      //     'isFavorite': isFavorite,
      //   }),
      // );
    } catch (e) {
      // Silent fail - local data is the source of truth
      print('Failed to sync favorite: $e');
    }
  }
  
  /// Load favorites từ server (khi user login)
  Future<void> syncFromServer() async {
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user == null) return;
      
      // TODO: Implement API call to get favorites from server
      // final response = await http.get(
      //   Uri.parse('${ApiConfig.baseUrl}/favorites/${user.id}'),
      // );
      // if (response.statusCode == 200) {
      //   final data = jsonDecode(response.body);
      //   _foodFavorites = (data['foods'] as List).map((e) => e['id'] as int).toSet();
      //   _shopFavorites = (data['shops'] as List).map((e) => e['id'] as int).toSet();
      //   await _save();
      // }
    } catch (e) {
      print('Failed to sync favorites from server: $e');
    }
  }
  
  /// Xóa tất cả favorites (khi logout)
  Future<void> clear() async {
    _foodFavorites.clear();
    _shopFavorites.clear();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_foodFavoritesKey);
    await prefs.remove(_shopFavoritesKey);
  }
}
