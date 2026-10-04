import 'package:flutter/material.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

import '../../../application/config/design_system/app_colors.dart';
import '../custom_circular_button.dart';
import '../custom_text.dart';
import '../scaffold_pading.dart';

class ContactUsBottomSheet extends StatelessWidget {
  const ContactUsBottomSheet({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: symmetricPadding(10, 20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              CustomText(
                LocaleKeys.contact_us,
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: AppColors.primaryColor,
                    ),
              ),
              IconButton(
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close))
            ],
          ),
        ),
        Padding(
          padding: symmetricPadding(30, 50),
          child: Column(
            children: [
              const CircularElevatedButton(
                title: LocaleKeys.request_call,
                filled: false,
              ),
              20.heightBox(),
              const CircularElevatedButton(title: LocaleKeys.call_us),
              20.heightBox(),
            ],
          ),
        ),
      ],
    );
  }
}
