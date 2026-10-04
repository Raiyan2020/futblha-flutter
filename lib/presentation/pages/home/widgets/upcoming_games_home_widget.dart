import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/diwaniyat/widgets/upcoming_game_card.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/pages/general/bloc/general_bloc.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';

class UpcomingGamesHomeWidget extends StatelessWidget {
  const UpcomingGamesHomeWidget(this.generalBloc, {super.key});
  final GeneralBloc generalBloc;

  List<GameModel> _getUpcomingGames(GeneralBloc generalBloc) {
    return generalBloc.homeData?.upcomingGames ?? [];
  }

  @override
  Widget build(BuildContext context) {
    final gamesBloc = locator<GamesBloc>();

    return CustomBlocConsumer<GeneralBloc, GeneralState>(
      bloc: generalBloc,
      listener: (context, state) {},
      builder: (context, state) {
        final upcomingGames = _getUpcomingGames(generalBloc);

        if (upcomingGames.isEmpty) {
          return const SizedBox.shrink();
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            20.heightBox(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    LocaleKeys.upcoming_games.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.router.push(const MyUpcomingGamesRoute());
                    },
                    child: Text(
                      LocaleKeys.see_all.tr(),
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                    ),
                  ),
                ],
              ),
            ),
            10.heightBox(),
            if (state is GeneralLoading && upcomingGames.isEmpty)
              SizedBox(height: 220.h, child: const LoadingWidget())
            else if (upcomingGames.isEmpty)
              const SizedBox.shrink()
            else
              SizedBox(
                height: 260.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: upcomingGames.length,
                  itemBuilder: (context, index) {
                    final game = upcomingGames[index];
                    return Padding(
                      padding: EdgeInsets.only(right: 12.w),
                      child: SizedBox(
                        width: 330.w,
                        child: UpcomingGameCard(
                          game: game,
                          gamesBloc: gamesBloc,
                          onTap: () {
                            context.router.push(
                              GameDetailsRoute(bloc: gamesBloc..gameDetails = game),
                            );
                          },
                        ),
                      ),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }
}
