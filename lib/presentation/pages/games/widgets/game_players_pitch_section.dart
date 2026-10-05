import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/games/game_members_response_model.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/response_model/games/game_player_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/pages/games/utils/game_formation_utils.dart';
import 'package:futblha/presentation/pages/games/widgets/player_info_bottom_sheet.dart';
import 'package:futblha/presentation/pages/games/widgets/soccer_field_painter.dart';

class GamePlayersPitchSection extends StatelessWidget {
  const GamePlayersPitchSection({
    super.key,
    required this.game,
    required this.members,
    required this.bloc,
    required this.isFromHistory,
    this.userTeamIndex,
    required this.onForfeitTap,
    required this.onJoinFromPosition,
    this.isChangingPosition = false,
    this.changePositionTeamIndex,
    this.onChangePositionSlot,
  });

  final GameModel game;
  final GameMembersResponseModel? members;
  final GamesBloc bloc;
  final bool isFromHistory;

  /// When set, user can only join slots on this team (0 = top, 1 = bottom). Null = both teams.
  final int? userTeamIndex;
  final VoidCallback onForfeitTap;
  final void Function(Map<String, double> coords, int teamIndex, int slotIndex) onJoinFromPosition;
  /// When true, empty slots on [changePositionTeamIndex] are tappable to change position.
  final bool isChangingPosition;
  final int? changePositionTeamIndex;
  final void Function(int teamIndex, int slotIndex)? onChangePositionSlot;

  @override
  Widget build(BuildContext context) {
    final totalPlayers = int.tryParse(game.playersTarget?.toString() ?? '0') ?? 0;
    final playersPerTeam = totalPlayers ~/ 2;
    final joinedPlayers = game.playersJoines ?? 0;

    final myTeamPlayers = sortPlayersByPosition(members?.myTeamPlayers ?? []);
    final opposingTeamPlayers = sortPlayersByPosition(members?.opposingTeamPlayers ?? []);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        5.heightBox(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () {
                if (game.id != null) {
                  context.router.push(JoinedPlayersRoute(gameId: game.id!, bloc: bloc));
                }
              },
              child: Row(
                children: [
                  Text(
                    LocaleKeys.players_joined.tr(),
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                  8.widthBox(),
                  Text(
                    '$joinedPlayers/$totalPlayers',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            if (game.userPermission?.isMember == true &&
                game.gameStatus != 'confirmed' &&
                !isFromHistory)
              GestureDetector(
                onTap: onForfeitTap,
                child: Row(
                  children: [
                    Icon(Icons.arrow_forward, color: AppColors.primaryRed, size: 16),
                    4.widthBox(),
                    Text(
                      LocaleKeys.forfeit_match.tr(),
                      style: const TextStyle(
                        color: AppColors.primaryRed,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
        10.heightBox(),
        Container(
          height: 500.h,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: AppColors.primaryLiteGrey,
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: Stack(
              children: [
                Image.asset(AppAssets.grass_profile, height: 500.h, fit: BoxFit.cover),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final playerWidgets = <Widget>[];
                    final emptySlotWidgets = <Widget>[];

                    // Use slotIndex (when present) so a player occupies that slot and we don't show empty there
                    final myTeamUsedIndices = <int>{};
                    for (final entry in myTeamPlayers.asMap().entries) {
                      final player = entry.value;
                      final teamIdx = 0;
                      final slotIdx = player.slotIndex ?? entry.key.toString();
                      myTeamUsedIndices.add(int.parse(slotIdx));
                      final coords = getPositionCoordinates(
                        player.teamIndex ?? teamIdx,
                        int.parse(slotIdx),
                        playersPerTeam,
                      );
                      playerWidgets.add(_buildPlayerWidget(context, player, coords, constraints));
                    }

                    final opposingTeamUsedIndices = <int>{};
                    for (final entry in opposingTeamPlayers.asMap().entries) {
                      final player = entry.value;
                      final teamIdx = 1;
                      final slotIdx = player.slotIndex ?? entry.key.toString();
                      opposingTeamUsedIndices.add(int.parse(slotIdx));
                      final coords = getPositionCoordinates(
                        player.teamIndex ?? teamIdx,
                        int.parse(slotIdx),
                        playersPerTeam,
                      );
                      playerWidgets.add(_buildPlayerWidget(context, player, coords, constraints));
                    }

                    for (int i = 0; i < playersPerTeam; i++) {
                      if (!myTeamUsedIndices.contains(i)) {
                        final coords = getPositionCoordinates(0, i, playersPerTeam);
                        emptySlotWidgets.add(_buildEmptySlot(context, coords, constraints, 0, i));
                      }
                    }

                    for (int i = 0; i < playersPerTeam; i++) {
                      if (!opposingTeamUsedIndices.contains(i)) {
                        final coords = getPositionCoordinates(1, i, playersPerTeam);
                        emptySlotWidgets.add(_buildEmptySlot(context, coords, constraints, 1, i));
                      }
                    }

                    return Stack(
                      children: [
                        CustomPaint(painter: SoccerFieldPainter(), child: Container()),
                        Stack(children: [...playerWidgets, ...emptySlotWidgets]),
                      ],
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlayerWidget(
    BuildContext context,
    GamePlayerModel player,
    Map<String, double> coords,
    BoxConstraints constraints,
  ) {
    final x = coords['x'] ?? 0.5;
    final y = coords['y'] ?? 0.5;
    final name = player.name ?? '';
    return Positioned(
      // Wider than the 50.w avatar so the name has room; still centered on the slot.
      left: x * constraints.maxWidth - 35.w,
      top: y * constraints.maxHeight - 25.w,
      width: 70.w,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () => PlayerInfoBottomSheet.show(context, player),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 50.w,
              height: 50.h,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.primaryWhite, width: 2.5),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryBlack.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipOval(
                child: player.image != null && player.image!.isNotEmpty
                    ? Image.network(
                        player.image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => Container(
                          color: AppColors.primaryLiteGrey,
                          child: Icon(Icons.person, color: AppColors.primaryColor, size: 30),
                        ),
                      )
                    : Container(
                        color: AppColors.primaryLiteGrey,
                        child: Icon(Icons.person, color: AppColors.primaryColor, size: 30),
                      ),
              ),
            ),
            if (name.isNotEmpty) ...[
              2.heightBox(),
              Text(
                name,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  shadows: [
                    Shadow(color: AppColors.primaryBlack.withValues(alpha: 0.6), blurRadius: 3),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildEmptySlot(
    BuildContext context,
    Map<String, double> coords,
    BoxConstraints constraints,
    int teamIndex,
    int slotIndex,
  ) {
    final x = coords['x'] ?? 0.5;
    final y = coords['y'] ?? 0.5;

    final baseCanJoin =
        game.userPermission?.canJoin == true && game.userPermission?.isMember != true;
    final isGoalkeeperSlot = slotIndex == 0;
    final goalkeeperClosedForTeam =
        isGoalkeeperSlot &&
        ((teamIndex == 0 && game.goalkeeperTeam1Close == true) ||
            (teamIndex == 1 && game.goalkeeperTeam2Close == true));
    final onAllowedTeam = userTeamIndex == null || teamIndex == userTeamIndex;
    final canJoin = baseCanJoin && !goalkeeperClosedForTeam && onAllowedTeam;

    final canChangePosition = isChangingPosition &&
        changePositionTeamIndex != null &&
        teamIndex == changePositionTeamIndex &&
        onChangePositionSlot != null &&
        !goalkeeperClosedForTeam;
    final canTap = canJoin || canChangePosition;

    void onTap() {
      if (canChangePosition) {
        onChangePositionSlot!(teamIndex, slotIndex);
      } else if (canJoin) {
        onJoinFromPosition(coords, teamIndex, slotIndex);
      }
    }

    return Positioned(
      left: x * constraints.maxWidth - 25.w,
      top: y * constraints.maxHeight - 25.w,
      child: GestureDetector(
        onTap: canTap ? onTap : null,
        child: Container(
          width: 50.w,
          height: 50.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: canTap
                ? AppColors.primaryColor.withValues(alpha: 0.6)
                : AppColors.primaryLiteGrey.withValues(alpha: 0.5),
            border: Border.all(
              color: canTap
                  ? AppColors.primaryWhite
                  : AppColors.primaryWhite.withValues(alpha: 0.5),
              width: 2,
            ),
          ),
          child: Icon(
            Icons.add,
            color: AppColors.primaryWhite.withValues(alpha: canTap ? 1.0 : 0.7),
            size: 24,
          ),
        ),
      ),
    );
  }
}
