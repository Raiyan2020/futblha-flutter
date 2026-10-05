import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/data/models/enums/position_enum.dart';
import 'package:futblha/data/models/response_model/games/game_player_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

/// Shows the details the game already has for a player (photo, name, position).
class PlayerInfoBottomSheet extends StatelessWidget {
  const PlayerInfoBottomSheet({super.key, required this.player});

  final GamePlayerModel player;

  static Future<void> show(BuildContext context, GamePlayerModel player) {
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => PlayerInfoBottomSheet(player: player),
    );
  }

  String get _positionLabel {
    if (player.positionText != null && player.positionText!.isNotEmpty) {
      return player.positionText!;
    }
    final key = player.position;
    if (key == null || key.isEmpty) return '';
    return Position.fromKey(key)?.displayName ?? key;
  }

  @override
  Widget build(BuildContext context) {
    final image = player.image;
    final position = _positionLabel;

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: SafeArea(
        top: false,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              margin: EdgeInsets.only(top: 12.h),
              width: 40.w,
              height: 4.h,
              decoration: BoxDecoration(
                color: context.mutedBackground,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            24.heightBox(),
            CircleAvatar(
              radius: 45,
              backgroundColor: context.mutedBackground,
              backgroundImage: image != null && image.isNotEmpty ? NetworkImage(image) : null,
              onBackgroundImageError: image != null && image.isNotEmpty ? (_, _) {} : null,
              child: image == null || image.isEmpty
                  ? Icon(Icons.person, color: context.brandOnSurface, size: 45)
                  : null,
            ),
            16.heightBox(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Text(
                player.name ?? '',
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
              ),
            ),
            if (position.isNotEmpty) ...[
              16.heightBox(),
              Container(
                margin: EdgeInsets.symmetric(horizontal: 20.w),
                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 12.h),
                decoration: BoxDecoration(
                  color: context.chipBackground,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  children: [
                    Icon(Icons.sports_soccer, color: context.brandOnSurface, size: 20),
                    8.widthBox(),
                    Text(
                      LocaleKeys.playing_position.tr(),
                      style: const TextStyle(color: AppColors.lightTextColor, fontSize: 14),
                    ),
                    const Spacer(),
                    Text(
                      position,
                      style: TextStyle(
                        color: context.brandOnSurface,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
            24.heightBox(),
          ],
        ),
      ),
    );
  }
}
