import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

import '../../../application/config/design_system/app_colors.dart';
import '../../../generated/locale_keys.g.dart';

class DurationFilterBottomSheet extends StatelessWidget {
  final Function(String)?
      onFilterSelected; // Callback to notify the selected month

  DurationFilterBottomSheet({super.key, this.onFilterSelected});

  final List<String> durations = [
    LocaleKeys.month.tr(),
    LocaleKeys.three_months.tr(),
    LocaleKeys.six_months.tr(),
    LocaleKeys.twelve_months.tr(),
  ];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 24),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Row(
              children: [
                Text(
                  LocaleKeys.select_duration.tr(),
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
          const SizedBox(height: 16),
          Divider(
            color: AppColors.primaryGrey.withValues(alpha: 0.4),
            thickness: 1.0,
          ),
          ListView.separated(
            shrinkWrap: true, // Set shrinkWrap to true
            itemCount: durations.length,
            itemBuilder: (context, index) {
              return MonthListItem(
                month: durations[index],
                onTap: () {
                  // Callback to notify the selected month
                  if (onFilterSelected != null) {
                    onFilterSelected!(durations[index]);
                  }
                  Navigator.of(context).pop();
                },
              );
            },
            separatorBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Divider(
                  color: AppColors.primaryGrey.withValues(alpha: 0.4),
                  thickness: 1.0,
                ),
              );
            },
          ),
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
