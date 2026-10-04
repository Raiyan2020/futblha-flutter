import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/diwaniya/diwaniya_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

class DiwaniyaCard extends StatelessWidget {
  final DiwaniyaModel diwaniya;

  const DiwaniyaCard({super.key, required this.diwaniya});

  Widget _buildStarRating(int rating) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (index) => Icon(
          index < rating ? Icons.star : Icons.star_border,
          size: 14,
          color: index < rating ? AppColors.primaryYellow : AppColors.primaryGrey,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Row(
        children: [
          // Circular Image
          Container(
            width: 80.w,
            height: 80.h,
            decoration: BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLiteGrey),
            child: ClipOval(
              child: Image.network(
                diwaniya.image ?? '',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [
                          AppColors.primaryColor,
                          AppColors.primaryColor.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Icon(Icons.people_outline, color: AppColors.primaryWhite, size: 40),
                  );
                },
              ),
            ),
          ),
          16.widthBox(),
          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  diwaniya.name ?? '',
                  style: TextStyle(
                    color: AppColors.primaryBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                8.heightBox(),
                // Level Review Rating
                Row(
                  children: [
                    Text(
                      LocaleKeys.level_review.tr(),
                      style: TextStyle(
                        color: AppColors.lightTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    8.widthBox(),
                    _buildStarRating(double.parse(diwaniya.level_rating ?? '0').round()),
                  ],
                ),
                4.heightBox(),
                // Clear Game Rating
                Row(
                  children: [
                    Text(
                      LocaleKeys.clean_game.tr(),
                      style: TextStyle(
                        color: AppColors.lightTextColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    8.widthBox(),
                    _buildStarRating(double.parse(diwaniya.clean_game_rating ?? '0').round()),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

