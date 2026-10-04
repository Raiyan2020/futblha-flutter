import 'dart:async';

import 'package:easy_localization/easy_localization.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'application/config/design_system/app_theme.dart';
import 'application/config/l10n.dart';
import 'application/core/di/app_component/app_component.dart';
import 'application/core/utils/auto_router_setup/app_router.dart';
import 'package:auto_route/auto_route.dart';

// import 'application/core/utils/fcm/fcm_handler.dart';
// import 'application/core/utils/fcm/notification_handler.dart';
import 'application/core/utils/helpers/app_flavor_helper/app_flavors_helper.dart';
import 'application/core/utils/helpers/app_flavor_helper/environment_config.dart';
import 'application/core/utils/helpers/cache/cache_manager.dart';
import 'application/core/utils/helpers/connectivity_helper/connectivity_service.dart';
import 'application/core/utils/helpers/responsive_ui_helper/responsive_config.dart';
import 'application/core/utils/helpers/theme_helper/theme_notifier.dart';
import 'package:intl/date_symbol_data_local.dart';
FutureOr<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initAppComponentLocator();

  await EasyLocalization.ensureInitialized();

  await CacheManager.instance.init();

  // Initialize theme notifier after cache is ready
  ThemeNotifier.instance.initialize();

  // await Firebase.initializeApp();
  // await LocalNotificationHandler.initializeNotifications();
  // await FCMHandler().initializeFCM();

  final configService = locator<AppFlavorsHelper>();
  final productFlavor = EnvironmentConfig.DEV_VARIANT.toProductFlavor();
  configService.configure(productFlavor: productFlavor);

  EasyLocalization.logger.enableLevels = [];

  // Initialize ALL locales you support (or just 'ar' and 'en')
  await initializeDateFormatting();

  runApp(
    EasyLocalization(
      supportedLocales: L10n.all,
      path: 'assets/l10n',
      fallbackLocale: L10n.langEn,
      startLocale: CacheManager.instance.getSavedLocale(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final AppRouter _appRouter = locator<AppRouter>();
  final _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();
  ConnectivityService? _connectivityService;
  final ThemeNotifier _themeNotifier = ThemeNotifier.instance;

  @override
  void initState() {
    super.initState();
    _connectivityService = ConnectivityService(_scaffoldMessengerKey);
    _themeNotifier.initialize();
    _themeNotifier.addListener(_onThemeChanged);
  }

  @override
  void dispose() {
    _themeNotifier.removeListener(_onThemeChanged);
    _connectivityService?.dispose();
    super.dispose();
  }

  void _onThemeChanged() {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    locator<ResponsiveUiConfig>().initialize(context);
    return ListenableBuilder(
      listenable: _themeNotifier,
      builder: (context, _) {
        return MaterialApp.router(
          title: 'Futblha',
          scaffoldMessengerKey: _scaffoldMessengerKey,
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: _themeNotifier.isDarkMode ? ThemeMode.dark : ThemeMode.light,
          routerConfig: _appRouter.config(
            deepLinkBuilder: (deepLink) async {
              // Always return default path - let AppLinksService handle deep link navigation
              // after app is fully initialized to avoid "Can not resolve initial route" error
              return const DeepLink.path('/');
            },
          ),
          debugShowCheckedModeBanner: false,
        );
      },
    );
  }
}