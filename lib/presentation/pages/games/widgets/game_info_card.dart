import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/date_extension_functions.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/generated/locale_keys.g.dart';

class GameInfoCard extends StatelessWidget {
  const GameInfoCard({
    super.key,
    required this.game,
    this.onChatPressed,
  });

  final GameModel game;
  final VoidCallback? onChatPressed;

  static String _formatTimePeriods(List<dynamic> periods) {
    if (periods.isEmpty) return '';
    final first = periods.first;
    final last = periods.last;
    final start = first.startTime ?? '';
    final end = last.endTime ?? '';
    return '$start - $end';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(12.w),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderGrey, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              if (game.type != null) _buildTypeChip(game.type!),
              if (game.userPermission?.isMember == true) _buildChatButton(context),
            ],
          ),
          _buildTeamsRow(context),
          10.heightBox(),
          Text(
            '${LocaleKeys.creator.tr()} : ${game.creatorName ?? ''}',
            style: TextStyle(
              color: AppColors.lightTextColor,
              fontSize: 12,
              fontWeight: FontWeight.w400,
            ),
          ),
          8.heightBox(),
          Wrap(
            spacing: 8.w,
            runSpacing: 8.h,
            children: _buildInfoChips(context),
          ),
        ],
      ),
    );
  }

  Widget _buildTypeChip(String type) {
    final label = type == 'private'
        ? LocaleKeys.private.tr()
        : type == 'public'
            ? LocaleKeys.public.tr()
            : LocaleKeys.my_diwaniya_game_type.tr();
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: AppColors.primaryColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildChatButton(BuildContext context) {
    return Stack(
      children: [
        IconButton(
          onPressed: () {
            onChatPressed?.call();
            if (game.id != null) {
              context.router.push(ChatRoute(gameId: game.id!));
            } else {
              context.router.push(ChatRoute());
            }
          },
          icon: Icon(Icons.chat_outlined, color: AppColors.primaryColor),
        ),
        if (game.unreadMessagesCount != null && game.unreadMessagesCount! > 0)
          Positioned(
            right: 0,
            top: 0,
            child: Container(
              padding: EdgeInsets.all(4.w),
              margin: EdgeInsets.all(4.w),
              decoration: const BoxDecoration(
                color: AppColors.primaryRed,
                shape: BoxShape.circle,
              ),
              child: Text(
                game.unreadMessagesCount.toString(),
                style: TextStyle(
                  color: AppColors.primaryWhite,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTeamsRow(BuildContext context) {
    final isMyDiwanyaGame = game.type == 'my_diwanya';
    final team1Name = isMyDiwanyaGame
        ? LocaleKeys.team_1.tr()
        : (game.creatorDiwaniya?.name ?? '');
    final team1Image = game.creatorDiwaniya?.image;
    final team2Name = isMyDiwanyaGame
        ? LocaleKeys.team_2.tr()
        : (game.opponentDiwaniya?.name ?? LocaleKeys.opposing_team.tr());
    final team2Image = isMyDiwanyaGame
        ? game.creatorDiwaniya?.image
        : game.opponentDiwaniya?.image;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _TeamLogo(name: team1Name, imageUrl: team1Image),
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
        _TeamLogo(name: team2Name, imageUrl: team2Image),
      ],
    );
  }

  List<Widget> _buildInfoChips(BuildContext context) {
    final chips = <Widget>[];

    if (game.booking?.bookingDate != null) {
      chips.add(_InfoChip(
        icon: Icons.calendar_today,
        text: game.booking!.bookingDate!.toLocal().formatDateToCustomString(),
      ));
    }
    if (game.booking?.periods != null && game.booking!.periods!.isNotEmpty) {
      chips.add(_InfoChip(
        icon: Icons.access_time,
        text: _formatTimePeriods(game.booking!.periods!),
      ));
    }
    if (game.playersTarget != null) {
      final totalPlayers = int.tryParse(game.playersTarget?.toString() ?? '0') ?? 0;
      final perTeam = totalPlayers ~/ 2;
      chips.add(_InfoChip(
        icon: Icons.people,
        text: '$perTeam  ${LocaleKeys.vs.tr()} $perTeam',
      ));
    }
    if (game.booking?.playground?.name != null) {
      chips.add(_InfoChip(
        icon: Icons.location_on,
        text: game.booking!.playground!.name ?? '',
      ));
    }
    if (game.gameStatusText != null) {
      chips.add(
        Container(
          padding: EdgeInsets.symmetric(horizontal: 12.w, vertical: 4.h),
          decoration: BoxDecoration(
            color: AppColors.primaryYellow.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            game.gameStatusText ?? '',
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 11,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      );
    }
    return chips;
  }
}

class _TeamLogo extends StatelessWidget {
  const _TeamLogo({required this.name, this.imageUrl});

  final String name;
  final String? imageUrl;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50.h,
          height: 50.h,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.primaryLiteGrey,
          ),
          child: ClipOval(
            child: imageUrl != null && imageUrl!.isNotEmpty
                ? Image.network(
                    imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.person, color: AppColors.primaryColor, size: 30),
                  )
                : Image.asset(
                    AppAssets.ic_profile,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) =>
                        Icon(Icons.person, color: AppColors.primaryColor, size: 30),
                  ),
          ),
        ),
        8.heightBox(),
        Text(
          name,
          style: TextStyle(
            color: AppColors.primaryColor,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _InfoChip extends StatelessWidget {
  const _InfoChip({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.w, vertical: 4.h),
      decoration: BoxDecoration(
        color: AppColors.secondaryColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppColors.primaryColor),
          4.widthBox(),
          Flexible(
            child: Text(
              text,
              style: TextStyle(
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
