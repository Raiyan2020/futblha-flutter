import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/diwaniya_ranking/diwaniya_ranking_item.dart';

import '../../../generated/locale_keys.g.dart';

class TopThreeRankingCard extends StatelessWidget {
  final DiwaniyaRankingItem item;
  final double height;
  final String asset;
  final bool isFirst;

  const TopThreeRankingCard({
    super.key,
    required this.height,
    required this.item,
    required this.asset,
    this.isFirst = false,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: item.id == null ? null : () => context.router.push(DiwaniyaDetailsRoute(diwaniyaId: item.id.toString())),
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          Container(
            height: height,
            width: 100.w,
            constraints: BoxConstraints(maxWidth: 110.w, minWidth: 80.w),
            padding: EdgeInsets.only(bottom: 10.h),
            margin: EdgeInsets.only(top: 18),
            decoration: BoxDecoration(
              image: DecorationImage(image: AssetImage(asset), fit: BoxFit.fill),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                37.heightBox(),
                Text(
                  '#${item.rank}',
                  style: TextStyle(
                    color: AppColors.primaryWhite,
                    fontSize: isFirst ? 18 : 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                3.heightBox(),
                Text(
                  item.name,
                  style: const TextStyle(color: AppColors.primaryWhite, fontSize: 12, fontWeight: FontWeight.w500),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                2.heightBox(),
                Text(
                  '${item.points} ${LocaleKeys.points.tr()}',
                  style: const TextStyle(color: AppColors.primaryWhite, fontSize: 11, fontWeight: FontWeight.w400),
                ),
              ],
            ),
          ),
          Container(
            width: 53.w,
            height: 53.w,
            decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryLiteGrey),
            child: ClipOval(
              child: item.imagePath != null && item.imagePath!.startsWith('http')
                  ? Image.network(
                      item.imagePath!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: AppColors.primaryColor);
                      },
                    )
                  : Image.asset(
                      item.imagePath ?? AppAssets.ic_profile,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return const Icon(Icons.person, color: AppColors.primaryColor);
                      },
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
