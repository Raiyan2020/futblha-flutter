import 'dart:async';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../application/config/design_system/app_colors.dart';
import '../../application/core/utils/auto_router_setup/app_router.dart';

@RoutePage()
class CustomSuccessPage extends StatefulWidget {
  final String iconPath;
  final String title;
  final String message;
  final VoidCallback? onButtonPress;
  final Duration autoNavigateDuration; // Configurable duration
  final Function()? navigationCallback;

  const CustomSuccessPage({super.key,
    required this.iconPath,
    required this.title,
    required this.message,
    this.onButtonPress,
    this.autoNavigateDuration =
        const Duration(seconds: 3), // Default duration is 3 seconds
    this.navigationCallback, // Nullable route object
  });

  @override
  State<CustomSuccessPage> createState() => _CustomSuccessPageState();
}

class _CustomSuccessPageState extends State<CustomSuccessPage> {
  @override
  void initState() {
    super.initState();
    // Add a delay for automatic navigation
    Timer(widget.autoNavigateDuration, () {
      // Navigate to another page using AutoRoute with the configurable route object
      if (widget.navigationCallback != null) {
        widget.navigationCallback!();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primaryColor,
      body: Center(
        child: FractionallySizedBox(
          widthFactor: 0.9,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const Spacer(),
              widget.iconPath.endsWith('png') == true
                  ? Image.asset(
                      widget.iconPath,
                      width: 80,
                      height: 80,
                    )
                  : SvgPicture.asset(widget.iconPath),
              const SizedBox(height: 40),
              Text(
                widget.title,
                style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      color: AppColors.primaryWhite,
                      fontWeight: FontWeight.bold,
                    ),
              ),
              const SizedBox(height: 16),
              Text(
                widget.message,
                textAlign: TextAlign.center,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: AppColors.primaryWhite,
                    ),
              ),
              const Spacer(),
              if (widget.onButtonPress != null) doneButton(context),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Widget doneButton(BuildContext context) {
    return FractionallySizedBox(
      widthFactor: 1,
      child: ElevatedButton(
        onPressed: (){
          context.router.pushAndPopUntil(const HomeRoute(), predicate: (_) => false);
        },
        style: ButtonStyle(
          backgroundColor:
              WidgetStateProperty.all<Color?>(AppColors.primaryWhite),
        ),
        child: Text(
          LocaleKeys.ok_button.tr().toUpperCase(),
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w700,
              ),
        ),
      ),
    );
  }
}
