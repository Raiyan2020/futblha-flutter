import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futblha/presentation/pages/games/bloc/games_bloc.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:futblha/presentation/widgets/snackbar_utill.dart';

import '../../../application/core/utils/auto_router_setup/app_router.dart';
import '../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../application/core/utils/helpers/extension_functions/date_extension_functions.dart';
import '../../../data/models/response_model/games/game_model.dart';
import '../../../data/models/response_model/games/game_player_model.dart';
import '../../../generated/locale_keys.g.dart';
import '../../widgets/login_required_dialog.dart';

@RoutePage()
class ActiveGamesPage extends StatefulWidget {
  const ActiveGamesPage({super.key});

  @override
  State<ActiveGamesPage> createState() => _ActiveGamesPageState();
}

class _ActiveGamesPageState extends State<ActiveGamesPage> {
  final gamesBloc = locator<GamesBloc>();

  @override
  void initState() {
    super.initState();
    gamesBloc.add(GetActiveGamesEvent());
  }

  List<GameModel> _getActiveGames(GamesBloc bloc) {
    return bloc.activeGames;
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
        final activeGames = _getActiveGames(gamesBloc);

        return Scaffold(
          appBar: AppBar(title: Text(LocaleKeys.active_games.tr())),
          body: state is GamesLoading && activeGames.isEmpty
              ? const LoadingWidget()
              : activeGames.isEmpty
              ? Center(
                  child: Text(
                    LocaleKeys.no_active_games_found.tr(),
                    style: TextStyle(color: AppColors.lightTextColor, fontSize: 16),
                  ),
                )
              : ListView.builder(
                  padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 16.h),
                  itemCount: activeGames.length,
                  itemBuilder: (context, index) {
                    final game = activeGames[index];
                    return Padding(
                      padding: EdgeInsets.only(bottom: 16.h),
                      child: InkWell(
                        onTap: () {
                          if (CacheManager.instance.isGuestMode()) {
                            LoginRequiredDialog.show(context);
                            return;
                          }
                          context.router
                              .push(
                                GameDetailsRoute(
                                  bloc: gamesBloc..gameDetails = GameModel(id: game.id),
                                ),
                              )
                              .then((value) {
                                if (value == true) gamesBloc.add(GetActiveGamesEvent());
                              });
                        },
                        child: _buildGameCard(game),
                      ),
                    );
                  },
                ),
        );
      },
    );
  }

  Widget _buildGameCard(GameModel game) {
    final joinedPlayers = int.tryParse(game.playersJoines?.toString() ?? '0') ?? 0;
    final totalPlayers = int.tryParse(game.playersTarget?.toString() ?? '0') ?? 0;
    final creatorName = game.creatorName ?? '';
    final diwaniyaName = game.creatorDiwaniya?.name ?? '';
    final diwaniyaImage = game.creatorDiwaniya?.image ?? AppAssets.ic_profile;
    final players = game.players ?? [];

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

    final location = game.booking?.playground?.name ?? '';

    return Container(
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: context.cardBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: context.borderColor, width: 1),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryBlack.withValues(alpha: 0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Diwaniya Info Row
          Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: diwaniyaImage.startsWith('http')
                    ? Image.network(
                        diwaniyaImage,
                        width: 40.w,
                        height: 40.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40.w,
                            height: 40.h,
                            color: context.mutedBackground,
                            child: Icon(Icons.person, color: context.brandOnSurface),
                          );
                        },
                      )
                    : Image.asset(
                        diwaniyaImage,
                        width: 40.w,
                        height: 40.h,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            width: 40.w,
                            height: 40.h,
                            color: context.mutedBackground,
                            child: Icon(Icons.person, color: context.brandOnSurface),
                          );
                        },
                      ),
              ),
              12.widthBox(),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diwaniyaName,
                      style: TextStyle(
                        color: context.brandOnSurface,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    4.heightBox(),
                    Text(
                      creatorName,
                      style: TextStyle(
                        color: context.textPrimary,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          12.heightBox(),
          // Player Count Row
          Row(
            children: [
              _buildStackedAvatars(
                context: context,
                maxVisible: 3,
                count: joinedPlayers,
                players: players,
              ),
              if (joinedPlayers > 3)
                Container(
                  margin: EdgeInsetsDirectional.only(start: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: context.mutedBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${joinedPlayers - 3}',
                    style: TextStyle(
                      color: context.brandOnSurface,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Spacer(),
              RichText(
                text: TextSpan(
                  style: TextStyle(
                    color: context.textPrimary,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                  children: [
                    TextSpan(text: '${joinedPlayers} ${LocaleKeys.of.tr()} '),
                    TextSpan(
                      text: '${totalPlayers}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    TextSpan(text: ' ${LocaleKeys.player_joined.tr()}'),
                  ],
                ),
              ),
            ],
          ),
          12.heightBox(),
          // Date and Time Row
          Row(
            children: [
              _buildInfoRow(icon: AppAssets.ic_calender, text: dateStr),
              8.widthBox(),
              _buildInfoRow(icon: Icons.access_time, text: timeStr),
            ],
          ),
          8.heightBox(),
          // Location Row
          _buildInfoRow(icon: Icons.location_on, text: location),
        ],
      ),
    );
  }

  Widget _buildStackedAvatars({
    required BuildContext context,
    required int maxVisible,
    required int count,
    required List<GamePlayerModel> players,
  }) {
    const avatarSize = 24.0;
    const overlap = 8.0;
    final visibleCount = count > maxVisible ? maxVisible : count;
    if (visibleCount <= 0) return const SizedBox.shrink();
    final step = avatarSize - overlap;
    final stackWidth = avatarSize + (visibleCount - 1) * step;
    final isRTL = context.locale.languageCode == 'ar';

    return SizedBox(
      width: stackWidth,
      height: avatarSize,
      child: Stack(
        clipBehavior: Clip.none,
        children: List.generate(visibleCount, (index) {
          final left = isRTL ? stackWidth - avatarSize - (index * step) : (index * step).toDouble();
          return Positioned(
            left: left,
            top: 0,
            child: Container(
              width: avatarSize,
              height: avatarSize,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: context.cardBackground, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.12),
                    blurRadius: 2,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: ClipOval(
                child: _buildPlayerAvatar(index < players.length ? players[index].image : null),
              ),
            ),
          );
        }),
      ),
    );
  }

  Widget _buildPlayerAvatar(String? imageUrl) {
    if (imageUrl != null && imageUrl.isNotEmpty) {
      return ClipOval(
        child: Image.network(
          imageUrl,
          width: 24,
          height: 24,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return CircleAvatar(
              radius: 12,
              backgroundColor: context.mutedBackground,
              child: Icon(Icons.person, size: 14, color: context.brandOnSurface),
            );
          },
        ),
      );
    }
    return CircleAvatar(
      radius: 12,
      backgroundColor: context.mutedBackground,
      child: Icon(Icons.person, size: 14, color: context.brandOnSurface),
    );
  }

  Widget _buildInfoRow({required dynamic icon, required String text}) {
    final isSvg = icon is String;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: context.chipBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isSvg)
            SvgPicture.asset(
              icon,
              width: 14,
              height: 14,
              colorFilter: ColorFilter.mode(context.brandOnSurface, BlendMode.srcIn),
            )
          else
            Icon(icon as IconData, size: 14, color: context.brandOnSurface),
          8.widthBox(),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                color: context.brandOnSurface,
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
