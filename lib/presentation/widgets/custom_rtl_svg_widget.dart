import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../application/config/l10n.dart';
import '../../application/core/utils/helpers/cache/cache_manager.dart';

class RtlSvgAssetWidget extends StatelessWidget {
  final String svgAssetPath;

  const RtlSvgAssetWidget({super.key, required this.svgAssetPath});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Transform(
        alignment: Alignment.center,
        transform: Matrix4.rotationY(getRotationAngleBasedOnLocalization(context)),
        child: SvgPicture.asset(
          svgAssetPath,
          // Other SvgPicture properties go here
        ),
      ),
    );
  }
}


extension RtlSvgAssetWidgetExtension on RtlSvgAssetWidget {
  double getRotationAngleBasedOnLocalization(BuildContext context) {
    // Get the locale from EasyLocalization
   final currentLocale = CacheManager.instance.getSavedLocale();

    // Example: If the current locale is 'en', return a different angle
    return currentLocale == L10n.langEn ? 0.0 : 3.141;
  }
}