import 'package:flutter/material.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';


class AppHeightBox extends StatelessWidget {
  final num height;

  const AppHeightBox({super.key, required this.height});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height.h,
    );
  }
}

class AppWidthBox extends StatelessWidget {
  final num width;
  const AppWidthBox({super.key, required this.width});
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width.w,
    );
  }
}

extension Boxes on num {
  Widget widthBox() {
    return AppWidthBox(width: this);
  }

  Widget heightBox() {
    return AppHeightBox(height: this);
  }
}
