import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/diwaniyat/widgets/upcoming_game_card.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

class UpcomingGamesSection extends StatelessWidget {
  final List<GameModel> upcomingGames;
  final GamesBloc gamesBloc;
  final Function(GameModel)? onGameTap;

  const UpcomingGamesSection({
    super.key,
    required this.upcomingGames,
    required this.gamesBloc,
    this.onGameTap,
  });

  @override
  Widget build(BuildContext context) {
    if (upcomingGames.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Text(
            LocaleKeys.upcoming_games.tr(),
            style: TextStyle(
              color: AppColors.primaryBlack,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        10.heightBox(),
        ...upcomingGames.map((game) {
          return Padding(
            padding: EdgeInsets.only(bottom: 12.h, left: 20.w, right: 20.w),
            child: UpcomingGameCard(
              game: game,
              gamesBloc: gamesBloc,
              onTap: () {
                if (onGameTap != null) {
                  onGameTap!(game);
                } else if (game.id != null) {
                  gamesBloc.gameDetails = game;
                }
              },
            ),
          );
        }),
      ],
    );
  }
}

