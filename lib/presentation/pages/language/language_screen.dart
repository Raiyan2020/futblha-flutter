import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../application/config/app_assets.dart';
import '../../../application/config/design_system/app_colors.dart';
import '../../../application/config/l10n.dart';
import '../../../application/core/utils/auto_router_setup/app_router.dart';
import '../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../generated/locale_keys.g.dart';

@RoutePage()
class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          logoWidget(context),
          Align(alignment: Alignment.bottomCenter, child: languagesButtons()),
        ],
      ),
    );
  }

  Expanded logoWidget(BuildContext context) {
    return Expanded(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Hero(
            tag: 'logo',
            child: Center(child: Image.asset(AppAssets.logoPNG, height: 200)),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Column languagesButtons() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          LocaleKeys.select_language_to_continue.tr(),
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 24),
        englishButton(),
        const SizedBox(height: 16),
        arabicButton(),
        const SizedBox(height: 50),
      ],
    );
  }

  GestureDetector englishButton() {
    return GestureDetector(
      onTap: () {
        CacheManager.instance.setLanguage(L10n.langEn.languageCode);
        context.setLocale(L10n.langEn);
        context.router.push(const LoginRoute());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'ENGLISH',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: AppColors.primaryColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }

  GestureDetector arabicButton() {
    return GestureDetector(
      onTap: () {
        CacheManager.instance.setLanguage(L10n.langAr.languageCode);
        context.setLocale(L10n.langAr);
        context.router.push(const LoginRoute());
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 24),
        width: double.infinity,
        height: 48,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          border: Border.all(color: AppColors.primaryColor),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Text(
            'عربي',
            style: GoogleFonts.cairo(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: AppColors.primaryWhite,
            ),
          ),
        ),
      ),
    );
  }
}
