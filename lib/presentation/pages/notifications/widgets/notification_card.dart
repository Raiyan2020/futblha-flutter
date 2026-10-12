import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import '../../../../application/config/app_assets.dart';
import '../../../../application/config/design_system/app_colors.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../application/core/utils/fcm/notification_navigation.dart';
import '../../../../data/models/response_model/notifications/notifications_response_model.dart';
import '../../../widgets/custom_text.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.model});
  final NotificationModel model;

  @override
  Widget build(BuildContext context) {
    // Unread challenges are highlighted in red until tapped.
    final highlight = model.type == gameInvitationNotificationType && model.isUnread;
    final accent = highlight ? AppColors.primaryRed : context.brandOnSurface;
    // Tint is blended into an opaque color so the shadow can't show through it.
    final background = highlight
        ? Color.alphaBlend(AppColors.primaryRed.withValues(alpha: 0.06), context.cardBackground)
        : context.cardBackground;

    return Material(
      color: background,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => NotificationNavigation.open(type: model.type, notificationId: model.id),
        child: Ink(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: highlight ? AppColors.primaryRed.withValues(alpha: 0.6) : context.borderColor,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.06),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: accent.withValues(alpha: 0.12),
                  shape: BoxShape.circle,
                ),
                child: highlight
                    ? Icon(Icons.sports_soccer, color: accent, size: 24)
                    : SvgPicture.asset(
                        AppAssets.ic_notification,
                        width: 22,
                        height: 22,
                        colorFilter: ColorFilter.mode(accent, BlendMode.srcIn),
                      ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: CustomText(
                            model.title ?? '',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: highlight ? AppColors.primaryRed : context.textPrimary,
                            ),
                          ),
                        ),
                        if (model.isUnread) ...[
                          const SizedBox(width: 8),
                          Container(
                            width: 8,
                            height: 8,
                            decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
                          ),
                        ],
                      ],
                    ),
                    if (model.body?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 4),
                      CustomText(
                        model.body!,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                          color: context.textPrimary.withValues(alpha: 0.85),
                        ),
                      ),
                    ],
                    if (model.createdAt?.isNotEmpty ?? false) ...[
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Icon(Icons.access_time, size: 14, color: context.textSecondary),
                          const SizedBox(width: 4),
                          CustomText(
                            model.createdAt!,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: context.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
