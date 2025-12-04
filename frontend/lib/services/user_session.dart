/// User Session - Lưu trữ thông tin user đang đăng nhập
class UserSession {
  static UserSession? _instance;
  
  int? userId;
  String? email;
  String? fullName;
  String? phone;
  String? avatar;
  String? token;
  
  UserSession._();
  
  static UserSession get instance {
    _instance ??= UserSession._();
    return _instance!;
  }
  
  /// Lưu thông tin user từ response login
  void setUser(Map<String, dynamic> userData, {String? authToken}) {
    userId = userData['id'];
    email = userData['email'];
    fullName = userData['fullName'];
    phone = userData['phone'];
    avatar = userData['avatar'];
    if (authToken != null) {
      token = authToken;
    }
  }
  
  /// Kiểm tra đã đăng nhập chưa
  bool get isLoggedIn => userId != null && token != null;
  
  /// Xóa session khi logout
  void clear() {
    userId = null;
    email = null;
    fullName = null;
    phone = null;
    avatar = null;
    token = null;
  }
  
  /// Lấy thông tin để truyền vào ProfileScreen
  Map<String, dynamic> toProfileArgs() {
    return {
      'userId': userId ?? 0,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
    };
  }
}
