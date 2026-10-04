import 'package:flutter/foundation.dart';

import '../../../../presentation/pages/notifications/bloc/notifications_bloc.dart';
import '../../di/app_component/app_component.dart';
import '../auto_router_setup/app_router.dart';
import '../constants/app_constants.dart';
import '../helpers/cache/cache_manager.dart';

/// Single place that decides where a notification tap goes, whether it came
/// from a push (background, terminated, foreground) or from the in-app list.
class NotificationNavigation {
  NotificationNavigation._();

  static bool _landingReady = false;
  static Map<String, dynamic>? _pendingData;

  /// Called by LandingPage once the main tabs are mounted. Flushes a tap that
  /// arrived before the router could navigate (e.g. app launched from a push).
  static void markLandingReady() {
    _landingReady = true;
    final data = _pendingData;
    _pendingData = null;
    if (data != null) handleData(data);
  }

  static void markLandingDisposed() => _landingReady = false;

  /// Handles a push payload (`type`, `notification_id`, ...).
  static void handleData(Map<String, dynamic> data) {
    if (!_landingReady) {
      _pendingData = data;
      return;
    }
    open(type: data['type']?.toString(), notificationId: data['notification_id']?.toString());
  }

  static void open({String? type, String? notificationId}) {
    if (CacheManager.instance.isGuestMode() || CacheManager.instance.getAuthToken().isEmpty) return;

    final notificationsBloc = locator<NotificationsBloc>();
    if (notificationId != null && notificationId.isNotEmpty) {
      notificationsBloc.add(MarkNotificationReadEvent(notificationId));
    } else {
      notificationsBloc.add(GetUnreadCountEvent());
    }

    if (type == gameInvitationNotificationType) {
      try {
        locator<AppRouter>().push(const GamesInvitationsRoute());
      } catch (e) {
        debugPrint('Error navigating to games invitations: $e');
      }
    }
  }
}
