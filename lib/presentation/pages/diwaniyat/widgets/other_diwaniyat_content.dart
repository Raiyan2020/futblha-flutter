import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/diwaniya/diwaniya_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/diwaniyat/widgets/diwaniya_card.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/pagination_list.dart';

class OtherDiwaniyatContent extends StatelessWidget {
  final List<DiwaniyaModel>? diwaniyas;
  final TextEditingController searchController;
  final String searchQuery;
  final bool hasActiveFilters;
  final bool hasMorePages;
  final bool isLoading;
  final VoidCallback onSearchChanged;
  final VoidCallback onFilterPressed;
  final VoidCallback onClearSearch;
  final VoidCallback onLoadMore;
  final Function(DiwaniyaModel) onDiwaniyaTap;

  const OtherDiwaniyatContent({
    super.key,
    required this.diwaniyas,
    required this.searchController,
    required this.searchQuery,
    required this.hasActiveFilters,
    required this.hasMorePages,
    this.isLoading = false,
    required this.onSearchChanged,
    required this.onFilterPressed,
    required this.onClearSearch,
    required this.onLoadMore,
    required this.onDiwaniyaTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Search and Filter Row
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: searchController,
                  onChanged: (_) => onSearchChanged(),
                  decoration: InputDecoration(
                    hintText: LocaleKeys.search.tr(),
                    hintStyle: TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                    prefixIcon: Icon(Icons.search, color: AppColors.lightTextColor, size: 20),
                    suffixIcon: searchQuery.isNotEmpty
                        ? IconButton(
                            icon: Icon(Icons.clear, color: AppColors.lightTextColor, size: 20),
                            onPressed: onClearSearch,
                          )
                        : null,
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                  ),
                ),
              ),
              12.widthBox(),
              Stack(
                children: [
                  Container(
                    width: 48.w,
                    height: 48.h,
                    decoration: BoxDecoration(
                      color: hasActiveFilters ? AppColors.primaryColor : context.chipBackground,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: onFilterPressed,
                      icon: Icon(
                        Icons.filter_list,
                        color: hasActiveFilters ? AppColors.primaryWhite : context.brandOnSurface,
                        size: 24,
                      ),
                    ),
                  ),
                  if (hasActiveFilters)
                    Positioned(
                      right: 6,
                      top: 6,
                      child: Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: AppColors.primaryRed,
                          shape: BoxShape.circle,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        16.heightBox(),
        // Diwaniya List with Pagination. Only the list shows loading, so the
        // search field stays mounted and keeps focus while a search runs.
        isLoading
            ? const Expanded(child: LoadingWidget())
            : diwaniyas != null && diwaniyas!.isNotEmpty
            ? Expanded(
                child: PaginationList(
                  itemCount: diwaniyas!.length,
                  onReachBottom: onLoadMore,
                  reachedMax: !hasMorePages,
                  shrinkWrap: false,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  separator: 12.heightBox(),
                  itemBuilder: (context, index) {
                    final diwaniya = diwaniyas![index];
                    return InkWell(
                      onTap: () => onDiwaniyaTap(diwaniya),
                      child: DiwaniyaCard(diwaniya: diwaniya),
                    );
                  },
                ),
              )
            : Expanded(
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32.0),
                    child: Text(
                      LocaleKeys.no_diwaniyas_found.tr(),
                      style: const TextStyle(color: AppColors.lightTextColor, fontSize: 16),
                    ),
                  ),
                ),
              ),
      ],
    );
  }
}
