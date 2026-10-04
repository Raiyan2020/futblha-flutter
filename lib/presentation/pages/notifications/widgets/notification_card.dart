import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter/material.dart';

import '../../../../application/config/app_assets.dart';
import '../../../../application/config/design_system/app_colors.dart';
import '../../../../data/models/response_model/notifications/notifications_response_model.dart';
import '../../../widgets/custom_text.dart';
import '../../../widgets/scaffold_pading.dart';

class NotificationCard extends StatelessWidget {
  const NotificationCard({super.key, required this.model});
  final NotificationModel model;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: symmetricPadding(15, 15),
      decoration: BoxDecoration(
        color: AppColors.textFieldColor,
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
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        subtitle: CustomText(
          model.createdAt ?? '',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
            color: const Color(0xFFB5B5B5),
          ),
        ),
        trailing: SvgPicture.asset(AppAssets.ic_notification),
      ),
    );
  }
}
