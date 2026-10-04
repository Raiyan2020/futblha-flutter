import 'package:futblha/presentation/widgets/custom_text.dart';
import 'package:easy_localization/easy_localization.dart' as localization;
import 'package:flutter/material.dart';
import '../../application/config/l10n.dart';
import '../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../generated/locale_keys.g.dart';

class LanguageButton extends StatelessWidget {
  final BuildContext parentContext;
  final Function onChange;

  const LanguageButton({super.key, required this.parentContext, required this.onChange});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        final language = CacheManager.instance.getLanguage() ?? 'en';
        CacheManager.instance.setLanguage(
          language == 'ar' ? L10n.langEn.languageCode : L10n.langAr.languageCode,
        );
        parentContext.setLocale(language == 'ar' ? L10n.langEn : L10n.langAr);
        Future.delayed(const Duration(seconds: 2), onChange());
      },
      child: Directionality(
        textDirection: CacheManager.instance.getLanguage() == 'ar'
            ? TextDirection.ltr
            : TextDirection.rtl,
        child: const CustomText(LocaleKeys.language),
      ),
    );
  }
}
