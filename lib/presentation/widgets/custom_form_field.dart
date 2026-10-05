import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:easy_localization/easy_localization.dart' as el;

import '../../application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

typedef Validator = String? Function(String?);
typedef OnChanged = void Function(String);
typedef OnSubmit = void Function(String);
typedef OnTap = void Function();

class CustomFormField extends StatelessWidget {
  final bool isMandatory;
  final bool roundedBorder;
  final Key? currentKey;
  final String? initialValue;
  final String? fieldName;
  final String? hint;
  final Validator? validator;
  final TextEditingController? controller;
  final TextInputType? keyboardType;
  final bool hideText;
  final bool enabled;
  final Widget? suffixIcon;
  final Widget? prefixIcon;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;
  final int? minLines;
  final OnTap? onTap;
  final InputDecoration? decoration;
  final OnChanged? onChanged;
  final OnSubmit? onSubmit;
  final TextInputAction? textInputAction;
  final double borderRadius;

  const CustomFormField({
    super.key,
    this.isMandatory = false,
    this.roundedBorder = true,
    this.currentKey,
    this.initialValue,
    this.fieldName,
    this.hint,
    this.validator,
    this.controller,
    this.keyboardType,
    this.hideText = false,
    this.enabled = true,
    this.suffixIcon,
    this.prefixIcon,
    this.inputFormatters = const [],
    this.maxLength,
    this.minLines,
    this.onTap,
    this.decoration,
    this.borderRadius = 10,
    this.onChanged,
    this.onSubmit,
    this.textInputAction,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: TextFormField(
        minLines: minLines,
        maxLines: minLines == null ? 1 : 6,
        key: currentKey,
        enabled: enabled,
        inputFormatters: inputFormatters,
        controller: controller,
        validator: validator,
        keyboardType: keyboardType,
        obscureText: hideText,
        onChanged: onChanged,
        textInputAction: textInputAction,
        onFieldSubmitted: onSubmit,
        initialValue: initialValue,
        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
        decoration:
            decoration ??
            InputDecoration(
              prefixIcon: prefixIcon,
              suffixIcon: suffixIcon,
              fillColor: context.mutedBackground,
              filled: true,
              // isDense: true,
              labelText: fieldName?.tr(),
              hintText: hint?.tr(),
              floatingLabelBehavior: FloatingLabelBehavior.auto,
              labelStyle: const TextStyle(
                color: AppColors.primaryDarkGrey,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              hintStyle: const TextStyle(
                fontSize: 16,
                color: AppColors.primaryDarkGrey,
                fontWeight: FontWeight.w500,
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 50,
                minHeight: 30,
              ),
              suffixIconConstraints: const BoxConstraints(
                minWidth: 50,
                minHeight: 30,
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              border: inputBorder,
              enabledBorder: inputBorder,
              errorBorder: inputBorder.copyWith(
                borderSide: const BorderSide(color: Colors.red, width: 1),
              ),
              focusedBorder: inputBorder.copyWith(
                borderSide: const BorderSide(
                  color: AppColors.primaryColor,
                  width: 1.5,
                ),
              ),
              disabledBorder: inputBorder,
              focusedErrorBorder: inputBorder.copyWith(
                borderSide: const BorderSide(color: Colors.red, width: 1.5),
              ),
              errorStyle: const TextStyle(
                color: Colors.red,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
      ),
    );
  }

  InputBorder get inputBorder {
    return roundedBorder
        ? OutlineInputBorder(
            borderRadius: BorderRadius.circular(borderRadius),
            borderSide: BorderSide(
              color: AppColors.primaryColor.withValues(alpha: 0.2),
              width: 1,
            ),
          )
        : const UnderlineInputBorder(
            borderRadius: BorderRadius.zero,
            borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
          );
  }
}

class FieldName extends StatelessWidget {
  const FieldName({
    super.key,
    required this.fieldName,
    required this.isMandatory,
  });

  final String? fieldName;
  final bool isMandatory;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
      margin: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(10),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.02),
            spreadRadius: .1,
            blurRadius: 10,
            offset: const Offset(0, 0),
          ),
        ],
      ),
      child: RichText(
        text: TextSpan(
          style: DefaultTextStyle.of(context).style,
          children: [
            TextSpan(
              text: fieldName ?? '',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            if (isMandatory)
              const TextSpan(
                text: '*',
                style: TextStyle(color: AppColors.primaryRed),
              ),
          ],
        ),
      ),
    );
  }
}

class CountryCodePicker extends StatelessWidget {
  final String countryCode;
  final String flagPath;

  const CountryCodePicker({
    super.key,
    required this.countryCode,
    required this.flagPath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const SizedBox(width: 8),
        SvgPicture.asset(flagPath),
        const SizedBox(width: 8),
        Text(countryCode, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 8),
        Text("|", style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(width: 8),
      ],
    );
  }
}
