import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/diwaniyat/utils/game_data_helper.dart';
import 'package:futblha/presentation/pages/diwaniyat/widgets/upcoming_game_card.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/pages/general/bloc/general_bloc.dart';

import '../../widgets/custom_loading_widget.dart';

@RoutePage()
class MyUpcomingGamesPage extends StatefulWidget {
  const MyUpcomingGamesPage({super.key});

  @override
  State<MyUpcomingGamesPage> createState() => _MyUpcomingGamesPageState();
}

class _MyUpcomingGamesPageState extends State<MyUpcomingGamesPage> {
  final generalBloc = locator<GeneralBloc>();
  final gamesBloc = locator<GamesBloc>();

  @override
  void initState() {
    super.initState();
    generalBloc.add(GetUpcomingGamesEvent());
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GeneralBloc, GeneralState>(
      bloc: generalBloc,
      listener: (context, state) {},
      builder: (context, state) {
        final upcomingGames = GameDataHelper.sortUpcomingGames(generalBloc.upcomingGames);

        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.upcoming_games.tr())),
          body: state is GeneralLoading && upcomingGames.isEmpty
              ? const LoadingWidget()
              : upcomingGames.isEmpty
              ? Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(horizontal: 24.w),
                    child: Text(
                      LocaleKeys.no_data_found.tr(),
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: AppColors.lightTextColor),
                    ),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  itemCount: upcomingGames.length,
                  itemBuilder: (context, index) {
                    final game = upcomingGames[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 12.h),
                      child: UpcomingGameCard(
                        game: game,
                        gamesBloc: gamesBloc,
                        onTap: () {
                          context.router.push(
                            GameDetailsRoute(bloc: gamesBloc..gameDetails = game),
                          );
                        },
                      ),
                    );
                  },
                ),
        );
      },
    );
  }
}
