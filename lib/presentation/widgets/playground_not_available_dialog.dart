import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../application/config/app_assets.dart';
import '../../application/config/design_system/app_colors.dart';
import '../../application/core/utils/helpers/extension_functions/size_extension.dart';
import '../../generated/locale_keys.g.dart';
import 'app_size_boxes.dart';
import 'custom_elevated_button.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

class PlaygroundNotAvailableDialog extends StatelessWidget {
  final String playgroundName;
  final VoidCallback onContinue;

  const PlaygroundNotAvailableDialog({
    super.key,
    required this.playgroundName,
    required this.onContinue,
  });

  static Future<void> show(
    BuildContext context, {
    required String playgroundName,
    required VoidCallback onContinue,
  }) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) =>
          PlaygroundNotAvailableDialog(playgroundName: playgroundName, onContinue: onContinue),
    );
  }

  @override
  Widget build(BuildContext context) {
    final message = LocaleKeys.playground_not_available_at_game_time.tr(
      namedArgs: {'playground': playgroundName},
    );

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 16.h),
        decoration: BoxDecoration(
          color: context.cardBackground,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Close button
            Align(
              alignment: Alignment.topRight,
              child: IconButton(
                icon: const Icon(Icons.close, color: AppColors.primaryDarkGrey),
                onPressed: () => Navigator.of(context).pop(),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
            ),
            // Error icon - red circle with exclamation
            Center(
              child: Image.asset(AppAssets.warning_red, width: 60.w, height: 60.h),
            ),

            24.heightBox(),
            // Title "Sorry!" in red
            Text(
              LocaleKeys.sorry.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryRed,
              ),
              textAlign: TextAlign.center,
            ),
            16.heightBox(),
            // Message in dark gray
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: context.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            24.heightBox(),
            // Continue button (green)
            CustomElevatedButton(
              title: LocaleKeys.continue_key.tr(),
              onPressed: () {
                Navigator.of(context).pop();
                onContinue();
              },
            ),
          ],
        ),
      ),
    );
  }
}
