import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/diwaniyat/bloc/diwaniya_bloc.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/pagination_list.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';

import '../../../application/core/utils/helpers/extension_functions/date_extension_functions.dart';

@RoutePage()
class GamesHistoryPage extends StatefulWidget {
  final int diwaniyaId;

  const GamesHistoryPage({super.key, required this.diwaniyaId});

  @override
  State<GamesHistoryPage> createState() => _GamesHistoryPageState();
}

class _GamesHistoryPageState extends State<GamesHistoryPage> {
  final diwaniyaBloc = locator<DiwaniyaBloc>();
  final gamesBloc = locator<GamesBloc>();

  @override
  void initState() {
    super.initState();
    diwaniyaBloc.add(
      GetDiwaniyaGamesEvent(diwaniyaId: widget.diwaniyaId, page: 1),
    );
  }

  void _loadNextPage() {
    final nextPage =
        (diwaniyaBloc.diwaniyaGamesPagination?.currentPage ?? 1) + 1;
    diwaniyaBloc.add(
      GetDiwaniyaGamesEvent(diwaniyaId: widget.diwaniyaId, page: nextPage),
    );
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<DiwaniyaBloc, DiwaniyaState>(
      bloc: diwaniyaBloc,
      listener: (context, state) {
        if (state is DiwaniyaError) {
          context.showMessage(isError: true, state.message);
        }
      },
      builder: (context, state) {
        final historyGames = diwaniyaBloc.diwaniyaGames;

        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.games_history.tr())),
          body: state is DiwaniyaLoading && historyGames.isEmpty
              ? const LoadingWidget()
              : historyGames.isEmpty
              ? Center(
                  child: Text(
                    LocaleKeys.no_game_history_found.tr(),
                    style: TextStyle(
                      color: AppColors.lightTextColor,
                      fontSize: 16,
                    ),
                  ),
                )
              : PaginationList(
                  itemCount: historyGames.length,
                  reachedMax: diwaniyaBloc.diwaniyaGamesReachedMax,
                  onReachBottom: () {
                    if (diwaniyaBloc.diwaniyaGamesReachedMax) return;
                    if (state is DiwaniyaLoading) return;
                    _loadNextPage();
                  },
                  padding: EdgeInsets.symmetric(
                    horizontal: 20.w,
                    vertical: 16.h,
                  ),
                  separator: 12.heightBox(),
                  itemBuilder: (context, index) {
                    final game = historyGames[index];
                    return InkWell(
                      onTap: () {
                        // open game details if state is players completed
                      },
                      splashColor: Colors.transparent,
                      child: _buildGameHistoryCard(game, index),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildGameHistoryCard(GameModel game, int index) {
    final isMyDiwanyaGame = game.type == 'my_diwanya';

    // Get team names and images
    final team1Name = isMyDiwanyaGame
        ? LocaleKeys.team_1.tr()
        : (game.creatorDiwaniya?.name ?? '');
    final team1Image = game.creatorDiwaniya?.image ?? AppAssets.ic_profile;
    final team2Name = isMyDiwanyaGame
        ? LocaleKeys.team_2.tr()
        : (game.opponentDiwaniya?.name ?? LocaleKeys.opposing_team.tr());
    final team2Image = game.opponentDiwaniya?.image ?? AppAssets.ic_profile;

    // Determine status and color
    final status = game.result?.toLowerCase() ?? '';
    String statusText = '';
    Color statusColor = AppColors.primaryColor;

    if (status.contains('win')) {
      statusText = LocaleKeys.win.tr();
      statusColor = AppColors.primaryColor;
    } else if (status.contains('lose') || status.contains('loss')) {
      statusText = LocaleKeys.lose.tr();
      statusColor = AppColors.primaryRed;
    } else if (status.contains('draw')) {
      statusText = LocaleKeys.draw.tr();
      statusColor = AppColors.primaryYellow;
    } else {
      statusText = status.isNotEmpty ? status : game.gameStatusText ?? '';
    }

    // Format date and time
    String dateStr = '';
    String timeStr = '';
    if (game.booking != null) {
      final bookingDate = game.booking!.bookingDate;
      if (bookingDate != null) {
        try {
          dateStr = bookingDate.toLocal().formatDateToCustomString();
        } catch (e) {
          dateStr = bookingDate.toLocal().formatDateToCustomString();
        }
      }

      // Get time from first period
      if (game.booking!.periods != null && game.booking!.periods!.isNotEmpty) {
        final period = game.booking!.periods!.first;
        timeStr = '${period.startTime ?? ''} - ${period.endTime ?? ''}';
      }
    }

    // Get players count
    final playersCount = ((game.playersTarget as int).round() / 2)
        .round()
        .toString();
    final playersStr = '$playersCount ${LocaleKeys.vs.tr()} $playersCount';

    // Get location
    final location = game.booking?.playground?.name ?? '';

    // Get creator name
    final creatorName = game.creatorName ?? '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Private/Public label
          Container(
            padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              game.type?.toLowerCase().tr() ?? '',
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          8.heightBox(),
          // Teams
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildTeamLogo(team1Name, team1Image),
              40.widthBox(),
              Text(
                LocaleKeys.vs.tr(),
                style: TextStyle(
                  color: AppColors.primaryBlack,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              40.widthBox(),
              _buildTeamLogo(team2Name, team2Image),
            ],
          ),
          12.heightBox(),
          // Status button
          Center(
            child: Container(
              padding: EdgeInsets.symmetric(horizontal: 14.w, vertical: 6.h),
              decoration: BoxDecoration(
                color: statusColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                statusText,
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          12.heightBox(),
          // Creator
          Text(
            '${LocaleKeys.creator.tr()} : $creatorName',
            style: TextStyle(
              color: AppColors.lightTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          12.heightBox(),
          // Game details row 1
          Center(
            child: Wrap(
              spacing: 8.w,
              runSpacing: 8.h,
              children: [
                if (dateStr.isNotEmpty)
                  _buildInfoChip(Icons.calendar_today, dateStr),
                if (dateStr.isNotEmpty && timeStr.isNotEmpty)
                  if (timeStr.isNotEmpty)
                    _buildInfoChip(Icons.access_time, timeStr),
                if ((dateStr.isNotEmpty || timeStr.isNotEmpty) &&
                    playersStr.isNotEmpty)
                  if (playersStr.isNotEmpty)
                    _buildInfoChip(Icons.people, playersStr),
                if (location.isNotEmpty)
                  _buildInfoChip(Icons.location_on, location),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTeamLogo(String name, String imagePath) {
    return Column(
      children: [
        Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLiteGrey,
          ),
          child: ClipOval(
            child: imagePath.startsWith('http')
                ? Image.network(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                        size: 30,
                      );
                    },
                  )
                : Image.asset(
                    imagePath,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Icon(
                        Icons.person,
                        color: AppColors.primaryColor,
                        size: 30,
                      );
                    },
                  ),
          ),
        ),
        8.heightBox(),
        Text(
          name,
          style: TextStyle(
            color: AppColors.primaryBlack,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }

  Widget _buildInfoChip(IconData icon, String text) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          4.widthBox(),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
