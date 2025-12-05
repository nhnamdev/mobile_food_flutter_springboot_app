import 'package:flutter/material.dart';
import '../../config/app_theme.dart';

class CategoryChip extends StatelessWidget {
  final String name;
  final String? iconUrl;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.name,
    this.iconUrl,
    this.isSelected = false,
    this.onTap,
  });

  // Get first letter or abbreviation for category
  String _getCategoryLetter() {
    final lowerName = name.toLowerCase();
    if (lowerName.contains('tất cả') || lowerName.contains('all')) {
      return '⊞';
    }
    // Return first letter uppercase
    if (name.isNotEmpty) {
      return name[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(right: 12),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : AppColors.white,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: isSelected 
                  ? AppColors.primaryColor.withOpacity(0.3)
                  : const Color(0xFFD3D1D8).withOpacity(0.25),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Category letter box
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.white.withOpacity(0.2) 
                    : AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Center(
                child: Text(
                  _getCategoryLetter(),
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: isSelected ? AppColors.white : AppColors.primaryColor,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? AppColors.white : AppColors.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
