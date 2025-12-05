import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Singleton manager để quản lý cài đặt ứng dụng
class SettingsManager extends ChangeNotifier {
  static final SettingsManager _instance = SettingsManager._internal();
  static SettingsManager get instance => _instance;
  
  SettingsManager._internal();
  
  SharedPreferences? _prefs;
  bool _initialized = false;
  
  // Keys
  static const String _keyNotifications = 'settings_notifications';
  static const String _keyOrderUpdates = 'settings_order_updates';
  static const String _keyPromotions = 'settings_promotions';
  static const String _keyNewRestaurants = 'settings_new_restaurants';
  static const String _keyDarkMode = 'settings_dark_mode';
  static const String _keyLanguage = 'settings_language';
  static const String _keyDistanceUnit = 'settings_distance_unit';
  static const String _keyAutoPlayVideo = 'settings_autoplay_video';
  static const String _keySaveSearchHistory = 'settings_save_search_history';
  static const String _keyDefaultPayment = 'settings_default_payment';
  static const String _keyLocationServices = 'settings_location_services';
  static const String _keyBiometricLogin = 'settings_biometric_login';
  
  // Cached values
  bool _notifications = true;
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _newRestaurants = false;
  bool _darkMode = false;
  String _language = 'vi';
  String _distanceUnit = 'km';
  bool _autoPlayVideo = true;
  bool _saveSearchHistory = true;
  String _defaultPayment = 'cash';
  bool _locationServices = true;
  bool _biometricLogin = false;
  
  // Getters
  bool get notifications => _notifications;
  bool get orderUpdates => _orderUpdates;
  bool get promotions => _promotions;
  bool get newRestaurants => _newRestaurants;
  bool get darkMode => _darkMode;
  String get language => _language;
  String get distanceUnit => _distanceUnit;
  bool get autoPlayVideo => _autoPlayVideo;
  bool get saveSearchHistory => _saveSearchHistory;
  String get defaultPayment => _defaultPayment;
  bool get locationServices => _locationServices;
  bool get biometricLogin => _biometricLogin;
  bool get isInitialized => _initialized;
  
  /// Khởi tạo và load settings từ SharedPreferences
  Future<void> init() async {
    if (_initialized) return;
    
    _prefs = await SharedPreferences.getInstance();
    
    _notifications = _prefs?.getBool(_keyNotifications) ?? true;
    _orderUpdates = _prefs?.getBool(_keyOrderUpdates) ?? true;
    _promotions = _prefs?.getBool(_keyPromotions) ?? true;
    _newRestaurants = _prefs?.getBool(_keyNewRestaurants) ?? false;
    _darkMode = _prefs?.getBool(_keyDarkMode) ?? false;
    _language = _prefs?.getString(_keyLanguage) ?? 'vi';
    _distanceUnit = _prefs?.getString(_keyDistanceUnit) ?? 'km';
    _autoPlayVideo = _prefs?.getBool(_keyAutoPlayVideo) ?? true;
    _saveSearchHistory = _prefs?.getBool(_keySaveSearchHistory) ?? true;
    _defaultPayment = _prefs?.getString(_keyDefaultPayment) ?? 'cash';
    _locationServices = _prefs?.getBool(_keyLocationServices) ?? true;
    _biometricLogin = _prefs?.getBool(_keyBiometricLogin) ?? false;
    
    _initialized = true;
    notifyListeners();
  }
  
  // Setters with persistence
  Future<void> setNotifications(bool value) async {
    _notifications = value;
    await _prefs?.setBool(_keyNotifications, value);
    notifyListeners();
  }
  
  Future<void> setOrderUpdates(bool value) async {
    _orderUpdates = value;
    await _prefs?.setBool(_keyOrderUpdates, value);
    notifyListeners();
  }
  
  Future<void> setPromotions(bool value) async {
    _promotions = value;
    await _prefs?.setBool(_keyPromotions, value);
    notifyListeners();
  }
  
  Future<void> setNewRestaurants(bool value) async {
    _newRestaurants = value;
    await _prefs?.setBool(_keyNewRestaurants, value);
    notifyListeners();
  }
  
  Future<void> setDarkMode(bool value) async {
    _darkMode = value;
    await _prefs?.setBool(_keyDarkMode, value);
    notifyListeners();
  }
  
  Future<void> setLanguage(String value) async {
    _language = value;
    await _prefs?.setString(_keyLanguage, value);
    notifyListeners();
  }
  
  Future<void> setDistanceUnit(String value) async {
    _distanceUnit = value;
    await _prefs?.setString(_keyDistanceUnit, value);
    notifyListeners();
  }
  
  Future<void> setAutoPlayVideo(bool value) async {
    _autoPlayVideo = value;
    await _prefs?.setBool(_keyAutoPlayVideo, value);
    notifyListeners();
  }
  
  Future<void> setSaveSearchHistory(bool value) async {
    _saveSearchHistory = value;
    await _prefs?.setBool(_keySaveSearchHistory, value);
    notifyListeners();
  }
  
  Future<void> setDefaultPayment(String value) async {
    _defaultPayment = value;
    await _prefs?.setString(_keyDefaultPayment, value);
    notifyListeners();
  }
  
  Future<void> setLocationServices(bool value) async {
    _locationServices = value;
    await _prefs?.setBool(_keyLocationServices, value);
    notifyListeners();
  }
  
  Future<void> setBiometricLogin(bool value) async {
    _biometricLogin = value;
    await _prefs?.setBool(_keyBiometricLogin, value);
    notifyListeners();
  }
  
  /// Xóa lịch sử tìm kiếm
  Future<void> clearSearchHistory() async {
    await _prefs?.remove('search_history');
  }
  
  /// Xóa cache ứng dụng
  Future<void> clearCache() async {
    // Clear các cached data
    await _prefs?.remove('cached_foods');
    await _prefs?.remove('cached_shops');
    await _prefs?.remove('cached_categories');
  }
  
  /// Reset tất cả cài đặt về mặc định
  Future<void> resetToDefaults() async {
    _notifications = true;
    _orderUpdates = true;
    _promotions = true;
    _newRestaurants = false;
    _darkMode = false;
    _language = 'vi';
    _distanceUnit = 'km';
    _autoPlayVideo = true;
    _saveSearchHistory = true;
    _defaultPayment = 'cash';
    _locationServices = true;
    _biometricLogin = false;
    
    // Save all defaults
    await _prefs?.setBool(_keyNotifications, _notifications);
    await _prefs?.setBool(_keyOrderUpdates, _orderUpdates);
    await _prefs?.setBool(_keyPromotions, _promotions);
    await _prefs?.setBool(_keyNewRestaurants, _newRestaurants);
    await _prefs?.setBool(_keyDarkMode, _darkMode);
    await _prefs?.setString(_keyLanguage, _language);
    await _prefs?.setString(_keyDistanceUnit, _distanceUnit);
    await _prefs?.setBool(_keyAutoPlayVideo, _autoPlayVideo);
    await _prefs?.setBool(_keySaveSearchHistory, _saveSearchHistory);
    await _prefs?.setString(_keyDefaultPayment, _defaultPayment);
    await _prefs?.setBool(_keyLocationServices, _locationServices);
    await _prefs?.setBool(_keyBiometricLogin, _biometricLogin);
    
    notifyListeners();
  }
  
  String get languageDisplayName {
    switch (_language) {
      case 'vi':
        return 'Tiếng Việt';
      case 'en':
        return 'English';
      default:
        return 'Tiếng Việt';
    }
  }
  
  String get paymentDisplayName {
    switch (_defaultPayment) {
      case 'cash':
        return 'Tiền mặt';
      case 'momo':
        return 'MoMo';
      case 'zalopay':
        return 'ZaloPay';
      case 'vnpay':
        return 'VNPay';
      case 'card':
        return 'Thẻ ngân hàng';
      default:
        return 'Tiền mặt';
    }
  }
}
