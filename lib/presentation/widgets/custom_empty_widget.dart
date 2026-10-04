import 'package:flutter/material.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

import '../../application/config/design_system/app_colors.dart';
import '../../generated/locale_keys.g.dart';
import 'custom_text.dart';

class EmptyWidget extends StatefulWidget {
  final Widget? icon;
  final String? text;
  const EmptyWidget({super.key, this.icon, this.text});

  @override
  State<EmptyWidget> createState() => _EmptyWidgetState();
}

class _EmptyWidgetState extends State<EmptyWidget> {
  bool _showWidget = false;

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _showWidget = true);
    });
  }

  @override
  Widget build(BuildContext context) {
    return !_showWidget
        ? const SizedBox()
        : Center(
            child: ListView(
              children: [
                widget.icon ?? const SizedBox(),
                10.heightBox(),
                CustomText(
                  widget.text ?? LocaleKeys.no_data_found,
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w700,
                      ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
  }
}
