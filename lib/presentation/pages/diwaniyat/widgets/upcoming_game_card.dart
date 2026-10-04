import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/diwaniyat/utils/game_data_helper.dart';
import 'package:futblha/presentation/pages/diwaniyat/widgets/info_chip.dart';
import 'package:futblha/presentation/pages/diwaniyat/widgets/team_logo.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

import '../../../../application/core/utils/helpers/extension_functions/date_extension_functions.dart';

class UpcomingGameCard extends StatelessWidget {
  final GameModel game;
  final GamesBloc gamesBloc;
  final VoidCallback onTap;

  const UpcomingGameCard({
    super.key,
    required this.game,
    required this.gamesBloc,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final gameTypeLabel = GameDataHelper.getGameTypeLabel(game.type);
    final isMyDiwanyaGame = game.type == 'my_diwanya';
    final team1Name = isMyDiwanyaGame ? LocaleKeys.team_1.tr() : (game.creatorDiwaniya?.name ?? '');
    final team1Image = game.creatorDiwaniya?.image;
    final team2Name = isMyDiwanyaGame
        ? LocaleKeys.team_2.tr()
        : (game.opponentDiwaniya?.name ?? LocaleKeys.opposing_team.tr());
    final team2Image = isMyDiwanyaGame ? game.creatorDiwaniya?.image : game.opponentDiwaniya?.image;
    final creatorName = game.creatorName ?? '';
    final dateStr = game.booking?.bookingDate?.toLocal().formatDateToCustomString() ?? '';
    final timeStr = GameDataHelper.formatTime(game.booking?.periods);
    final playersStr = GameDataHelper.getPlayersString(game.playersTarget);
    final location = game.booking?.playground?.name ?? '';
    final statusText = game.gameStatusText ?? game.invitationStatus ?? game.gameStatus ?? '';
    final statusColor = GameDataHelper.getStatusColor(statusText);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.borderGrey, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: .spaceBetween,
          children: [
            if (game.type != null) ...[
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  gameTypeLabel,
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              5.heightBox(),
            ],
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TeamLogo(name: team1Name, imageUrl: team1Image),
                16.widthBox(),
                Text(
                  LocaleKeys.vs.tr(),
                  style: TextStyle(
                    color: AppColors.primaryBlack,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                16.widthBox(),
                TeamLogo(name: team2Name, imageUrl: team2Image),
              ],
            ),
            if (creatorName.isNotEmpty) ...[
              12.heightBox(),
              Text(
                '${LocaleKeys.creator.tr()} : $creatorName',
                style: TextStyle(
                  color: AppColors.lightTextColor,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
            5.heightBox(),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
              decoration: BoxDecoration(
                color: AppColors.secondaryColor,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: .spaceBetween,
                children: [
                  if (dateStr.isNotEmpty) InfoChip(icon: Icons.calendar_today, text: dateStr),
                  if (timeStr.isNotEmpty) InfoChip(icon: Icons.access_time, text: timeStr),
                  if (playersStr.isNotEmpty) InfoChip(icon: Icons.people, text: playersStr),
                ],
              ),
            ),
            if (location.isNotEmpty || statusText.isNotEmpty) ...[
              8.heightBox(),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
                decoration: BoxDecoration(
                  color: AppColors.secondaryColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    if (location.isNotEmpty) InfoChip(icon: Icons.location_on, text: location),
                    if (location.isNotEmpty && statusText.isNotEmpty) Spacer(),
                    if (statusText.isNotEmpty)
                      Text(
                        statusText,
                        style: TextStyle(
                          color: statusColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
