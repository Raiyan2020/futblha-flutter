import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/application/core/utils/constants/app_constants.dart';
import 'package:futblha/application/core/utils/fcm/notification_navigation.dart';

void main() {
  group('gameIdFrom', () {
    test('reads game_id from a push payload (strings or ints)', () {
      expect(NotificationNavigation.gameIdFrom({'type': 'game_confirmed', 'game_id': '123'}), 123);
      expect(NotificationNavigation.gameIdFrom({'game_id': 123}), 123);
    });

    test('reads game_id from an in-app notification data JSON string', () {
      expect(NotificationNavigation.gameIdFrom('{"game_id":45}'), 45);
      expect(NotificationNavigation.gameIdFrom('{"extra":{"game_id":"46"}}'), 46);
    });

    test('returns null when missing or malformed', () {
      expect(NotificationNavigation.gameIdFrom(null), isNull);
      expect(NotificationNavigation.gameIdFrom(''), isNull);
      expect(NotificationNavigation.gameIdFrom('not json'), isNull);
      expect(NotificationNavigation.gameIdFrom({'type': 'x'}), isNull);
      expect(NotificationNavigation.gameIdFrom({'game_id': 'abc'}), isNull);
    });
  });

  test('all four payment notification types open the game page', () {
    expect(gameNotificationTypes, {
      'game_payment_required',
      'game_team_payment_received',
      'game_confirmed',
      'game_refund_pending',
    });
    expect(gameNotificationTypes.contains(gameInvitationNotificationType), isFalse);
  });
}
