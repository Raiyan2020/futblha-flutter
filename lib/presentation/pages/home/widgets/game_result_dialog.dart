import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/date_extension_functions.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';
import 'package:futblha/presentation/widgets/game_result_bottom_sheet.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/request_model/games/add_game_result_request_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';

/// Mandatory dialog shown on home when there are confirmed games (time passed)
/// that need a result. Admin cannot dismiss until they submit a result.
class GameResultDialog {
  /// Applies the selected result: navigates to opposing team rating (if both
  /// diwaniyas present) and adds [AddGameResultEvent]. Extracted for unit testing.
  /// [pushRoute] is typically `context.router.push`; injectable for tests.
  /// [onGameResultEventAdded] is optional, used in tests to capture the event.
  static Future<void> applyResultAfterSelection({
    required GameModel game,
    required GameResult result,
    required String team1Name,
    required String? team1Image,
    required String team2Name,
    required String? team2Image,
    required Future<T?> Function<T extends Object?>(PageRouteInfo<T> route) pushRoute,
    required GamesBloc gamesBloc,
    void Function(GamesEvent)? onGameResultEventAdded,
  }) async {
    final resultString = result == GameResult.team1Win
        ? 'win'
        : result == GameResult.team2Win
            ? 'lose'
            : 'draw';
    final bool rateTeam2 = result == GameResult.team1Win || result == GameResult.tie;
    final opposingTeamName = rateTeam2 ? team2Name : team1Name;
    final opposingTeamImage = rateTeam2 ? team2Image : team1Image;
    if (game.creatorDiwaniya != null && game.opponentDiwaniya != null) {
      await pushRoute(
        HowWasOpposingTeamRoute(
          teamName: opposingTeamName,
          teamImage: opposingTeamImage,
          gameId: game.id,
        ),
      );
    }
    if (game.id != null) {
      final event = AddGameResultEvent(
        gameId: game.id!,
        request: AddGameResultRequestModel(result: resultString),
      );
      gamesBloc.add(event);
      onGameResultEventAdded?.call(event);
    }
  }

  static Future<void> showIfNeeded(BuildContext context, GamesBloc gamesBloc) async {
    final games = gamesBloc.gamesNeedingResult;
    if (games.isEmpty) return;

    await showDialog<void>(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black54,
      builder: (dialogContext) => PopScope(
        canPop: false,
        child: _GameResultDialogContent(gamesBloc: gamesBloc, initialGames: List.from(games)),
      ),
    );
  }
}

class _GameResultDialogContent extends StatefulWidget {
  final GamesBloc gamesBloc;
  final List<GameModel> initialGames;

  const _GameResultDialogContent({required this.gamesBloc, required this.initialGames});

  @override
  State<_GameResultDialogContent> createState() => _GameResultDialogContentState();
}

class _GameResultDialogContentState extends State<_GameResultDialogContent> {
  late List<GameModel> _pendingGames;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _pendingGames = List.from(widget.initialGames);
  }

  GameModel? get _currentGame => _pendingGames.isNotEmpty ? _pendingGames.first : null;

  Future<void> _openResultBottomSheet(BuildContext context) async {
    final game = _currentGame;
    if (game?.id == null || _isSubmitting) return;

    final isMyDiwanyaGame = game!.type == 'my_diwanya';
    final team1Name = isMyDiwanyaGame ? LocaleKeys.team_1.tr() : (game.creatorDiwaniya?.name ?? '');
    final team1Image = game.creatorDiwaniya?.image;
    final team2Name = isMyDiwanyaGame
        ? LocaleKeys.team_2.tr()
        : (game.opponentDiwaniya?.name ?? LocaleKeys.opposing_team.tr());
    final team2Image = game.opponentDiwaniya?.image;

    final result = await GameResultBottomSheet.show(
      context,
      team1Name: team1Name,
      team1Image: team1Image,
      team2Name: team2Name,
      team2Image: team2Image,
    );

    if (result != null && mounted) {
      setState(() => _isSubmitting = true);
      await GameResultDialog.applyResultAfterSelection(
        game: game,
        result: result,
        team1Name: team1Name,
        team1Image: team1Image,
        team2Name: team2Name,
        team2Image: team2Image,
        pushRoute: context.router.push,
        gamesBloc: widget.gamesBloc,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GamesBloc, GamesState>(
      bloc: widget.gamesBloc,
      listener: (context, state) {
        if (state is AddGameResultSuccess) {
          setState(() => _isSubmitting = false);
          context.showMessage(state.message);
          // Refresh list from server
          widget.gamesBloc.add(const GetGamesResultEvent());
        } else if (state is GamesResultLoaded) {
          _pendingGames = List.from(state.games);
          if (_pendingGames.isEmpty && context.mounted) {
            Navigator.of(context).pop();
          } else {
            setState(() {});
          }
        } else if (state is GamesError) {
          setState(() => _isSubmitting = false);
          context.showMessage(isError: true, state.message);
        }
      },
      builder: (context, state) {
        if (_currentGame == null) {
          return const Center(child: CircularProgressIndicator());
        }

        final game = _currentGame!;

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Padding(
            padding: EdgeInsets.all(24.w),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      Icon(Icons.emoji_events, color: AppColors.primaryColor, size: 28.w),
                      12.widthBox(),
                      Expanded(
                        child: Text(
                          LocaleKeys.game_result.tr(),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                  8.heightBox(),
                  Text(
                    LocaleKeys.detect_game_winner.tr(),
                    style: const TextStyle(
                      color: AppColors.lightTextColor,
                      fontSize: 14,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                  if (game.booking?.bookingDate != null) ...[
                    8.heightBox(),
                    Text(
                      '${game.booking?.bookingDate?.toLocal().formatDateToCustomString()}',
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                  24.heightBox(),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _isSubmitting ? null : () => _openResultBottomSheet(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        disabledBackgroundColor: AppColors.primaryLiteGrey,
                      ),
                      child: Text(
                        LocaleKeys.detect_game_winner.tr(),
                        style: const TextStyle(
                          color: AppColors.primaryWhite,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  if (_pendingGames.length > 1) ...[
                    12.heightBox(),
                    Text(
                      '${_pendingGames.length - 1} ${LocaleKeys.remaining.tr()}',
                      style: const TextStyle(color: AppColors.lightTextColor, fontSize: 12),
                      textAlign: TextAlign.center,
                    ),
                  ],
                  if (_isSubmitting) ...[
                    16.heightBox(),
                    const Center(child: CircularProgressIndicator()),
                  ],
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
