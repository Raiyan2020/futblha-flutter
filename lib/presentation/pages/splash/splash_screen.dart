import 'dart:async';
import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import '../../../application/config/app_assets.dart';
import '../../../application/config/l10n.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/auto_router_setup/app_router.dart';
import '../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../application/core/utils/helpers/maintenance_check/maintenance_check_helper.dart';
import '../auth/bloc/authentication_bloc.dart';

@RoutePage()
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with TickerProviderStateMixin {
  bool animateOut = false;
  bool showLogo = false;
  bool _isClosedForMaintenance = false;

  @override
  void initState() {
    super.initState();

    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [SystemUiOverlay.top, SystemUiOverlay.bottom],
    );

    Future.delayed(const Duration(milliseconds: 300), () {
      if (!mounted) return;
      setState(() => animateOut = true);

      Future.delayed(const Duration(milliseconds: 200), () {
        if (!mounted) return;
        setState(() => showLogo = true);

        Future.wait([
          Future.delayed(const Duration(seconds: 2)),
          MaintenanceCheckHelper.isClosedForMaintenance().then((v) => _isClosedForMaintenance = v),
        ]).then((_) {
          if (!mounted) return;
          navigateToCorrectRoute();
        });
      });
    });
  }

  void navigateToCorrectRoute() {
    if (_isClosedForMaintenance) {
      context.router.replace(const MaintenanceRoute());
      return;
    }
    final isLangSelected = CacheManager.instance.getLanguage() != null;
    if (isLangSelected) {
      handleAuthenticatedUser();
    } else {
      context.router.replace(const LanguageRoute());
    }
  }

  void handleAuthenticatedUser() {
    // Check if user is in guest mode
    if (CacheManager.instance.isGuestMode()) {
      context.router.replace(const LandingRoute());
      return;
    }
    
    final String authToken = CacheManager.instance.getAuthToken();
    if (authToken.isNotEmpty) {
      handleAuthenticatedAccount();
    } else {
      context.router.replace(const LoginRoute());
    }
  }

  Future<void> handleAuthenticatedAccount() async {
    locator<AuthenticationBloc>().add(GetProfileEvent());
    final state = await locator<AuthenticationBloc>().stream.firstWhere(
      (state) => state is GetProfileSuccess || state is AuthenticationError,
    );
    if (!mounted) return;
    if (state is GetProfileSuccess) {
      // Reset language from profile so app matches user preference
      final profileLanguage = state.user.language;
      if (profileLanguage != null &&
          (profileLanguage == 'ar' || profileLanguage == 'en')) {
        await CacheManager.instance.setLanguage(profileLanguage);
        if (mounted) {
          context.setLocale(
            profileLanguage == 'ar' ? L10n.langAr : L10n.langEn,
          );
        }
      }
      if (!mounted) return;
      context.router.replace(const HomeRoute());
    } else {
      context.router.replace(const LoginRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        image: DecorationImage(image: AssetImage(AppAssets.splash_background), fit: BoxFit.cover),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 800),
            opacity: showLogo ? 1.0 : 0.0,
            child: AnimatedScale(
              duration: const Duration(milliseconds: 800),
              scale: showLogo ? 1.0 : 0.5,
              curve: Curves.easeOutBack,
              child: Hero(tag: 'logo', child: SvgPicture.asset(AppAssets.logo, height: 150)),
            ),
          ),
        ),
      ),
    );
  }
}
