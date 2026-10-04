import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../application/config/app_assets.dart';
import '../../application/config/design_system/app_colors.dart';
import '../../application/core/utils/auto_router_setup/app_router.dart';
import '../../application/core/utils/helpers/extension_functions/size_extension.dart';
import '../../generated/locale_keys.g.dart';
import 'app_size_boxes.dart';
import 'custom_elevated_button.dart';

class LoginRequiredDialog extends StatelessWidget {
  const LoginRequiredDialog({super.key});

  static Future<void> show(BuildContext context) {
    return showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const LoginRequiredDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10.w, vertical: 10.w),
        decoration: BoxDecoration(
          color: Color(0xffF6FDFB),
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
            // Warning icon
            Container(
              width: 80.w,
              height: 80.h,
              decoration: const BoxDecoration(shape: BoxShape.circle, color: AppColors.primaryRed),
              child: Center(
                child: Image.asset(AppAssets.warning_red, width: 40.w, height: 40.h),
              ),
            ),
            24.heightBox(),
            // Title
            Text(
              LocaleKeys.login_required.tr(),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: AppColors.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            16.heightBox(),
            // Message
            Text(
              LocaleKeys.you_must_login_first.tr(),
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w400,
                color: AppColors.primaryDark,
              ),
              textAlign: TextAlign.center,
            ),
            24.heightBox(),
            // Login button
            CustomElevatedButton(
              title: LocaleKeys.sign_in.tr(),
              onPressed: () {
                Navigator.of(context).pop();
                context.router.pushAndPopUntil(const LoginRoute(), predicate: (_) => false);
              },
            ),
          ],
        ),
      ),
    );
  }
}
