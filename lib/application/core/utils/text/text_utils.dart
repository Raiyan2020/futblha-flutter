import 'package:flutter/material.dart';

TextSpan buildTextSpan({
  required String text,
  TextStyle? style,
  List<TextSpan>? children,
}) {
  return TextSpan(
    text: text,
    style: style,
    children: children,
  );
}
