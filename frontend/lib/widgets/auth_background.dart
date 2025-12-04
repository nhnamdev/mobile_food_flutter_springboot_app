import 'package:flutter/material.dart';

class AuthBackground extends StatelessWidget {
  final Widget child;
  
  const AuthBackground({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    
    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // Top right circle
          Positioned(
            top: -120,
            right: -80,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFE724C),
              ),
            ),
          ),
          
          // Top right smaller circle
          Positioned(
            top: 50,
            right: -20,
            child: Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFE724C).withOpacity(0.2),
              ),
            ),
          ),
          
          // Bottom left circle
          Positioned(
            bottom: -100,
            left: -100,
            child: Container(
              width: 250,
              height: 250,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFFFE724C),
              ),
            ),
          ),
          
          // Bottom left smaller circle
          Positioned(
            bottom: 80,
            left: -30,
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFFE724C).withOpacity(0.2),
              ),
            ),
          ),
          
          // Top left yellow circle (partial)
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFF8B64C).withOpacity(0.2),
              ),
            ),
          ),
          
          // Main content
          child,
        ],
      ),
    );
  }
}
