import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../application/config/design_system/app_colors.dart';

typedef OnTap = void Function();

class CustomCardWidget extends StatelessWidget {
  final String title;
  final String? iconPath;
  final bool showDot;
  final OnTap? onTap;

  const CustomCardWidget({super.key, 
    required this.title,
    this.iconPath,
    this.showDot = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 160,
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          color: AppColors.primaryColor.withValues(alpha: 0.06),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 8),
                SvgPicture.asset(
                  iconPath!,
                  height: 40,
                  width: 40,
                  colorFilter:
                      const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
                ),
                const Spacer(),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 8),
              ],
            ),
            if (showDot)
              const Positioned(
                top: 4,
                right: 4,
                child: CircleAvatar(
                  radius: 4,
                  backgroundColor: Colors.red, // Customize the dot color
                ),
              ),
          ],
        ),
      ),
    );
  }
}
