import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';

void main() {
  test('parses booking status, team payments and payer permissions (private game)', () {
    final game = GameModel.fromJson({
      'id': 1,
      'type': 'private',
      'payment_timing': null,
      'booking': {
        'status': 'awaiting_payment',
        'grand_total': '40.000',
        'team_payments': [
          {
            'team': 'host',
            'diwaniya_id': 5,
            'amount': '20.000',
            'status': 'paid',
            'paid_at': '2026-10-15T14:26:34+03:00',
          },
          {
            'team': 'opponent',
            'diwaniya_id': 6,
            'amount': '20.000',
            'status': 'unpaid',
            'paid_at': null,
          },
        ],
      },
      'user_permission': {'can_book': false, 'can_pay_team_share': true, 'payer_team': 'opponent'},
    });

    expect(game.booking?.status, 'awaiting_payment');
    expect(game.booking?.teamPayments, hasLength(2));
    expect(game.booking?.teamPayments?.first.team, 'host');
    expect(game.booking?.teamPayments?.first.diwaniyaId, 5);
    expect(game.booking?.teamPayments?.first.status, 'paid');
    expect(game.booking?.teamPayments?.last.amount, '20.000');
    expect(game.booking?.teamPayments?.last.paidAt, isNull);
    expect(game.userPermission?.canBook, isFalse);
    expect(game.userPermission?.canPayTeamShare, isTrue);
    expect(game.userPermission?.payerTeam, 'opponent');
  });

  test('parses payment_timing and a booking without team payments (public game)', () {
    final game = GameModel.fromJson({
      'id': 2,
      'type': 'public',
      'payment_timing': 'immediate',
      'booking': {'status': 'pending_payment', 'team_payments': null},
      'user_permission': {'can_book': true, 'can_pay_team_share': false, 'payer_team': null},
    });

    expect(game.paymentTiming, 'immediate');
    expect(game.booking?.status, 'pending_payment');
    expect(game.booking?.teamPayments, isNull);
    expect(game.userPermission?.canBook, isTrue);
    expect(game.userPermission?.payerTeam, isNull);
  });
}
