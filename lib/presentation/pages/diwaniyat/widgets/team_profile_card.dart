import 'package:auto_route/auto_route.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/app_assets.dart';
import 'package:futblha/application/config/design_system/app_colors.dart';
import 'package:futblha/application/core/utils/auto_router_setup/app_router.dart';
import 'package:futblha/application/core/utils/helpers/extension_functions/size_extension.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/diwaniyat/bloc/diwaniya_bloc.dart';
import 'package:futblha/presentation/widgets/app_size_boxes.dart';

class TeamProfileCard extends StatelessWidget {
  final DiwaniyaBloc bloc;
  final VoidCallback? onShare;

  const TeamProfileCard({super.key, required this.bloc, this.onShare});

  Widget _buildActionIcon(
    IconData icon, {
    bool hasBadge = false,
    int badgeCount = 0,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          Container(
            padding: EdgeInsets.all(8),
            decoration: const BoxDecoration(shape: BoxShape.circle),
            child: Icon(icon, color: AppColors.primaryWhite, size: 24),
          ),
          if (hasBadge && badgeCount > 0)
            Positioned(
              right: 0,
              top: 0,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.primaryRed,
                  shape: BoxShape.circle,
                ),
                child: Text(
                  '$badgeCount',
                  style: const TextStyle(
                    color: AppColors.primaryWhite,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String value, String label) {
    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 18.w, vertical: 14.h),
          constraints: BoxConstraints(minWidth: 50.w),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            image: DecorationImage(
              image: AssetImage(AppAssets.score_background),
              fit: BoxFit.fill,
            ),
          ),
          child: Text(
            value,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppColors.primaryColor,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        4.heightBox(),
        Text(
          label,
          style: TextStyle(
            color: AppColors.primaryWhite,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  void _showLeaveDiwaniyaDialog(BuildContext context) {
    final diwaniyaId = bloc.myDiwaniya?.id;
    if (diwaniyaId == null) return;
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text(LocaleKeys.leave.tr()),
        content: Text(LocaleKeys.leave_diwaniya_confirmation.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: Text(LocaleKeys.dismiss.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(dialogContext).pop();
              bloc.add(LeaveDiwaniyaEvent(diwaniyaId: diwaniyaId));
            },
            child: Text(LocaleKeys.leave.tr()),
          ),
        ],
      ),
    );
  }

  Widget _buildNavButton(String text, {required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.symmetric(vertical: 8.h),
        decoration: BoxDecoration(
          color: AppColors.primaryWhite.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.primaryWhite.withValues(alpha: 0.3),
          ),
        ),
        child: Center(
          child: Text(
            text,
            style: TextStyle(
              color: AppColors.primaryWhite,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (bloc.myDiwaniya == null) return const SizedBox.shrink();
    return Stack(
      children: [
        // Main card with wavy top
        Container(
          margin: EdgeInsets.only(top: 28.h),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(AppAssets.my_diwanya_background),
              fit: BoxFit.fill,
            ),
          ),
          child: Padding(
            padding: EdgeInsets.fromLTRB(25.w, 20.h, 25.w, 25.h),
            child: Column(
              children: [
                // Action icons row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Column(
                      children: [
                        _buildActionIcon(Icons.share, onTap: onShare),
                        if (bloc.myDiwaniya?.userPermission?.isAdmin == true)
                          _buildActionIcon(
                            Icons.person_add,
                            hasBadge: true,
                            badgeCount: bloc.myDiwaniya?.joinRequests ?? 0,
                            onTap: () => context.router.push(
                              JoinRequestsRoute(diwaniyaBloc: bloc),
                            ),
                          )
                        else
                          SizedBox(width: 40),
                        40.heightBox(),
                      ],
                    ),

                    // Team name and rank
                    Column(
                      children: [
                        45.heightBox(),
                        Text(
                          bloc.myDiwaniya?.name ?? '',
                          style: TextStyle(
                            color: AppColors.primaryWhite,
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        8.heightBox(),
                        Text(
                          bloc.myDiwaniya?.rank != null
                              ? '#${bloc.myDiwaniya!.rank}'
                              : '',
                          style: TextStyle(
                            color: AppColors.primaryWhite,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),

                    Column(
                      children: [
                        if (bloc.myDiwaniya?.userPermission?.isAdmin == true)
                          _buildActionIcon(
                            Icons.settings,
                            onTap: () => context.router
                                .push(DiwaniyaSettingsRoute(bloc: bloc))
                                .then((value) {
                                  bloc.add(GetDiwaniyasOverviewEvent());
                                }),
                          )
                        else
                          SizedBox(width: 40),
                        if (bloc.myDiwaniya?.userPermission?.canLeave == true)
                          _buildActionIcon(
                            Icons.exit_to_app,
                            onTap: () => _showLeaveDiwaniyaDialog(context),
                          ),
                        if (bloc.myDiwaniya?.memberStatus != 'pending')
                          _buildActionIcon(
                            Icons.chat_outlined,
                            hasBadge: true,
                            badgeCount:
                                bloc.myDiwaniya?.unreadMessagesCount ?? 0,
                            onTap: () => context.router.push(
                              ChatRoute(diwaniyaBloc: bloc),
                            ),
                          )
                        else
                          SizedBox(width: 40),
                        40.heightBox(),
                      ],
                    ),
                  ],
                ),
                10.heightBox(),

                // Description
                if (bloc.myDiwaniya?.description != null)
                  Container(
                    padding: EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: AppColors.primaryWhite.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      bloc.myDiwaniya?.description ?? '',
                      style: TextStyle(
                        color: AppColors.primaryWhite.withValues(alpha: 0.8),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                      textAlign: TextAlign.center,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),

                15.heightBox(),
                // Statistics
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildStatCard(
                        bloc.myDiwaniya?.wins ?? '0',
                        LocaleKeys.win.tr(),
                      ),
                      _buildStatCard(
                        bloc.myDiwaniya?.draws ?? '0',
                        LocaleKeys.draw.tr(),
                      ),
                      _buildStatCard(
                        bloc.myDiwaniya?.losses ?? '0',
                        LocaleKeys.lose.tr(),
                      ),
                    ],
                  ),
                ),
                15.heightBox(),
                // Navigation buttons
                Row(
                  children: [
                    if (bloc.myDiwaniya?.memberStatus != 'pending') ...[
                      Expanded(
                        child: _buildNavButton(
                          LocaleKeys.games_history.tr(),
                          onTap: () {
                            if (bloc.myDiwaniya?.id != null) {
                              context.router.push(
                                GamesHistoryRoute(
                                  diwaniyaId: bloc.myDiwaniya!.id!,
                                ),
                              );
                            }
                          },
                        ),
                      ),
                      12.widthBox(),
                    ],
                    Expanded(
                      child: _buildNavButton(
                        LocaleKeys.view_members.tr(),
                        onTap: () {
                          context.router.push(MembersRoute(bloc: bloc));
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        // Profile picture overlapping
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Center(
            child: Container(
              width: 78.w,
              height: 78.w,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.primaryLiteGrey,
                boxShadow: [
                  BoxShadow(
                    color: AppColors.primaryWhite.withValues(alpha: 0.2),
                    blurRadius: 10,
                    offset: Offset(0, 5),
                    spreadRadius: 2,
                  ),
                ],
              ),
              child: ClipOval(
                child: Image.network(
                  bloc.myDiwaniya?.image ?? '',
                  width: 78.w,
                  height: 78.w,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) {
                    return Image.asset(
                      AppAssets.ic_profile,
                      width: 78.w,
                      height: 78.w,
                    );
                  },
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
