import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../application/config/design_system/app_colors.dart';

typedef OnTap = void Function();

class ClickableTextField extends StatelessWidget {
  final OnTap? onTap;

  final String text;
  final String icon;

  const ClickableTextField({super.key, this.onTap, required this.text, required this.icon});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12.0),
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.primaryGrey,
          ),
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                text,
                style: Theme.of(context).textTheme.headlineMedium,
              ),
            ),
            SvgPicture.asset(icon), // Replace with your desired icon
          ],
        ),
      ),
    );
  }
}
