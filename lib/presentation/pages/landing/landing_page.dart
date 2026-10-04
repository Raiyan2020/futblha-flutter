import 'dart:io';

import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../application/config/app_assets.dart';
import '../../../application/config/design_system/app_colors.dart';
import '../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/auto_router_setup/app_router.dart';
import '../../../application/core/utils/constants/app_constants.dart';
import '../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../application/core/utils/helpers/maintenance_check/maintenance_check_helper.dart';
import '../../../application/core/utils/helpers/launch_url.dart';
import '../../../application/core/utils/app_links_service.dart';
import '../../../generated/locale_keys.g.dart';
import '../auth/bloc/authentication_bloc.dart';
import '../diwaniyat/bloc/diwaniya_bloc.dart';
import '../settings/bloc/settings_bloc.dart';

@RoutePage()
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final settingsBloc = locator<SettingsBloc>();
  final AppLinksService _appLinksService = AppLinksService();

  @override
  void initState() {
    super.initState();
    _checkMaintenanceAndRedirect();
    settingsBloc.add(GetSettingsEvent());

    // Fetch diwaniyas-overview once so auth bloc has "my diwaniya" for join-game team restriction
    if (CacheManager.instance.getUserId().isNotEmpty &&
        !CacheManager.instance.isGuestMode()) {
      locator<DiwaniyaBloc>().add(GetDiwaniyasOverviewEvent());
    }

    // Initialize deep linking
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _appLinksService.init(context);
      }
    });
  }

  Future<void> _checkMaintenanceAndRedirect() async {
    final isClosed = await MaintenanceCheckHelper.isClosedForMaintenance();
    if (isClosed && mounted) {
      context.router.replace(const MaintenanceRoute());
    }
  }

  @override
  Widget build(BuildContext context) {
    return CustomBlocConsumer<SettingsBloc, SettingsState>(
      bloc: settingsBloc,
      listener: _handleSettingsState,
      builder: (context, state) {
        return AutoTabsScaffold(
          routes: const [HomeRoute(), DiwaniyatRoute(), ProfileRoute()],
          // extendBody: true,
          bottomNavigationBuilder: (_, tabsRouter) =>
              _buildBottomNavigationBar(context, tabsRouter),
        );
      },
    );
  }

  Future<void> _handleSettingsState(
    BuildContext context,
    SettingsState state,
  ) async {
    if (state is! SettingsLoaded) return;

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;
    final isIos = Platform.isIOS;
    final storeVersion = isIos
        ? state.settings.iosVersion
        : state.settings.androidVersion;
    final forceUpdate = isIos
        ? state.settings.forcedUpdateIos
        : state.settings.forcedUpdateAndroid;

    debugPrint('My Version: $currentVersion');

    if (storeVersion != null && storeVersion != currentVersion) {
      if (!mounted) return;
      await _showUpdateDialog(context, forceUpdate);
    }
  }

  Future<void> _showUpdateDialog(
    BuildContext context,
    String? forceUpdate,
  ) async {
    final isForceUpdate = forceUpdate == '1';
    final canDismiss = !isForceUpdate;

    await showDialog(
      context: context,
      barrierDismissible: canDismiss,
      builder: (context) =>
          _UpdateDialog(isForceUpdate: isForceUpdate, canDismiss: canDismiss),
    );

    if (!mounted) return;

    if (isForceUpdate && !kDebugMode) {
      locator<AuthenticationBloc>().add(const LogoutEvent(apiRequest: false));
      if (mounted) {
        context.router.pushAndPopUntil(
          const LoginRoute(),
          predicate: (_) => false,
        );
      }
    }
  }

  Widget _buildBottomNavigationBar(
    BuildContext context,
    TabsRouter tabsRouter,
  ) {
    return Container(
      height: 60,
      margin: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.primaryWhite,
        borderRadius: BorderRadius.circular(30),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          // Home Tab (Active)
          _buildTabItem(
            context: context,
            isActive: tabsRouter.activeIndex == 0,
            icon: AppAssets.home_icon,
            activeIcon: AppAssets.home_icon,
            label: LocaleKeys.home.tr(),
            onTap: () => tabsRouter.setActiveIndex(0),
          ),
          // Middle Tab (Groups/Diwaniya - Placeholder)
          _buildTabItem(
            context: context,
            isActive: tabsRouter.activeIndex == 1,
            icon: AppAssets.diwaniyat_icon,
            activeIcon: AppAssets.diwaniyat_icon,
            label: LocaleKeys.diwaniyat.tr(),
            onTap: () => tabsRouter.setActiveIndex(1),
          ),
          // Profile Tab
          _buildTabItem(
            context: context,
            isActive: tabsRouter.activeIndex == 2,
            icon: AppAssets.account_icon,
            activeIcon: AppAssets.account_icon,
            label: LocaleKeys.account.tr(),
            onTap: () => tabsRouter.setActiveIndex(2),
          ),
        ],
      ),
    );
  }

  Widget _buildTabItem({
    required BuildContext context,
    required bool isActive,
    String? icon,
    String? activeIcon,
    required String label,
    required VoidCallback onTap,
    IconData? materialIcon,
  }) {
    final iconWidget = materialIcon != null
        ? Icon(
            materialIcon,
            size: isActive ? 20 : 24,
            color: isActive ? AppColors.primaryColor : AppColors.primaryDark,
          )
        : icon != null && icon.isNotEmpty
        ? SizedBox(
            width: 20,
            child: SvgPicture.asset(
              isActive && activeIcon != null ? activeIcon : icon,
              width: isActive ? 20 : 24,
              height: isActive ? 20 : 24,
              colorFilter: ColorFilter.mode(
                isActive ? AppColors.primaryColor : AppColors.primaryDark,
                BlendMode.srcIn,
              ),
            ),
          )
        : const SizedBox.shrink();

    if (isActive && label.isNotEmpty) {
      // Active tab with mint green background, icon and text (only for tabs with labels)
      return Expanded(
        flex: isActive ? 3 : 2,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.secondaryColor,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                iconWidget,
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    } else {
      // Inactive tab - just icon
      return Expanded(
        flex: isActive ? 3 : 2,
        child: InkWell(
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(8),
            child: Center(child: iconWidget),
          ),
        ),
      );
    }
  }
}

class _UpdateDialog extends StatelessWidget {
  final bool isForceUpdate;
  final bool canDismiss;

  const _UpdateDialog({required this.isForceUpdate, required this.canDismiss});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(LocaleKeys.update.tr()),
      content: Text(LocaleKeys.new_update_available.tr()),
      actions: [
        TextButton(
          onPressed: () {
            LaunchUrl.openUrl(Platform.isIOS ? appStoreLink : playStoreLink);
          },
          child: Text(LocaleKeys.update.tr()),
        ),
        if (canDismiss || kDebugMode)
          TextButton(
            onPressed: () {
              context.router.maybePop();
            },
            child: Text(LocaleKeys.cancel.tr()),
          ),
      ],
    );
  }
}
