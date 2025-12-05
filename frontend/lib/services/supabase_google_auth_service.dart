import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:supabase_flutter/supabase_flutter.dart';
import 'user_session.dart';

/// Supabase Google Authentication Service
class SupabaseGoogleAuthService {
  static final _supabase = Supabase.instance.client;
  
  /// Đăng nhập bằng Google qua Supabase
  static Future<Map<String, dynamic>> signInWithGoogle() async {
    try {
      // Đăng nhập Google qua Supabase OAuth
      final response = await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: 'io.supabase.foodapp://login-callback/', // Deep link cho mobile
      );
      
      if (response) {
        // Lấy user sau khi đăng nhập thành công
        final user = _supabase.auth.currentUser;
        
        if (user != null) {
          // Lưu vào UserSession
          UserSession.instance.setUser({
            'id': user.id.hashCode, // Supabase dùng UUID
            'email': user.email,
            'fullName': user.userMetadata?['full_name'] ?? user.email?.split('@')[0],
            'avatar': user.userMetadata?['avatar_url'],
            'phone': user.phone,
          }, authToken: _supabase.auth.currentSession?.accessToken);
          
          return {
            'success': true,
            'message': 'Đăng nhập Google thành công',
            'data': {
              'user': UserSession.instance.toProfileArgs(),
              'token': _supabase.auth.currentSession?.accessToken,
            },
          };
        }
      }
      
      return {
        'success': false,
        'message': 'Đăng nhập Google thất bại',
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi: $e',
      };
    }
  }
  
  /// Đăng nhập Google cho Web
  static Future<Map<String, dynamic>> signInWithGoogleWeb() async {
    try {
      await _supabase.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: kIsWeb ? null : 'io.supabase.foodapp://login-callback/',
      );
      
      // Web sẽ redirect, không trả về ngay
      return {
        'success': true,
        'message': 'Đang chuyển hướng...',
      };
      
    } catch (e) {
      return {
        'success': false,
        'message': 'Lỗi: $e',
      };
    }
  }
  
  /// Đăng xuất
  static Future<void> signOut() async {
    await _supabase.auth.signOut();
    UserSession.instance.clear();
  }
  
  /// Lấy user hiện tại
  static User? getCurrentUser() {
    return _supabase.auth.currentUser;
  }
  
  /// Kiểm tra đã đăng nhập chưa
  static bool isSignedIn() {
    return _supabase.auth.currentUser != null;
  }
  
  /// Lắng nghe thay đổi auth state
  static Stream<AuthState> get authStateChanges {
    return _supabase.auth.onAuthStateChange;
  }
}
