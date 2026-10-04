import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/diwaniya_ranking/diwaniya_ranking_item.dart';

import '../../../generated/locale_keys.g.dart';

class RankingListItem extends StatelessWidget {
  final DiwaniyaRankingItem item;

  const RankingListItem({super.key, required this.item});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(bottom: 12.h),
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: item.isMine ? AppColors.primaryColor : AppColors.borderGrey,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: AppColors.primaryWhite,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                '#${item.rank}',
                style: const TextStyle(
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          12.widthBox(),
          CircleAvatar(
            radius: 22,
            backgroundImage: item.imagePath != null && item.imagePath!.startsWith('http')
                ? NetworkImage(item.imagePath!) as ImageProvider
                : AssetImage(item.imagePath ?? AppAssets.ic_profile),
            backgroundColor: AppColors.primaryLiteGrey,
            onBackgroundImageError: (_, _) {},
          ),
          12.widthBox(),
          Expanded(
            child: Text(
              item.name,
              style: TextStyle(
                color: item.isMine
                    ? AppColors.primaryColor
                    : AppColors.primaryDark,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Container(
            padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 8.h),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(15),
            ),
            child: Text(
              '${item.points} ${LocaleKeys.points.tr()}',
              style: const TextStyle(
                color: AppColors.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
