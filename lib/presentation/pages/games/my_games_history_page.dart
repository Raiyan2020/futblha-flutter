import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/widgets/pagination_list.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:intl/intl.dart' as intl;

import '../../../application/core/utils/helpers/extension_functions/date_extension_functions.dart';
import '../../widgets/custom_loading_widget.dart';

@RoutePage()
class MyGamesHistoryPage extends StatefulWidget {
  const MyGamesHistoryPage({super.key});

  @override
  State<MyGamesHistoryPage> createState() => _MyGamesHistoryPageState();
}

class _MyGamesHistoryPageState extends State<MyGamesHistoryPage> {
  final gamesBloc = locator<GamesBloc>();

  @override
  void initState() {
    super.initState();
    gamesBloc.add(const GetGameHistoryEvent(page: 1));
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GamesBloc, GamesState>(
      bloc: gamesBloc,
      listener: (context, state) {
        if (state is GamesError) {
          context.showMessage(isError: true, state.message);
        }
      },
      builder: (context, state) {
        final games = gamesBloc.gameHistory;

        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.my_games_history.tr())),
          body: games.isEmpty
              ? (state is GamesLoading
                    ? const LoadingWidget()
                    : Center(child: Text(LocaleKeys.no_game_history_available.tr())))
              : PaginationList(
                  itemCount: games.length,
                  reachedMax: gamesBloc.gameHistoryReachedMax,
                  onReachBottom: () {
                    if (gamesBloc.gameHistoryReachedMax) return;
                    if (state is GamesLoading)
                      return; // Prevent duplicate requests while loading next page
                    final nextPage = (gamesBloc.gameHistoryPagination?.currentPage ?? 1) + 1;
                    gamesBloc.add(GetGameHistoryEvent(page: nextPage));
                  },
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  separator: 16.heightBox(),
                  itemBuilder: (context, index) {
                    return _buildGameCard(games[index], context);
                  },
                ),
        );
      },
    );
  }

  Widget _buildGameCard(GameModel game, BuildContext context) {
    // Determine visibility
    final visibility = game.type?.toLowerCase();
    final isMyDiwanyaGame = game.type == 'my_diwanya';

    // Get team names and images
    final team1Name = isMyDiwanyaGame ? LocaleKeys.team_1.tr() : (game.creatorDiwaniya?.name ?? '');
    final team1Image = game.creatorDiwaniya?.image ?? AppAssets.ic_profile;
    final team2Name = isMyDiwanyaGame
        ? LocaleKeys.team_2.tr()
        : (game.opponentDiwaniya?.name ?? LocaleKeys.opposing_team.tr());
    final team2Image = game.opponentDiwaniya?.image ?? AppAssets.ic_profile;

    // Get creator name
    final creatorName = game.creatorName ?? '';

    // Format date and time
    String dateStr = '';
    String timeStr = '';
    if (game.booking != null) {
      final bookingDate = game.booking!.bookingDate;
      if (bookingDate != null) {
        try {
          dateStr = intl.DateFormat('d MMM yyyy').format(bookingDate);
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
    // final joinedPlayers = game.playersJoines ?? 0;
    final targetPlayers = game.playersTarget ?? 0;
    final playersStr = '${(targetPlayers / 2).round()} VS ${(targetPlayers / 2).round()}';

    // Get location
    final location = game.booking?.playground?.name;

    // Determine status based on gameStatus
    GameStatus status;
    final gameStatus = game.result?.toLowerCase() ?? '';
    if (gameStatus.contains('win')) {
      status = GameStatus.win;
    } else if (gameStatus.contains('lose') || gameStatus.contains('loss')) {
      status = GameStatus.lose;
    } else if (gameStatus.contains('draw')) {
      status = GameStatus.draw;
    } else {
      status = GameStatus.waitingOpposingTeam;
    }

    return GestureDetector(
      onTap: () {
        if (game.id != null) {
          context.router.push(
            GameDetailsRoute(bloc: gamesBloc..gameDetails = game, isFromHistory: true),
          );
        }
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: context.chipBackground, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Visibility Tag and Notification
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                _buildVisibilityTag(visibility),
                if (game.chatEnabled == true)
                  IconButton(
                    onPressed: () {
                      if (game.id != null) {
                        context.router.push(ChatRoute(gameId: game.id!));
                      } else {
                        context.router.push(ChatRoute());
                      }
                    },
                    icon: Icon(Icons.chat_outlined, color: context.brandOnSurface),
                  ),
              ],
            ),
            16.heightBox(),
            // Team Matchup
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: team1Image.startsWith('http')
                          ? NetworkImage(team1Image) as ImageProvider
                          : AssetImage(team1Image),
                      backgroundColor: context.mutedBackground,
                      onBackgroundImageError: (_, _) {},
                    ),
                    8.heightBox(),
                    Text(
                      team1Name,
                      style: TextStyle(
                        color: context.brandOnSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                16.widthBox(),
                Text(
                  'VS',
                  style: TextStyle(
                    color: context.brandOnSurface,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                16.widthBox(),
                Column(
                  children: [
                    CircleAvatar(
                      radius: 30,
                      backgroundImage: team2Image.startsWith('http')
                          ? NetworkImage(team2Image) as ImageProvider
                          : AssetImage(team2Image),
                      backgroundColor: context.mutedBackground,
                      onBackgroundImageError: (_, _) {},
                    ),
                    8.heightBox(),
                    Text(
                      team2Name,
                      style: TextStyle(
                        color: context.brandOnSurface,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
            // Status Badge (for private games with result)
            if (status != GameStatus.waitingOpposingTeam) ...[
              12.heightBox(),
              Center(child: _buildStatusBadge(status)),
            ],
            12.heightBox(),
            // Creator Information
            Text(
              '${LocaleKeys.creator.tr()} : $creatorName',
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            12.heightBox(),
            // Game Details
            Container(
              decoration: BoxDecoration(
                color: context.chipBackground.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.calendar_today, size: 14, color: context.brandOnSurface),
                      6.widthBox(),
                      Text(
                        dateStr,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.access_time, size: 14, color: context.brandOnSurface),
                      6.widthBox(),
                      Text(
                        timeStr,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      Icon(Icons.person, size: 14, color: context.brandOnSurface),
                      6.widthBox(),
                      Text(
                        playersStr,
                        textDirection: TextDirection.ltr,
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            8.heightBox(),
            Container(
              decoration: BoxDecoration(
                color: context.chipBackground.withValues(alpha: .5),
                borderRadius: BorderRadius.circular(8),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 14, color: context.brandOnSurface),
                      6.widthBox(),
                      Text(
                        location ?? '',
                        style: TextStyle(
                          color: context.textSecondary,
                          fontSize: 12,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    game.gameStatusText ?? '',
                    style: TextStyle(
                      color: context.brandOnSurface,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVisibilityTag(String? visibility) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        visibility?.tr() ?? '',
        style: TextStyle(
          color: context.brandOnSurface,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildStatusBadge(GameStatus status) {
    String statusText;
    Color statusColor;

    switch (status) {
      case GameStatus.win:
        statusText = 'Win';
        statusColor = context.brandOnSurface;
        break;
      case GameStatus.lose:
        statusText = LocaleKeys.lose.tr();
        statusColor = AppColors.primaryRed;
        break;
      case GameStatus.draw:
        statusText = LocaleKeys.draw.tr();
        statusColor = AppColors.primaryOrange;
        break;
      case GameStatus.waitingOpposingTeam:
        statusText = LocaleKeys.waiting_opposing_team.tr();
        statusColor = AppColors.primaryOrange;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.chipBackground,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        statusText,
        style: TextStyle(color: statusColor, fontSize: 12, fontWeight: FontWeight.w500),
      ),
    );
  }
}

enum GameStatus { win, lose, draw, waitingOpposingTeam }
