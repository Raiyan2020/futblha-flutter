import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:flutter/material.dart';


class ScaffoldPadding extends StatelessWidget {
  final Widget child;
  final double? bottomPadding;
  const ScaffoldPadding({required this.child, this.bottomPadding, super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        right: 16.w,
        left: 16.w,
        top: MediaQuery.of(context).padding.top,
        bottom: bottomPadding ?? 0,
      ),
      child: child,
    );
  }
}

EdgeInsets symmetricPadding(num height, num width) {
  return EdgeInsets.symmetric(
    horizontal: width.w,
    vertical: height.h,
  );
}
