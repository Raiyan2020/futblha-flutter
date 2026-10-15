import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../../data/models/response_model/games/game_model.dart';
import '../../../../presentation/pages/games/bloc/games_bloc.dart';
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
    open(
      type: data['type']?.toString(),
      notificationId: data['notification_id']?.toString(),
      gameId: gameIdFrom(data),
      fromPush: true,
    );
  }

  /// Reads `game_id` from a push payload or from an in-app notification's
  /// `data` (a JSON string), at the top level or inside `extra`.
  static int? gameIdFrom(Object? data) => intFrom(data, 'game_id');

  /// Reads the int [key] the same way as [gameIdFrom] (e.g. `friend_request_id`).
  static int? intFrom(Object? data, String key) {
    Object? source = data;
    if (source is String) {
      if (source.isEmpty) return null;
      try {
        source = jsonDecode(source);
      } catch (_) {
        return null;
      }
    }
    if (source is! Map) return null;
    final direct = source[key];
    final extra = source['extra'];
    final value = direct ?? (extra is Map ? extra[key] : null);
    return value is int ? value : int.tryParse(value?.toString() ?? '');
  }

  /// [fromPush] is true for taps on a push; false when tapped in the list.
  static void open({String? type, String? notificationId, int? gameId, bool fromPush = false}) {
    if (CacheManager.instance.isGuestMode() || CacheManager.instance.getAuthToken().isEmpty) return;

    final notificationsBloc = locator<NotificationsBloc>();
    if (notificationId != null && notificationId.isNotEmpty) {
      notificationsBloc.add(MarkNotificationReadEvent(notificationId));
    } else {
      notificationsBloc.add(GetUnreadCountEvent());
    }

    if (gameNotificationTypes.contains(type) && gameId != null) {
      try {
        // The game page loads the latest game (and pay button) from this id.
        locator<AppRouter>().push(
          GameDetailsRoute(bloc: locator<GamesBloc>()..gameDetails = GameModel(id: gameId)),
        );
      } catch (e) {
        debugPrint('Error navigating to game details: $e');
      }
      return;
    }

    // Friend requests are accepted / rejected from the notifications list.
    if (fromPush &&
        friendsFeatureEnabled &&
        (type == friendRequestNotificationType || type == friendRequestAcceptedNotificationType)) {
      try {
        locator<AppRouter>().push(NotificationsRoute());
      } catch (e) {
        debugPrint('Error navigating to notifications: $e');
      }
      return;
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
