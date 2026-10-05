import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:flutter/material.dart';

import '../../application/config/design_system/app_colors.dart';
import '../../application/core/utils/helpers/keyboard/keyboard_helper.dart';
import 'custom_text.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

class CustomElevatedButton extends StatelessWidget {
  final String title;
  final bool isEnabled;
  final bool filled;
  final VoidCallback? onPressed;
  final Color color;
  final Color textColor;
  final double? width;

  const CustomElevatedButton({
    super.key,
    required this.title,
    this.isEnabled = true,
    this.filled = true,
    this.onPressed,
    this.color = AppColors.primaryColor,
    this.textColor = AppColors.primaryWhite,
    this.width,
  });

  @override
  Widget build(BuildContext context, {BorderRadius? borderRadius}) {
    return ElevatedButton(
      onPressed: isEnabled
          ? () {
              onPressed?.call();
              KeyboardHelper.hideKeyboard(context);
            }
          : null,
      style: ElevatedButton.styleFrom(
        backgroundColor: filled ? color : context.cardBackground,
        minimumSize: const Size(0, 0),
        fixedSize: Size(width ?? MediaQuery.of(context).size.width, 45.h),
        //  padding: symmetricPadding(15, 25),
        visualDensity: VisualDensity.compact,
        shape: RoundedRectangleBorder(
          side: BorderSide(
            color: !isEnabled
                ? AppColors.primaryGrey
                : filled
                ? color
                : AppColors.primaryGrey,
            width: 1,
          ),
          borderRadius: borderRadius ?? BorderRadius.circular(10),
        ),
      ),
      child: CustomText(
        title,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: filled
              ? isEnabled
                    ? textColor
                    : AppColors.primaryWhite
              : AppColors.primaryDarkGrey,
        ),
      ),
    );
  }
}
