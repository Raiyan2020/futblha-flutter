import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import '../../../../application/config/app_assets.dart';
import '../../../../application/config/design_system/app_colors.dart';
import '../../../../application/core/utils/constants/app_constants.dart';
import '../../../../application/core/utils/fcm/notification_navigation.dart';
import '../../../../data/models/response_model/notifications/notifications_response_model.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/scaffold_pading.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.model});
  final NotificationModel model;

  @override
  Widget build(BuildContext context) {
    // Unread challenges are highlighted in red until tapped.
    final highlight = model.type == gameInvitationNotificationType && model.isUnread;
    return GestureDetector(
      onTap: () => NotificationNavigation.open(type: model.type, notificationId: model.id),
      child: Container(
        padding: symmetricPadding(15, 15),
        decoration: BoxDecoration(
          color: highlight ? AppColors.primaryRed.withValues(alpha: 0.08) : context.cardBackground,
          border: highlight ? Border.all(color: AppColors.primaryRed, width: 1.5) : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              spreadRadius: 3,
              blurRadius: 10,
              offset: const Offset(0, 10), // changes position of shadow
            ),
          ],
          borderRadius: BorderRadius.circular(15),
        ),
        child: ListTile(
          contentPadding: EdgeInsets.zero,
          title: CustomText(
            model.title ?? '',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: highlight ? AppColors.primaryRed : null,
            ),
          ),
          subtitle: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (model.body?.isNotEmpty ?? false)
                CustomText(
                  model.body!,
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w500,
                    color: highlight ? AppColors.primaryRed : null,
                  ),
                ),
              CustomText(
                model.createdAt ?? '',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: const Color(0xFFB5B5B5),
                ),
              ),
            ],
          ),
          trailing: highlight
              ? const Icon(Icons.sports_soccer, color: AppColors.primaryRed)
              : SvgPicture.asset(AppAssets.ic_notification),
        ),
      ),
    );
  }
}
