import 'package:flutter/cupertino.dart';

import '../../../application/core/di/app_component/app_component.dart';
import '../../../presentation/pages/auth/bloc/authentication_bloc.dart';
import '../response_model/notifications/remote_notification/remote_notification_model.dart';

enum NotificationType {
  readyToGo(5, 'ReadyToGo', ReadyToGoHandler()),
  blocked(6, 'Blocked', BlockedHandler());

  final int value;
  final String name;
  final NotificationHandler handler;

  const NotificationType(this.value, this.name, this.handler);

  static NotificationType getTypeFromInt(int? value) {
    for (var element in NotificationType.values) {
      if (element.value == value) {
        return element;
      }
    }
    return NotificationType.readyToGo;
  }

  void performAction(RemoteNotificationModel model) {
    handler.handle(model);
  }
}

abstract class NotificationHandler {
  void handle(RemoteNotificationModel model);
}

class ReadyToGoHandler implements NotificationHandler {
  const ReadyToGoHandler();
  @override
  void handle(RemoteNotificationModel model) {
    debugPrint('Handling ReadyToGo');
    // Add specific logic here
  }
}

class BlockedHandler implements NotificationHandler {
  const BlockedHandler();
  @override
  void handle(RemoteNotificationModel model) {
    locator<AuthenticationBloc>().add(const LogoutEvent(apiRequest: false));
  }
}
