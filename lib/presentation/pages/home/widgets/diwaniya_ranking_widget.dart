import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/diwaniya_ranking/diwaniya_ranking_item.dart';
import 'package:futblha/presentation/widgets/diwaniya_ranking/top_three_ranking_card.dart';
import 'package:futblha/presentation/pages/general/bloc/general_bloc.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../../widgets/app_size_boxes.dart';
import '../../../widgets/custom_loading_widget.dart';

class DiwaniyaRankingWidget extends StatelessWidget {
  const DiwaniyaRankingWidget(this.generalBloc, {super.key});
  final GeneralBloc generalBloc;

  List<DiwaniyaRankingItem> _getTopThree(GeneralBloc generalBloc) {
    // Prefer home API data, fallback to diwaniya ranking API
    final topRanking = generalBloc.homeData?.topRanking ?? [];
    if (topRanking.isEmpty) return [];

    // Sort by rank to ensure correct order (1st, 2nd, 3rd)
    final sorted = topRanking.toList()
      ..sort((a, b) {
        final rankA = int.tryParse(a.rank ?? '0') ?? 0;
        final rankB = int.tryParse(b.rank ?? '0') ?? 0;
        return rankA.compareTo(rankB);
      });

    return sorted.take(3).map((diwaniya) {
      final rank = int.tryParse(diwaniya.rank ?? '0') ?? 0;
      final points = int.tryParse(diwaniya.totalPoints ?? '0') ?? 0;

      return DiwaniyaRankingItem(
        id: diwaniya.id,
        rank: rank,
        name: diwaniya.name ?? '',
        points: points,
        imagePath: diwaniya.image,
        containerHeight: rank == 1
            ? 150.0
            : rank == 2
            ? 130.0
            : 120.0,
        backgroundImagePath: rank == 1
            ? AppAssets.rank_1
            : rank == 2
            ? AppAssets.rank_2
            : AppAssets.rank_3,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GeneralBloc, GeneralState>(
      bloc: generalBloc,
      listener: (context, state) {},
      builder: (context, state) {
        final topThree = _getTopThree(generalBloc);
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 15.w),
          margin: EdgeInsets.symmetric(horizontal: 15.w),
          decoration: BoxDecoration(
            color: AppColors.primaryColor,
            borderRadius: BorderRadius.circular(16),
            image: const DecorationImage(
              image: AssetImage(AppAssets.rank_background),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              10.heightBox(),
              InkWell(
                onTap: () => context.router.push(const DiwaniyaRankingRoute()),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      LocaleKeys.diwaniya_ranking.tr(),
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const Icon(Icons.arrow_forward_ios, size: 16, color: AppColors.primaryColor),
                  ],
                ),
              ),
              10.heightBox(),
              if (state is GeneralLoading && topThree.isEmpty)
                const Center(
                  child: Padding(
                    padding: EdgeInsets.all(20.0),
                    child: LoadingWidget(),
                  ),
                )
              else if (topThree.isEmpty)
                const SizedBox.shrink()
              else
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (topThree.length >= 3) _buildRankingCard(topThree[2]),
                    if (topThree.length >= 1) _buildRankingCard(topThree[0]),
                    if (topThree.length >= 2) _buildRankingCard(topThree[1]),
                  ],
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildRankingCard(DiwaniyaRankingItem item) {
    final height = item.containerHeight ?? 120.0;
    final asset = item.backgroundImagePath ?? '';
    final isFirst = item.rank == 1;

    return TopThreeRankingCard(item: item, height: height, asset: asset, isFirst: isFirst);
  }
}
