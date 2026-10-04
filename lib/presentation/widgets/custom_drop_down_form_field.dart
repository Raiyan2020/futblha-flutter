import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../application/config/design_system/app_colors.dart';
import '../../generated/locale_keys.g.dart';

class CustomDropdownFormField<T> extends StatelessWidget {
  final String fieldName;
  final bool isMandatory;
  final bool enabled;
  final List<T?>? items;
  final void Function(T?)? onChanged;
  final String Function(T?) displayTextFunction; // Added displayTextFunction

  const CustomDropdownFormField({super.key,
    required this.fieldName,
    this.isMandatory = true,
    required this.enabled,
    required this.items,
    required this.onChanged,
    required this.displayTextFunction, // Initialize displayTextFunction
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: fieldName ,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              if (!isMandatory)
                TextSpan(
                  text: LocaleKeys.optional.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryGrey,
                  ),
                ),
            ],
          ),
        ),
        const SizedBox(height: 4),
        DropdownButtonFormField<T?>(
          initialValue: null, // Set the initial value or use a controller
          items: (items ?? []).map((T? value) {
            return DropdownMenuItem<T?>(
              value: value,
              child: Text(
                displayTextFunction.call(value) ,
              ),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ],
    );
  }
}
