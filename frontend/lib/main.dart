import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'config/app_theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/profile/addresses_screen.dart';
import 'screens/profile/order_history_screen.dart';
import 'screens/nearby/nearby_screen.dart';
import 'screens/favorites/favorites_screen.dart';
import 'screens/notifications/notifications_screen.dart';
import 'screens/cart/cart_screen.dart';
import 'screens/food_detail/food_detail_screen.dart';
import 'services/user_session.dart';
import 'services/user_sync_service.dart';
import 'services/local_cart_manager.dart';
import 'services/local_favorites_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Khởi tạo Supabase
  await Supabase.initialize(
    url: 'https://nwagwvwydcggsbxqiwbo.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im53YWd3dnd5ZGNnZ3NieHFpd2JvIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjQ4MzA2MjUsImV4cCI6MjA4MDQwNjYyNX0.4L_rGIaO0yKGmgy_0tG8-UitUmnTeBYESpaPB39UTq0',
  );
  
  // Load cart from local storage
  await LocalCartManager.instance.loadFromLocal();
  
  // Load favorites from local storage
  await LocalFavoritesManager.instance.init();
  
  runApp(const FoodApp());
}

class FoodApp extends StatefulWidget {
  const FoodApp({super.key});

  @override
  State<FoodApp> createState() => _FoodAppState();
}

class _FoodAppState extends State<FoodApp> {
  final _supabase = Supabase.instance.client;
  bool _isLoading = true;
  bool _isLoggedIn = false;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
    
    // Lắng nghe thay đổi auth state
    _supabase.auth.onAuthStateChange.listen((data) async {
      final event = data.event;
      final session = data.session;
      
      if (event == AuthChangeEvent.signedIn && session != null) {
        final user = session.user;
        
        // Sync user vào backend database
        final syncResult = await UserSyncService.syncGoogleUser(
          supabaseUid: user.id,
          email: user.email ?? '',
          fullName: user.userMetadata?['full_name'] ?? 
                   user.userMetadata?['name'] ?? 
                   user.email?.split('@')[0] ?? 'User',
          avatar: user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
          phone: user.phone,
        );
        
        // Lưu user vào session (dùng ID từ backend nếu sync thành công)
        int? backendUserId;
        if (syncResult['success'] == true && syncResult['user'] != null) {
          backendUserId = syncResult['user']['id'];
        }
        backendUserId ??= user.id.hashCode;
            
        UserSession.instance.setUser({
          'id': backendUserId,
          'supabaseUid': user.id,
          'email': user.email,
          'fullName': user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? user.email?.split('@')[0],
          'avatar': user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
          'phone': user.phone,
        }, authToken: session.accessToken);
        
        if (mounted) {
          setState(() {
            _isLoggedIn = true;
            _isLoading = false;
          });
        }
      } else if (event == AuthChangeEvent.signedOut) {
        UserSession.instance.clear();
        if (mounted) {
          setState(() {
            _isLoggedIn = false;
            _isLoading = false;
          });
        }
      }
    });
  }

  Future<void> _checkAuthState() async {
    final session = _supabase.auth.currentSession;
    
    if (session != null) {
      final user = session.user;
      
      // Sync user vào backend database
      final syncResult = await UserSyncService.syncGoogleUser(
        supabaseUid: user.id,
        email: user.email ?? '',
        fullName: user.userMetadata?['full_name'] ?? 
                 user.userMetadata?['name'] ?? 
                 user.email?.split('@')[0] ?? 'User',
        avatar: user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
        phone: user.phone,
      );
      
      // Lưu user vào session
      int? backendUserId;
      if (syncResult['success'] == true && syncResult['user'] != null) {
        backendUserId = syncResult['user']['id'];
      }
      backendUserId ??= user.id.hashCode;
          
      UserSession.instance.setUser({
        'id': backendUserId,
        'supabaseUid': user.id,
        'email': user.email,
        'fullName': user.userMetadata?['full_name'] ?? user.userMetadata?['name'] ?? user.email?.split('@')[0],
        'avatar': user.userMetadata?['avatar_url'] ?? user.userMetadata?['picture'],
        'phone': user.phone,
      }, authToken: session.accessToken);
      
      setState(() {
        _isLoggedIn = true;
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: _isLoading 
          ? const Scaffold(
              body: Center(
                child: CircularProgressIndicator(),
              ),
            )
          : _isLoggedIn 
              ? const HomeScreen() 
              : const WelcomeScreen(),
      routes: {
        '/welcome': (context) => const WelcomeScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/signin': (context) => const SignInScreen(),
        '/home': (context) => const HomeScreen(),
        '/nearby': (context) => const NearbyScreen(),
        '/favorites': (context) => const FavoritesScreen(),
        '/notifications': (context) => const NotificationsScreen(),
        '/cart': (context) => const CartScreen(),
        '/addresses': (context) => const AddressesScreen(),
        '/order-history': (context) => const OrderHistoryScreen(),
      },
      onGenerateRoute: (settings) {
        // Profile route với arguments
        if (settings.name == '/profile') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => ProfileScreen(
              userId: args?['userId'] ?? 0,
              initialName: args?['fullName'],
              initialEmail: args?['email'],
              initialPhone: args?['phone'],
              initialAvatar: args?['avatar'],
            ),
          );
        }
        // Food detail route
        if (settings.name == '/food-detail') {
          final args = settings.arguments as Map<String, dynamic>?;
          return MaterialPageRoute(
            builder: (context) => FoodDetailScreen(
              foodId: args?['foodId'] ?? 0,
              initialData: args?['initialData'],
            ),
          );
        }
        return null;
      },
    );
  }
}


