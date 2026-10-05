import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../application/config/design_system/app_colors.dart';
import '../../application/core/di/app_component/app_component.dart';
import '../../application/core/utils/auto_router_setup/app_router.dart';
import '../pages/notifications/bloc/notifications_bloc.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

/// App-bar bell with a red unread badge, driven by the singleton NotificationsBloc.
class NotificationBellButton extends StatelessWidget {
  const NotificationBellButton({super.key});

  @override
  Widget build(BuildContext context) {
    final bloc = locator<NotificationsBloc>();
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8),
      decoration: BoxDecoration(
        color: context.chipBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: BlocBuilder<NotificationsBloc, NotificationsState>(
        bloc: bloc,
        builder: (context, state) {
          return Stack(
            clipBehavior: Clip.none,
            children: [
              IconButton(
                onPressed: () async {
                  await context.router.push(NotificationsRoute());
                  bloc.add(GetUnreadCountEvent());
                },
                icon: Icon(Icons.notifications_none, color: context.brandOnSurface),
              ),
              if (bloc.unreadCount > 0)
                PositionedDirectional(
                  end: 4,
                  top: 4,
                  child: RedCountBadge(count: bloc.unreadCount),
                ),
            ],
          );
        },
      ),
    );
  }
}

class RedCountBadge extends StatelessWidget {
  const RedCountBadge({super.key, required this.count});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 18, minHeight: 18),
      padding: const EdgeInsets.symmetric(horizontal: 4),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: AppColors.primaryRed,
        borderRadius: BorderRadius.circular(9),
      ),
      child: Text(
        count > 99 ? '99+' : '$count',
        style: const TextStyle(color: AppColors.primaryWhite, fontSize: 10, fontWeight: FontWeight.bold),
      ),
    );
  }
}
