import 'package:auto_route/auto_route.dart';
import 'package:flutter_svg/svg.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:flutter/material.dart';

import '../../../application/config/app_assets.dart';
import '../../../application/config/design_system/app_colors.dart';
import '../../../application/core/utils/auto_router_setup/app_router.dart';
import '../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../auth/bloc/authentication_bloc.dart';
import '../general/bloc/general_bloc.dart';
import '../games/bloc/games_bloc.dart';
import 'widgets/home_banner_widget.dart';
import 'widgets/diwaniya_ranking_widget.dart';
import 'widgets/active_games_widget.dart';
import 'widgets/upcoming_games_home_widget.dart';
import 'widgets/playgrounds_widget.dart';
import 'widgets/game_result_dialog.dart';

@RoutePage()
class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final authBloc = locator<AuthenticationBloc>();
  final generalBloc = locator<GeneralBloc>();
  final gamesBloc = locator<GamesBloc>();
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final searchController = TextEditingController();
  bool _gameResultDialogOpen = false;

  @override
  void initState() {
    super.initState();
    final hasToken = CacheManager.instance.getAuthToken().isNotEmpty;
    final isGuest = CacheManager.instance.isGuestMode();
    final isAuthenticated = hasToken || isGuest;
    // Only fetch when user is still authenticated (avoids home/games-result after logout)
    if (isAuthenticated && generalBloc.homeData == null) {
      generalBloc.add(GetHomeEvent());
    }
    // Games result requires auth; skip when no token to avoid 401 after logout
    if (hasToken && !isGuest) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) gamesBloc.add(const GetGamesResultEvent());
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<AuthenticationBloc, AuthenticationState>(
      bloc: authBloc,
      listener: (context, state) {},
      builder: (context, authState) {
        return CustomBlocConsumer<GamesBloc, GamesState>(
          bloc: gamesBloc,
          listener: (context, state) {
            if (state is GamesResultLoaded && state.games.isNotEmpty && !_gameResultDialogOpen) {
              _gameResultDialogOpen = true;
              GameResultDialog.showIfNeeded(context, gamesBloc).then((_) {
                if (mounted) setState(() => _gameResultDialogOpen = false);
              });
            }
          },
          builder: (context, gamesState) {
            return Scaffold(
              key: _scaffoldKey,
              appBar: AppBar(
                title: SvgPicture.asset(
                  Theme.of(context).brightness == Brightness.dark
                      ? AppAssets.white_logo
                      : AppAssets.home_logo,
                ),
                automaticallyImplyLeading: false,
                centerTitle: false,
                actions: [
                  if (!CacheManager.instance.isGuestMode())
                    Container(
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        color: AppColors.secondaryColor,
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: IconButton(
                        onPressed: () {
                          context.router.push(NotificationsRoute());
                        },
                        icon: const Icon(Icons.notifications_none, color: AppColors.primaryColor),
                      ),
                    ),
                ],
              ),
              body: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    12.heightBox(),
                    // Banner Section
                    HomeBannerWidget(generalBloc),
                    20.heightBox(),
                    // Diwaniya Ranking Section
                    DiwaniyaRankingWidget(generalBloc),

                    // Active Games Section
                    ActiveGamesWidget(generalBloc),

                    // My Upcoming Games Section (matches user is registered for)
                    UpcomingGamesHomeWidget(generalBloc),
                    20.heightBox(),
                    // Playgrounds Section
                    PlaygroundsWidget(generalBloc),
                    20.heightBox(),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
