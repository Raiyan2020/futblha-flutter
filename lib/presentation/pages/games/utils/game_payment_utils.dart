import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/response_model/games/team_payment_model.dart';

/// Who can pay a game's booking, read only from what the backend returns.
class GamePaymentUtils {
  GamePaymentUtils._();

  /// Private challenges: each Diwaniya pays its own share (`team_payments`).
  static bool isTeamSharePayment(GameModel game) => game.booking?.teamPayments != null;

  /// `can_pay_team_share` for private challenges, `can_book` otherwise. The
  /// backend already applies the roster rule, payment_timing and "already paid".
  static bool canPay(GameModel game) => isTeamSharePayment(game)
      ? game.userPermission?.canPayTeamShare == true
      : game.userPermission?.canBook == true;

  /// The share the current user pays (their `payer_team`), if any.
  static TeamPaymentModel? myTeamShare(GameModel game) {
    final team = game.userPermission?.payerTeam;
    if (team == null) return null;
    for (final payment in game.booking?.teamPayments ?? const <TeamPaymentModel>[]) {
      if (payment.team == team) return payment;
    }
    return null;
  }
}
