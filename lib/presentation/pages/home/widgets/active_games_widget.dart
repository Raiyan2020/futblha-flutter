import 'package:flutter/material.dart';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/basecomponents/base_view_model_view.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/presentation/pages/general/bloc/general_bloc.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/response_model/games/game_player_model.dart';

import '../../../../application/core/utils/helpers/extension_functions/date_extension_functions.dart';
import '../../../widgets/app_size_boxes.dart';

class ActiveGamesWidget extends StatelessWidget {
  const ActiveGamesWidget(this.generalBloc, {super.key});
  final GeneralBloc generalBloc;

  List<GameModel> _getActiveGames(GeneralBloc generalBloc) {
    // Use home API active games data
    final activeGames = generalBloc.homeData?.activeGames ?? [];
    return activeGames.take(2).toList();
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<GeneralBloc, GeneralState>(
      bloc: generalBloc,
      listener: (context, state) {},
      builder: (context, state) {
        final activeGames = _getActiveGames(generalBloc);

        if (activeGames.isEmpty) {
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
                    LocaleKeys.active_games.tr(),
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                  ),
                  GestureDetector(
                    onTap: () {
                      context.router.push(const ActiveGamesRoute());
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
            if (state is GeneralLoading && activeGames.isEmpty)
              SizedBox(
                height: 190.h,
                child: const Center(child: CircularProgressIndicator()),
              )
            else if (activeGames.isEmpty)
              const SizedBox.shrink()
            else
              SizedBox(
                height: 190.h,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  itemCount: activeGames.length,
                  itemBuilder: (context, index) {
                    return GestureDetector(
                      onTap: () {
                        // Navigate to active games page - user can select game there
                        context.router.push(const ActiveGamesRoute());
                      },
                      child: _buildGameCard(context, activeGames[index]),
                    );
                  },
                ),
              ),
          ],
        );
      },
    );
  }

  Widget _buildGameCard(BuildContext context, GameModel game) {
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
      width: 280.w,
      margin: EdgeInsets.only(right: 12.w),
      padding: EdgeInsets.all(16.w),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
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
                            color: AppColors.primaryLiteGrey,
                            child: const Icon(Icons.person, color: AppColors.primaryColor),
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
                            color: AppColors.primaryLiteGrey,
                            child: const Icon(Icons.person, color: AppColors.primaryColor),
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
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(
                      creatorName,
                      style: const TextStyle(
                        color: AppColors.lightTextColor,
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
          Row(
            children: [
              _buildStackedAvatars(
                context: context,
                maxVisible: 6,
                count: joinedPlayers,
                players: players,
              ),
              if (joinedPlayers > 6)
                Container(
                  margin: EdgeInsetsDirectional.only(start: 4),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLiteGrey,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '+${joinedPlayers - 6}',
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              const Spacer(),
              Text(
                '${joinedPlayers} ${LocaleKeys.of.tr()} ${totalPlayers} ${LocaleKeys.player_joined.tr()}',
                style: const TextStyle(
                  color: AppColors.lightTextColor,
                  fontSize: 11,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
          12.heightBox(),
          Row(
            children: [
              _buildInfoRow(icon: AppAssets.ic_calender, text: dateStr),
              8.widthBox(),
              _buildInfoRow(icon: Icons.access_time, text: timeStr),
            ],
          ),
          8.heightBox(),
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
                border: Border.all(color: Colors.white, width: 2),
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
            return const CircleAvatar(
              radius: 12,
              backgroundColor: AppColors.primaryLiteGrey,
              child: Icon(Icons.person, size: 14, color: AppColors.primaryColor),
            );
          },
        ),
      );
    }
    return const CircleAvatar(
      radius: 12,
      backgroundColor: AppColors.primaryLiteGrey,
      child: Icon(Icons.person, size: 14, color: AppColors.primaryColor),
    );
  }

  Widget _buildInfoRow({required dynamic icon, required String text}) {
    final isSvg = icon is String;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
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
              colorFilter: const ColorFilter.mode(AppColors.primaryColor, BlendMode.srcIn),
            )
          else
            Icon(icon as IconData, size: 14, color: AppColors.primaryColor),
          8.widthBox(),
          Flexible(
            child: Text(
              text,
              style: const TextStyle(
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
