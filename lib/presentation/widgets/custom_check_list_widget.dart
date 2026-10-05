import 'package:flutter/material.dart';

import '../../application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

class CustomCheckListWidget<T> extends StatefulWidget {
  final String sectionTitle;
  final bool isDefaultSelected;
  final List<T?>? choices; // Accept nullable list
  final Function(List<T>)? onSelectionChanged;
  final String Function(T) displayTextProvider;

  const CustomCheckListWidget({
    super.key,
    required this.sectionTitle,
    required this.isDefaultSelected,
    required this.choices,
    required this.displayTextProvider,
    this.onSelectionChanged,
  });

  @override
  _CustomCheckListWidgetState<T> createState() => _CustomCheckListWidgetState<T>();
}

class _CustomCheckListWidgetState<T> extends State<CustomCheckListWidget<T>> {
  List<T> selectedItems = [];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          widget.sectionTitle,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        const SizedBox(
          height: 4.0,
        ),
        Container(
          decoration: BoxDecoration(
            color: AppColors.primaryColor.withValues(alpha: 0.05),
            borderRadius: BorderRadius.circular(
                4.0), // Adjust the radius as needed// Change to your desired light green color
          ),
          child: ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: widget.choices?.length ?? 0, // Use null-aware operator
            itemBuilder: (BuildContext context, int index) {
              T choice = widget.choices?[index] as T; // Use null-aware operator

              return Column(
                children: [
                  ListTile(
                    title: Row(
                      children: [
                        Expanded(
                          child: Text(
                            widget.displayTextProvider(choice),
                            // Adjust based on your data structure
                            style: Theme.of(context).textTheme.labelLarge,
                          ),
                        ),
                        Container(
                          width: 24.0,
                          height: 24.0,
                          decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: Border.all(
                                  color: selectedItems.contains(choice)
                                      ? AppColors.primaryColor
                                      : AppColors.primaryGrey),
                              color: !widget.isDefaultSelected
                                  ? selectedItems.contains(choice)
                                      ? AppColors.primaryColor
                                      : context.cardBackground
                                  : AppColors.primaryGrey),
                          child: const Center(
                            child: Icon(
                              Icons.check,
                              size: 16.0,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                    onTap: () {
                      if (widget.isDefaultSelected) return;
                      if (choice != null) {
                        setState(() {
                          if (selectedItems.contains(choice)) {
                            selectedItems.remove(choice);
                          } else {
                            selectedItems.add(choice);
                          }
                        });
                      }
                      widget.onSelectionChanged!(selectedItems);
                    },
                  ),
                  if (index != (widget.choices?.length ?? 0) - 1)
                    Divider(
                      color: context.cardBackground, // Change to your desired divider color
                      thickness: 1.0,
                    ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}
