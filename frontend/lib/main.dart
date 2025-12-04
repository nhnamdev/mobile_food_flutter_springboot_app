import 'package:flutter/material.dart';
import 'config/app_theme.dart';
import 'screens/auth/welcome_screen.dart';
import 'screens/auth/sign_up_screen.dart';
import 'screens/auth/sign_in_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const FoodApp());
}

class FoodApp extends StatelessWidget {
  const FoodApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery App',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: '/',
      routes: {
        '/': (context) => const WelcomeScreen(),
        '/welcome': (context) => const WelcomeScreen(),
        '/signup': (context) => const SignUpScreen(),
        '/signin': (context) => const SignInScreen(),
        '/home': (context) => const HomeScreen(),
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
        return null;
      },
    );
  }
}


