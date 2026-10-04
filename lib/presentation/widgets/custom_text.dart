import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as el;

class CustomText extends StatelessWidget {
  final String text;
  final TextStyle? style;
  final TextAlign? textAlign;
  final TextDirection? textDirection;
  final int? maxLines;
  const CustomText(
    this.text, {
    super.key,
    this.style,
    this.textAlign,
    this.maxLines,
    this.textDirection,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text.tr(),
      style: style ?? TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
      textAlign: textAlign,
      textDirection:
          textDirection ??
          (context.locale.languageCode == 'ar'
              ? TextDirection.rtl
              : TextDirection.ltr),
      maxLines: maxLines,
      overflow: TextOverflow.ellipsis,
      textScaler: TextScaler.noScaling,
    );
  }
}
