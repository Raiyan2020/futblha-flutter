import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../../application/config/design_system/app_colors.dart';
import '../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../custom_elevated_button.dart';

class ChangeLanguageBottomSheet extends StatelessWidget {
  final Function(String)
      onLanguageChanged; // Callback to notify the selected month

  const ChangeLanguageBottomSheet({super.key, required this.onLanguageChanged});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  LocaleKeys.change_language.tr(),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.primaryColor,
                      ),
                ),
                const Spacer(), // Add spacer to push the exit icon to the right
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () {
                    // Handle exit icon tap
                    Navigator.of(context)
                        .pop(); // Example: Close the bottom sheet
                  },
                ),
              ],
            ),
          ),
          Divider(
            color: AppColors.primaryGrey.withValues(alpha: 0.4),
            thickness: 1.0,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16,vertical: 16),
            child: Center(
              child: Text(LocaleKeys.change_language_message.tr(),
                  textAlign: TextAlign.center,
                  style: Theme.of(context).textTheme.headlineMedium),
            ),
          ),
          const SizedBox(height: 10),
          GestureDetector(
              onTap: () {
                Navigator.of(context).pop();
              },
              child: Center(
                child: Text(
                    LocaleKeys.cancel.tr(),
                    style:
                        Theme.of(context).textTheme.displayMedium?.copyWith(
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w700,
                            )),
              )),
          const SizedBox(height: 16),
          CustomElevatedButton(
            title:  LocaleKeys.restart_apply.tr(),
            onPressed: () {
              onLanguageChanged(CacheManager.instance.getLanguage() ?? 'en');
              Navigator.of(context).pop();
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class MonthListItem extends StatelessWidget {
  final String month;
  final VoidCallback? onTap;

  const MonthListItem({super.key, required this.month, this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(
        month,
        style: Theme.of(context).textTheme.titleMedium,
      ),
      onTap: onTap, // Execute the provided callback on tap
      // Add other onTap or other interactions as needed
    );
  }
}
