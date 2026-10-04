import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../presentation/widgets/scaffold_pading.dart';
import 'app_colors.dart';

class AppDecorations {
  static InputDecoration inputTextDecoration({
    String? hint,
    String? label,
    Widget? suffixIcon,
    Widget? suffix,
    Widget? prefix,
    Widget? prefixIcon,
    Color? fillColor,
    Color? borderColor,
    Color? focusedBorderColor,
    bool? isDense,
  }) => InputDecoration(
    prefixIconConstraints: const BoxConstraints(minHeight: 16, minWidth: 46),
    prefixIcon: prefixIcon,
    suffix: suffix,
    prefix: prefix,
    contentPadding: isDense == null
        ? const EdgeInsets.symmetric(horizontal: 16, vertical: 15)
        : symmetricPadding(12, 12),
    suffixIcon: suffixIcon,
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(width: 1.5, color: focusedBorderColor ?? AppColors.borderGrey),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(width: 1.5, color: borderColor ?? AppColors.borderGrey),
    ),
    disabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: BorderSide(width: 1.5, color: borderColor ?? AppColors.borderGrey),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.primaryRed),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12.0),
      borderSide: const BorderSide(color: AppColors.primaryRed),
    ),
    errorStyle: const TextStyle(
      color: AppColors.primaryRed,
      fontWeight: FontWeight.w400,
      height: 1.0,
      fontSize: 14.0,
    ),
    hintText: hint?.tr(),
    labelText: label,
    hintStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: AppColors.primaryDarkGrey.withValues(alpha: 0.5),
    ),
    // focusColor: AppColors.brownishGrey,
    filled: true,
    alignLabelWithHint: true,
    isDense: isDense,
    suffixStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryDarkGrey.withValues(alpha: 0.5),
    ),
    prefixStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w500,
      color: AppColors.primaryDarkGrey.withValues(alpha: 0.5),
    ),
    helperStyle: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, height: 0),
  );
}
