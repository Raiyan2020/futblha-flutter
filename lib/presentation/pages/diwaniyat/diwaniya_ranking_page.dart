import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/diwaniya_ranking/diwaniya_ranking_item.dart';
import 'package:futblha/presentation/widgets/diwaniya_ranking/ranking_list_item.dart';
import 'package:futblha/presentation/widgets/diwaniya_ranking/top_three_ranking_card.dart';
import 'package:futblha/presentation/pages/diwaniyat/bloc/diwaniya_bloc.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/generated/locale_keys.g.dart';

@RoutePage()
class DiwaniyaRankingPage extends StatefulWidget {
  const DiwaniyaRankingPage({super.key});

  @override
  State<DiwaniyaRankingPage> createState() => _DiwaniyaRankingPageState();
}

class _DiwaniyaRankingPageState extends State<DiwaniyaRankingPage> {
  final bloc = locator<DiwaniyaBloc>();
  List<String> get _filters => [
    LocaleKeys.this_month.tr(),
    LocaleKeys.this_year.tr(),
    LocaleKeys.all_time.tr(),
  ];
  int _selectedFilter = 0;

  @override
  void initState() {
    super.initState();
    _loadRanking();
  }

  void _loadRanking() {
    String? date;
    switch (_selectedFilter) {
      case 0: // This Month
        date = 'month';
        break;
      case 1: // This Year
        date = 'year';
        break;
      case 2: // All Time
        date = null;
        break;
    }
    bloc.add(GetDiwaniyaRankingEvent(date: date));
  }

  List<DiwaniyaRankingItem> _getTopThree() {
    final topRanking = bloc.diwaniyaRanking?.topRanking ?? [];
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
        isMine: diwaniya.isMyDiwaniya ?? false,
      );
    }).toList();
  }

  List<DiwaniyaRankingItem> _getRankingList() {
    final allRanking = bloc.diwaniyaRanking?.allRanking?.items ?? [];
    // Skip first 3 as they're shown in top three
    final remaining = allRanking.skip(3).toList();

    return remaining.map((diwaniya) {
      final rank = int.tryParse(diwaniya.rank ?? '0') ?? 0;
      final points = int.tryParse(diwaniya.totalPoints ?? '0') ?? 0;

      return DiwaniyaRankingItem(
        id: diwaniya.id,
        rank: rank,
        name: diwaniya.name ?? '',
        points: points,
        imagePath: diwaniya.image,
        isMine: diwaniya.isMyDiwaniya ?? false,
      );
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<DiwaniyaBloc, DiwaniyaState>(
      bloc: bloc,
      listener: (context, state) {
        if (state is DiwaniyaError) {
          context.showMessage(isError: true, state.message);
        }
      },
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.diwaniya_ranking.tr())),
          body: SingleChildScrollView(
            padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  spacing: 10.w,
                  children: List.generate(_filters.length, (index) {
                    final isSelected = index == _selectedFilter;
                    return Expanded(
                      child: GestureDetector(
                        onTap: () {
                          setState(() => _selectedFilter = index);
                          _loadRanking();
                        },
                        child: Container(
                          padding: EdgeInsets.symmetric(vertical: 10.h),
                          decoration: BoxDecoration(
                            color: isSelected ? AppColors.primaryColor : AppColors.primaryLiteGrey,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              _filters[index],
                              style: TextStyle(
                                color: isSelected ? AppColors.primaryWhite : AppColors.primaryDark,
                                fontSize: 13,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ),
                20.heightBox(),
                state is DiwaniyaLoading
                    ? const LoadingWidget()
                    : Column(
                        children: [
                          _buildTopThreeCard(),
                          20.heightBox(),
                          ..._getRankingList().map((item) => RankingListItem(item: item)),
                        ],
                      ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildTopThreeCard() {
    final topThree = _getTopThree();

    if (topThree.isEmpty) {
      return const SizedBox.shrink();
    }

    // Ensure we have at least 3 items (pad with empty if needed)
    final displayItems = <DiwaniyaRankingItem>[];
    if (topThree.length >= 3) {
      displayItems.addAll([topThree[0], topThree[1], topThree[2]]);
    } else if (topThree.length == 2) {
      displayItems.addAll([topThree[0], topThree[1]]);
      displayItems.add(DiwaniyaRankingItem(rank: 0, name: '', points: 0));
    } else if (topThree.length == 1) {
      displayItems.add(topThree[0]);
      displayItems.add(DiwaniyaRankingItem(rank: 0, name: '', points: 0));
      displayItems.add(DiwaniyaRankingItem(rank: 0, name: '', points: 0));
    } else {
      return const SizedBox.shrink();
    }

    return Container(
      height: 170.h,
      padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 0.h),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        image: DecorationImage(image: AssetImage(AppAssets.rank_background), fit: BoxFit.cover),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlack.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Align(
            alignment: Alignment.bottomCenter,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // 3rd place (left)
                if (displayItems.length >= 3 && displayItems[2].rank > 0)
                  TopThreeRankingCard(item: displayItems[2], height: 120, asset: AppAssets.rank_3)
                else if (displayItems.length < 3)
                  SizedBox(width: 100.w),
                // 1st place (center)
                if (displayItems.length >= 1 && displayItems[0].rank > 0)
                  TopThreeRankingCard(
                    item: displayItems[0],
                    height: 150,
                    asset: AppAssets.rank_1,
                    isFirst: true,
                  )
                else
                  SizedBox(width: 100.w),
                // 2nd place (right)
                if (displayItems.length >= 2 && displayItems[1].rank > 0)
                  TopThreeRankingCard(item: displayItems[1], height: 130, asset: AppAssets.rank_2)
                else if (displayItems.length < 2)
                  SizedBox(width: 100.w),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
