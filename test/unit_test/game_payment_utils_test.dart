import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/data/models/response_model/games/game_booking_model.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/response_model/games/game_user_permission_model.dart';
import 'package:futblha/data/models/response_model/games/team_payment_model.dart';
import 'package:futblha/presentation/pages/games/utils/game_payment_utils.dart';

GameModel _game({
  List<TeamPaymentModel>? teamPayments,
  bool? canBook,
  bool? canPayTeamShare,
  String? payerTeam,
}) => GameModel(
  id: 1,
  booking: GameBookingModel(teamPayments: teamPayments),
  userPermission: GameUserPermissionModel(
    canBook: canBook,
    canPayTeamShare: canPayTeamShare,
    payerTeam: payerTeam,
  ),
);

final _shares = [
  TeamPaymentModel(team: 'host', amount: '20.001', status: 'paid'),
  TeamPaymentModel(team: 'opponent', amount: '20.000', status: 'unpaid'),
];

void main() {
  group('public / my_diwanya (no team_payments)', () {
    test('pay button follows can_book', () {
      expect(GamePaymentUtils.canPay(_game(canBook: true)), isTrue);
      expect(GamePaymentUtils.canPay(_game(canBook: false)), isFalse);
      expect(GamePaymentUtils.canPay(_game()), isFalse);
    });

    test('can_pay_team_share is ignored', () {
      expect(GamePaymentUtils.canPay(_game(canBook: false, canPayTeamShare: true)), isFalse);
      expect(GamePaymentUtils.isTeamSharePayment(_game(canBook: true)), isFalse);
    });
  });

  group('private challenge (team_payments present)', () {
    test('pay button follows can_pay_team_share, never can_book', () {
      expect(GamePaymentUtils.canPay(_game(teamPayments: _shares, canPayTeamShare: true)), isTrue);
      expect(
        GamePaymentUtils.canPay(
          _game(teamPayments: _shares, canBook: true, canPayTeamShare: false),
        ),
        isFalse,
      );
    });

    test('the share shown is the payer team entry from the backend', () {
      expect(
        GamePaymentUtils.myTeamShare(_game(teamPayments: _shares, payerTeam: 'host'))?.amount,
        '20.001',
      );
      expect(
        GamePaymentUtils.myTeamShare(_game(teamPayments: _shares, payerTeam: 'opponent'))?.amount,
        '20.000',
      );
    });

    test('no share when the user admins neither Diwaniya', () {
      expect(GamePaymentUtils.myTeamShare(_game(teamPayments: _shares)), isNull);
    });
  });
}
