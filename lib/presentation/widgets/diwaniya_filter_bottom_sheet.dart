import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

class DiwaniyaFilterBottomSheet {
  static Future<DiwaniyaFilterResult?> show(
    BuildContext context, {
    DiwaniyaFilterResult? initialFilters,
  }) async {
    final types = [LocaleKeys.public.tr(), LocaleKeys.private.tr()];
    final levels = [LocaleKeys.beginner.tr(), LocaleKeys.intermediate.tr(), LocaleKeys.advanced.tr()];
    String? selectedType = types.contains(initialFilters?.type) ? initialFilters?.type : null;
    String? selectedLevel = initialFilters?.level;
    final TextEditingController membersController = TextEditingController(
      text: initialFilters?.membersCount?.toString() ?? '',
    );
    DiwaniyaFilterResult? result;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16.w,
            right: 16.w,
          ),
          child: StatefulBuilder(
            builder: (context, setState) {
              return Container(
                margin: EdgeInsets.only(top: 32.h),
                decoration: BoxDecoration(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            LocaleKeys.diwaniyat_filter.tr(),
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                          ),
                          IconButton(
                            onPressed: () => Navigator.pop(context),
                            icon: const Icon(Icons.close),
                          ),
                        ],
                      ),
                      16.heightBox(),
                      Text(
                        LocaleKeys.diwaniya_type.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      6.heightBox(),
                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration: _filterFieldDecoration(LocaleKeys.select_type.tr()),
                        items: types
                            .map((type) => DropdownMenuItem<String>(value: type, child: Text(type)))
                            .toList(),
                        onChanged: (value) => setState(() => selectedType = value),
                      ),
                      12.heightBox(),
                      Text(
                        LocaleKeys.number_of_members.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      6.heightBox(),
                      TextField(
                        controller: membersController,
                        keyboardType: TextInputType.number,
                        decoration: _filterFieldDecoration(LocaleKeys.enter_number.tr()),
                      ),
                      12.heightBox(),
                      Text(
                        LocaleKeys.diwaniya_level.tr(),
                        style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      6.heightBox(),
                      DropdownButtonFormField<String>(
                        initialValue: selectedLevel,
                        decoration: _filterFieldDecoration(LocaleKeys.select_level.tr()),
                        items: levels
                            .map(
                              (level) => DropdownMenuItem<String>(value: level, child: Text(level)),
                            )
                            .toList(),
                        onChanged: (value) => setState(() => selectedLevel = value),
                      ),
                      20.heightBox(),
                      Row(
                        children: [
                          if (selectedType != null ||
                              selectedLevel != null ||
                              membersController.text.isNotEmpty)
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () {
                                  selectedType = null;
                                  selectedLevel = null;
                                  membersController.clear();
                                  setState(() {});
                                },
                                style: OutlinedButton.styleFrom(
                                  padding: EdgeInsets.symmetric(vertical: 14.h),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  side: BorderSide(color: AppColors.primaryColor),
                                ),
                                child: Text(
                                  LocaleKeys.clear_all.tr(),
                                  style: TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ),
                          if (selectedType != null ||
                              selectedLevel != null ||
                              membersController.text.isNotEmpty)
                            12.widthBox(),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                result = DiwaniyaFilterResult(
                                  type: selectedType,
                                  level: selectedLevel,
                                  membersCount: membersController.text.isNotEmpty
                                      ? int.tryParse(membersController.text)
                                      : null,
                                );
                                Navigator.pop(context, result);
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primaryColor,
                                padding: EdgeInsets.symmetric(vertical: 14.h),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: Text(
                                LocaleKeys.show_results.tr(),
                                style: const TextStyle(
                                  color: AppColors.primaryWhite,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        );
      },
    );
    return result;
  }

  static InputDecoration _filterFieldDecoration(String hint) {
    return InputDecoration(
      hintText: hint,
      filled: true,
      contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.secondaryColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.primaryColor),
      ),
    );
  }
}

class DiwaniyaFilterResult {
  final String? type; // Localized string: "Public", "Private", "Friendly"
  final String? level; // Localized string: "Beginner", "Intermediate", "Advanced"
  final int? membersCount;

  DiwaniyaFilterResult({
    this.type,
    this.level,
    this.membersCount,
  });

  // Convert localized type string to API value
  String? getApiType() {
    if (type == null) return null;
    // Compare with localized strings
    final public = LocaleKeys.public.tr();
    final private = LocaleKeys.private.tr();
    final friendly = LocaleKeys.friendly.tr();
    if (type == public) return 'public';
    if (type == private) return 'private';
    if (type == friendly) return 'friendly';
    return null;
  }

  // Convert localized level string to rating (1-5)
  int? getApiRating() {
    if (level == null) return null;
    // Compare with localized strings
    final beginner = LocaleKeys.beginner.tr();
    final intermediate = LocaleKeys.intermediate.tr();
    final advanced = LocaleKeys.advanced.tr();
    if (level == beginner) return 1;
    if (level == intermediate) return 3;
    if (level == advanced) return 5;
    return null;
  }

  bool get hasFilters => type != null || level != null || membersCount != null;
}
