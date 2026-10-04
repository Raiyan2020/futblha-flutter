import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/presentation/pages/games/create_game_page.dart';
import 'package:futblha/generated/locale_keys.g.dart';

/// Game Type Selection Page
///
/// Note: Game types are hardcoded as there is no API endpoint for game types.
/// The available game types are:
/// - My Diwaniya Only: Game between diwaniya members only
/// - Private Game: Game between diwaniya members & chosen opposing diwaniya
/// - Public Game: Game between diwaniya members & other app members
@RoutePage()
class GameTypeSelectionPage extends StatelessWidget {
  const GameTypeSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(LocaleKeys.create_game.tr())),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 20.w, vertical: 24.h),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              LocaleKeys.choose_game_type.tr(),
              style: const TextStyle(
                color: AppColors.primaryBlack,
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            24.heightBox(),
            _buildGameTypeOption(
              context,
              title: LocaleKeys.my_diwaniya_only.tr(),
              description: LocaleKeys.my_diwaniya_only_description.tr(),
              gameType: GameType.myDiwaniyaOnly,
            ),
            16.heightBox(),
            _buildGameTypeOption(
              context,
              title: LocaleKeys.private_game.tr(),
              description: LocaleKeys.private_game_description.tr(),
              gameType: GameType.privateGame,
            ),
            16.heightBox(),
            _buildGameTypeOption(
              context,
              title: LocaleKeys.public_game.tr(),
              description: LocaleKeys.public_game_description.tr(),
              gameType: GameType.publicGame,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameTypeOption(
    BuildContext context, {
    required String title,
    required String description,
    required GameType gameType,
  }) {
    return GestureDetector(
      onTap: () {
        context.router.push(CreateGameRoute(gameType: gameType)).then((value) {
          if (value == true) {
            context.router.pop(true);
          }
        });
      },
      child: Container(
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: AppColors.secondaryColor,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  8.heightBox(),
                  Text(
                    description,
                    style: const TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ),
            ),
            12.widthBox(),
            const Icon(Icons.arrow_forward_ios, color: AppColors.primaryColor, size: 16),
          ],
        ),
      ),
    );
  }
}
