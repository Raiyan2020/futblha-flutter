import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../application/config/app_assets.dart';

class ToolbarWidget extends StatelessWidget {
  final String title;
  final bool showTitle;

  const ToolbarWidget({super.key, this.title = '', this.showTitle = false});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      centerTitle: true,
      title: showTitle
          ? Text(
              title,
              style: Theme.of(context).textTheme.headlineLarge,
            )
          : null,
      leading: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        alignment: Alignment.centerLeft,
        child: SvgPicture.asset(AppAssets.leftArrow),
      ),
    );
  }
}
