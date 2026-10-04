import 'package:auto_route/annotations.dart';
import 'package:flutter/material.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/auth/bloc/authentication_bloc.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/language_button.dart';

import '../../../application/config/design_system/app_colors.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../application/core/utils/helpers/theme_helper/theme_notifier.dart';
import '../../../data/models/request_model/auth/update_user_settings_request_model.dart';
import '../../../data/models/response_model/login_remote_response_model/login_response_model.dart';
import '../../widgets/custom_scaffold.dart';
import '../../widgets/custom_text.dart';
import '../../widgets/custom_toolbar.dart';
import '../../widgets/scaffold_pading.dart';

@RoutePage()
class SettingsPage extends StatefulWidget {
  const SettingsPage({super.key});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  final UserModel? user = locator<AuthenticationBloc>().user;
  final ThemeNotifier _themeNotifier = ThemeNotifier.instance;
  bool isNotification = true;
  bool isDarkMode = false;

  @override
  void initState() {
    super.initState();

    setState(() {
      isNotification =
          CacheManager.instance.getNotification() ?? user?.notification_enabled ?? true;
      isDarkMode = CacheManager.instance.getDarkMode() ?? false;
      user?.language;
      //   isVoice = CacheManager.instance.getVoice() ?? true;
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return CustomScaffold(
      hasPadding: true,
      appBar: const CustomAppBar(title: LocaleKeys.settings),
      body: Container(
        padding: symmetricPadding(8, 0),
        decoration: BoxDecoration(color: theme.cardColor, borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            DrawerListItem(
              text: LocaleKeys.language_language,
              isArrow: true,
              trailing: LanguageButton(
                parentContext: context,
                onChange: () {
                  locator<AuthenticationBloc>().add(
                    UpdateUserSettingsEvent(
                      requestModel: UpdateUserSettingsRequestModel(
                        language: CacheManager.instance.getLanguage() ?? 'en',
                        notificationEnabled: CacheManager.instance.getNotification() == true
                            ? '1'
                            : '0',
                      ),
                    ),
                  );
                },
              ),
              onTap: () {},
            ),
            DrawerListItem(
              text: LocaleKeys.notifications,
              trailing: Switch.adaptive(
                value: isNotification,
                activeTrackColor: AppColors.primaryColor,
                onChanged: (value) async {
                  setState(() {
                    isNotification = value;
                  });
                  try {
                    // if (value) {
                    //   await FirebaseMessaging.instance.subscribeToTopic('general');
                    // } else {
                    //   await FirebaseMessaging.instance.unsubscribeFromTopic('general');
                    // }
                    CacheManager.instance.setNotification(value);
                  } catch (e) {
                    debugPrint(e.toString());
                  }
                  locator<AuthenticationBloc>().add(
                    UpdateUserSettingsEvent(
                      requestModel: UpdateUserSettingsRequestModel(
                        notificationEnabled: value == true ? '1' : '0',
                        language: CacheManager.instance.getLanguage() ?? 'en',
                      ),
                    ),
                  );
                },
              ),
              onTap: () {},
            ),
            DrawerListItem(
              text: LocaleKeys.dark_mode,
              isDivider: false,
              trailing: Switch.adaptive(
                value: isDarkMode,
                activeTrackColor: AppColors.primaryColor,
                onChanged: (value) async {
                  setState(() {
                    isDarkMode = value;
                  });
                  await _themeNotifier.setDarkMode(value);
                },
              ),
              onTap: () {},
            ),
          ],
        ),
      ),
    );
  }
}

class DrawerListItem extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Widget? trailing;
  final bool isDivider;
  final bool isArrow;

  const DrawerListItem({
    super.key,
    required this.text,
    required this.onTap,
    this.trailing,
    this.isDivider = true,
    this.isArrow = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ListTile(
          contentPadding: const EdgeInsetsDirectional.only(start: 20),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (trailing != null) ...[trailing!, 10.widthBox()],
              if (isArrow) Icon(Icons.chevron_right, color: theme.iconTheme.color, size: 30),
            ],
          ),
          title: CustomText(text, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          onTap: onTap,
        ),
        if (isDivider) const Divider(indent: 20, endIndent: 20, height: 2),
      ],
    );
  }
}
