import 'package:flutter/material.dart';

import '../../application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

class CustomTabBar extends StatelessWidget {
  final String text;
  final bool isSelected;
  final VoidCallback onTap;

  const CustomTabBar({super.key, required this.text, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: isSelected ? AppColors.primaryColor : AppColors.primaryGrey.withValues(alpha: 0.4),
              width: 1.0, // Adjust the thickness of the underline
            ),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(fontSize: 16.0, color: isSelected ? context.brandOnSurface : context.textPrimary),
          ),
        ),
      ),
    );
  }
}
