import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

enum GameResult { team1Win, tie, team2Win }

class GameResultBottomSheet {
  static Future<GameResult?> show(
    BuildContext context, {
    required String team1Name,
    required String? team1Image,
    required String team2Name,
    required String? team2Image,
  }) async {
    GameResult? selectedResult;

    return await showModalBottomSheet<GameResult>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Container(
              padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
              decoration: BoxDecoration(
                color: context.cardBackground,
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: EdgeInsets.all(24.w),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Handle bar
                    Container(
                      width: 40.w,
                      height: 4.h,
                      decoration: BoxDecoration(
                        color: AppColors.primaryGrey,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    24.heightBox(),
                    // Title
                    Text(
                      LocaleKeys.game_result.tr(),
                      style: TextStyle(
                        color: context.textSecondary,
                        fontSize: 20,
                        fontWeight: FontWeight.w600,
                      ),
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
                    24.heightBox(),
                    // Game Outcome Options
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildResultOption(
                          context,
                          teamName: team1Name,
                          teamImage: team1Image,
                          isSelected: selectedResult == GameResult.team1Win,
                          onTap: () => setState(() => selectedResult = GameResult.team1Win),
                        ),
                        _buildResultOption(
                          context,
                          teamName: LocaleKeys.we_tied.tr(),
                          teamImage: null,
                          isTie: true,
                          isSelected: selectedResult == GameResult.tie,
                          onTap: () => setState(() => selectedResult = GameResult.tie),
                        ),
                        _buildResultOption(
                          context,
                          teamName: team2Name,
                          teamImage: team2Image,
                          isSelected: selectedResult == GameResult.team2Win,
                          onTap: () => setState(() => selectedResult = GameResult.team2Win),
                        ),
                      ],
                    ),
                    24.heightBox(),
                    // Continue Button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: selectedResult != null
                            ? () {
                                Navigator.of(context).pop(selectedResult);
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryColor,
                          padding: EdgeInsets.symmetric(vertical: 16.h),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                          disabledBackgroundColor: context.mutedBackground,
                        ),
                        child: Text(
                          LocaleKeys.continue_key.tr(),
                          style: const TextStyle(
                            color: AppColors.primaryWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  static Widget _buildResultOption(
    BuildContext context, {
    required String teamName,
    String? teamImage,
    bool isTie = false,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 155.w,
        width: 100.w,
        padding: EdgeInsets.all(16.w),
        decoration: BoxDecoration(
          color: isSelected ? context.chipBackground : context.mutedBackground,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : context.borderColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: .spaceBetween,
          children: [
            // Selection Indicator
            Align(
              alignment: Alignment.topRight,
              child: Container(
                width: 20,
                height: 20,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? AppColors.primaryColor : context.cardBackground,
                  border: Border.all(
                    color: isSelected ? AppColors.primaryColor : AppColors.primaryGrey,
                    width: 2,
                  ),
                ),
                child: isSelected
                    ? const Icon(Icons.check, size: 12, color: AppColors.primaryWhite)
                    : null,
              ),
            ),
            12.heightBox(),
            // Image or Icon
            if (isTie)
              Icon(Icons.handshake, size: 40, color: context.brandOnSurface)
            else
              CircleAvatar(
                radius: 25,
                backgroundImage: teamImage != null
                    ? NetworkImage(teamImage)
                    : AssetImage(AppAssets.ic_profile),
                backgroundColor: context.mutedBackground,
                onBackgroundImageError: (_, _) {},
              ),
            12.heightBox(),
            // Team Name
            Text(
              teamName,
              style: TextStyle(
                color: context.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}
