import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart' as el;
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';
import 'package:futblha/presentation/widgets/custom_loading_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../../application/config/app_assets.dart';
import '../../../application/config/design_system/app_colors.dart';
import '../../../application/core/basecomponents/base_view_model_view.dart';
import '../../../application/core/di/app_component/app_component.dart';
import '../../../application/core/utils/auto_router_setup/app_router.dart';
import '../../../application/core/utils/helpers/cache/cache_manager.dart';
import '../../../data/models/enums/position_enum.dart';
import '../../../generated/locale_keys.g.dart';
import '../../widgets/scaffold_pading.dart';
import '../../widgets/custom_elevated_button.dart';
import '../auth/bloc/authentication_bloc.dart';
import '../../widgets/notification_bell_button.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../notifications/bloc/notifications_bloc.dart';

@RoutePage()
class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final authBloc = locator<AuthenticationBloc>();

  String _formatPositions(List<String>? positionKeys) {
    if (positionKeys == null || positionKeys.isEmpty) {
      return LocaleKeys.no_positions_selected.tr();
    }

    // Check if jocker is in the list
    if (positionKeys.contains(Position.jocker.key)) {
      return Position.jocker.displayName;
    }

    // Map position keys to display names using enum
    final positionNames = positionKeys
        .map((key) => Position.fromKey(key)?.displayName ?? key)
        .toList();

    return positionNames.join(' , ');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: SvgPicture.asset(
          Theme.of(context).brightness == Brightness.dark
              ? AppAssets.white_logo
              : AppAssets.home_logo,
        ),
        automaticallyImplyLeading: false,
        elevation: 0,
        actions: [
          // Only show notifications for authenticated users
          if (!CacheManager.instance.isGuestMode()) const NotificationBellButton(),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) => SingleChildScrollView(
          padding: symmetricPadding(0, 15),
          child: ConstrainedBox(
            // Lets the guest content be centered vertically when it is shorter than the screen
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: CustomBlocConsumer<AuthenticationBloc, AuthenticationState>(
          bloc: authBloc,
          listener: (context, state) {},
          builder: (context, state) {
            final isGuestMode = CacheManager.instance.isGuestMode();

            return Column(
              mainAxisAlignment: isGuestMode ? MainAxisAlignment.center : MainAxisAlignment.start,
              children: [
                if (isGuestMode) ...[
                  // Guest User Card
                  Container(
                    width: double.infinity,
                    padding: symmetricPadding(20, 20),
                    margin: EdgeInsets.only(top: 20.h),
                    decoration: BoxDecoration(
                      color: AppColors.secondaryColor,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          spreadRadius: 1,
                          blurRadius: 5,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      children: [
                        Text(
                          LocaleKeys.you_are_a_guest_user.tr(),
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        20.heightBox(),
                        CustomElevatedButton(
                          title: LocaleKeys.sign_in.tr(),
                          onPressed: () {
                            context.router.pushAndPopUntil(
                              const LoginRoute(),
                              predicate: (_) => false,
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                  15.heightBox(),
                  // Guest Menu Items Section (only public items)
                  Column(
                    children: [
                      MenuItem(
                        icon: Icons.settings,
                        text: LocaleKeys.settings,
                        onTap: () {
                          context.router.push(const SettingsRoute());
                        },
                      ),
                      MenuItem(
                        icon: Icons.description,
                        text: LocaleKeys.terms_and_conditions,
                        onTap: () {
                          context.router.push(
                            AboutRoute(title: LocaleKeys.terms_of_services, content: 'terms'),
                          );
                        },
                      ),
                      MenuItem(
                        icon: Icons.security,
                        text: LocaleKeys.privacy_policy,
                        onTap: () {
                          context.router.push(
                            AboutRoute(title: LocaleKeys.privacy_policy, content: 'privacy'),
                          );
                        },
                      ),
                      MenuItem(
                        icon: Icons.help_outline,
                        text: LocaleKeys.contact_us,
                        onTap: () {
                          context.router.push(const SupportRoute());
                        },
                      ),
                      MenuItem(
                        icon: Icons.info_outline,
                        text: LocaleKeys.about_fatbelha,
                        onTap: () {
                          context.router.push(
                            AboutRoute(title: LocaleKeys.about_us, content: 'about'),
                          );
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                ] else ...[
                  // Authenticated User Profile Card
                  Stack(
                    alignment: Alignment.topCenter,
                    children: [
                      Container(
                        width: double.infinity,
                        padding: symmetricPadding(10, 20),
                        margin: EdgeInsets.only(top: 50.h),
                        decoration: BoxDecoration(
                          color: AppColors.secondaryColor,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                // Edit Icon on the left
                                IconButton(
                                  onPressed: () {
                                    context.router.push(const EditProfileRoute());
                                  },
                                  icon: SvgPicture.asset(AppAssets.person_edit),
                                ),
                                // Logout Button
                                TextButton.icon(
                                  onPressed: () {
                                    authBloc.add(const LogoutEvent(apiRequest: true));
                                  },
                                  style: TextButton.styleFrom(
                                    padding: EdgeInsets.zero,
                                    minimumSize: Size.zero,
                                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                  ),
                                  icon: const Icon(Icons.logout, color: AppColors.primaryRed),
                                  label: Text(
                                    LocaleKeys.logout.tr(),
                                    style: const TextStyle(color: AppColors.primaryRed),
                                  ),
                                ),
                              ],
                            ),
                            // User Name
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  authBloc.user?.name ?? '',
                                  style: const TextStyle(
                                    color: AppColors.primaryColor,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  '${authBloc.user?.country_code ?? ''} ${authBloc.user?.phone_not_code ?? authBloc.user?.phone ?? ''}',
                                  style: TextStyle(
                                    color: AppColors.primaryColor.withValues(alpha: 0.7),
                                    fontSize: 14,
                                    fontWeight: FontWeight.w400,
                                  ),
                                  textAlign: TextAlign.center,
                                  textDirection: TextDirection.ltr,
                                ),
                              ],
                            ),
                            10.heightBox(),
                            // Player Attributes Section
                            Container(
                              width: double.infinity,
                              padding: EdgeInsets.all(12.w),
                              decoration: BoxDecoration(
                                color: Color(0xFFA6EFD3),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (authBloc.user?.age != null) ...[
                                    Row(
                                      children: [
                                        Text(
                                          '${LocaleKeys.age_label.tr()} ',
                                          style: const TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          '${authBloc.user!.age}',
                                          style: const TextStyle(
                                            color: AppColors.primaryColor,
                                            fontSize: 14,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                  Row(
                                    children: [
                                      Text(
                                        '${LocaleKeys.positions_label.tr()} ',
                                        style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        _formatPositions(authBloc.user?.positions),
                                        style: const TextStyle(
                                          color: AppColors.primaryColor,
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            5.heightBox(),
                          ],
                        ),
                      ),
                      // Profile Picture
                      Container(
                        width: 90.w,
                        height: 90.h,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(color: AppColors.primaryWhite, width: 4),
                        ),
                        child: ClipOval(
                          child: authBloc.user?.image != null
                              ? Image.network(
                                  authBloc.user!.image!,
                                  fit: BoxFit.cover,
                                  errorBuilder: (context, error, stackTrace) {
                                    return Image.asset(AppAssets.ic_profile, fit: BoxFit.cover);
                                  },
                                )
                              : Image.asset(AppAssets.ic_profile, fit: BoxFit.cover),
                        ),
                      ),
                    ],
                  ),
                  15.heightBox(),
                  // Authenticated User Menu Items Section
                  Column(
                    children: [
                      MenuItem(
                        icon: Icons.account_balance_wallet,
                        text: LocaleKeys.wallet_balance,
                        onTap: () {
                          context.router.push(const WalletRoute());
                        },
                        trailing: authBloc.user?.balance != null
                            ? '${authBloc.user?.balance} ${LocaleKeys.kwd.tr()}'
                            : '0.000 ${LocaleKeys.kwd.tr()}',
                      ),
                      BlocBuilder<NotificationsBloc, NotificationsState>(
                        bloc: locator<NotificationsBloc>(),
                        builder: (context, _) => MenuItem(
                          icon: Icons.link,
                          text: LocaleKeys.games_invitations,
                          badgeCount: locator<NotificationsBloc>().pendingInvitationsCount,
                          onTap: () {
                            context.router.push(const GamesInvitationsRoute());
                          },
                        ),
                      ),
                      MenuItem(
                        icon: Icons.access_time,
                        text: LocaleKeys.my_games_history,
                        onTap: () {
                          context.router.push(const MyGamesHistoryRoute());
                        },
                      ),
                      MenuItem(
                        icon: Icons.calendar_today,
                        text: LocaleKeys.my_bookings,
                        onTap: () {
                          context.router.push(const MyBookingsRoute());
                        },
                      ),
                      MenuItem(
                        icon: Icons.settings,
                        text: LocaleKeys.settings,
                        onTap: () {
                          context.router.push(const SettingsRoute());
                        },
                      ),
                      MenuItem(
                        icon: Icons.description,
                        text: LocaleKeys.terms_and_conditions,
                        onTap: () {
                          context.router.push(
                            AboutRoute(title: LocaleKeys.terms_and_conditions, content: 'terms'),
                          );
                        },
                      ),
                      MenuItem(
                        icon: Icons.security,
                        text: LocaleKeys.privacy_policy,
                        onTap: () {
                          context.router.push(
                            AboutRoute(title: LocaleKeys.privacy_policy, content: 'privacy'),
                          );
                        },
                      ),
                      MenuItem(
                        icon: Icons.help_outline,
                        text: LocaleKeys.contact_us,
                        onTap: () {
                          context.router.push(const SupportRoute());
                        },
                      ),
                      MenuItem(
                        icon: Icons.info_outline,
                        text: LocaleKeys.about_fatbelha,
                        onTap: () {
                          context.router.push(
                            AboutRoute(title: LocaleKeys.about_us, content: 'about'),
                          );
                        },
                        isLast: true,
                      ),
                    ],
                  ),
                ],
                20.heightBox(),
                if (state is AuthLoading)
                  const Padding(padding: EdgeInsets.all(8.0), child: LoadingWidget()),
              ],
            );
          },
        ),
          ),
        ),
      ),
    );
  }
}

class MenuItem extends StatelessWidget {
  const MenuItem({
    super.key,
    required this.icon,
    required this.text,
    required this.onTap,
    this.trailing,
    this.isLast = false,
    this.badgeCount = 0,
  });
  final IconData icon;
  final String text;
  final VoidCallback onTap;
  final String? trailing;
  final bool isLast;
  final int badgeCount;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: isLast ? 0 : 12.h),
      child: InkWell(
        onTap: onTap,
        child: Container(
          padding: EdgeInsets.all(16.w),
          decoration: BoxDecoration(
            color: AppColors.secondaryColor,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                spreadRadius: 1,
                blurRadius: 5,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(icon, color: AppColors.primaryColor, size: 24),
              16.widthBox(),
              Expanded(
                child: Text(
                  text.tr(),
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (badgeCount > 0) ...[
                RedCountBadge(count: badgeCount),
                8.widthBox(),
              ],
              if (trailing != null) ...[
                Text(
                  trailing!,
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                8.widthBox(),
              ],
              const Icon(Icons.chevron_right, color: AppColors.primaryColor, size: 24),
            ],
          ),
        ),
      ),
    );
  }
}
