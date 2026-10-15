import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/application/core/di/app_component/app_component.dart';
import 'package:futblha/application/core/utils/helpers/responsive_ui_helper/responsive_config.dart';
import 'package:futblha/data/models/response_model/diwaniya/diwaniya_model.dart';
import 'package:futblha/data/models/response_model/games/game_booking_model.dart';
import 'package:futblha/data/models/response_model/games/game_model.dart';
import 'package:futblha/data/models/response_model/games/team_payment_model.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/games/widgets/game_booking_status_card.dart';

Future<void> _pump(WidgetTester tester, GameModel game) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) {
            locator<ResponsiveUiConfig>().initialize(context);
            return GameBookingStatusCard(game: game);
          },
        ),
      ),
    ),
  );
}

void main() {
  setUpAll(() => locator.registerSingleton<ResponsiveUiConfig>(ResponsiveUiConfig()));
  tearDownAll(() => locator.reset());

  test('maps every backend status, unknown ones show nothing', () {
    for (final s in [
      'unpaid',
      'pending_payment',
      'awaiting_payment',
      'paid',
      'failed',
      'expired',
    ]) {
      expect(GameBookingStatusCard.bookingStatusKey(s), isNotNull, reason: s);
    }
    for (final s in ['unpaid', 'pending', 'paid', 'failed', 'refunded']) {
      expect(GameBookingStatusCard.teamPaymentStatusKey(s), isNotNull, reason: s);
    }
    expect(GameBookingStatusCard.bookingStatusKey('something_new'), isNull);
    expect(GameBookingStatusCard.teamPaymentStatusKey(null), isNull);
  });

  test('hidden when there is no booking information', () {
    expect(GameBookingStatusCard.hasContent(GameModel(id: 1)), isFalse);
    expect(
      GameBookingStatusCard.hasContent(GameModel(id: 1, booking: GameBookingModel())),
      isFalse,
    );
    expect(
      GameBookingStatusCard.hasContent(GameModel(id: 1, booking: GameBookingModel(status: 'paid'))),
      isTrue,
    );
  });

  testWidgets('private challenge shows each Diwaniya with its amount and status', (tester) async {
    await _pump(
      tester,
      GameModel(
        id: 1,
        type: 'private',
        creatorDiwaniya: DiwaniyaModel(name: 'Host FC'),
        opponentDiwaniya: DiwaniyaModel(name: 'Guest FC'),
        booking: GameBookingModel(
          status: 'awaiting_payment',
          teamPayments: [
            TeamPaymentModel(team: 'host', amount: '20.001', status: 'paid'),
            TeamPaymentModel(team: 'opponent', amount: '20.000', status: 'unpaid'),
          ],
        ),
      ),
    );

    expect(find.text(LocaleKeys.booking_status_awaiting_payment), findsOneWidget);
    expect(find.text('Host FC'), findsOneWidget);
    expect(find.text('Guest FC'), findsOneWidget);
    expect(find.text('20.001 ${LocaleKeys.kwd}'), findsOneWidget);
    expect(find.text('20.000 ${LocaleKeys.kwd}'), findsOneWidget);
    expect(find.text(LocaleKeys.team_payment_paid), findsOneWidget);
    expect(find.text(LocaleKeys.team_payment_unpaid), findsOneWidget);
  });

  testWidgets('public game shows only the booking status', (tester) async {
    await _pump(
      tester,
      GameModel(
        id: 2,
        type: 'public',
        booking: GameBookingModel(status: 'expired'),
      ),
    );
    expect(find.text(LocaleKeys.booking_status_expired), findsOneWidget);
    expect(find.text(LocaleKeys.team_payment_paid), findsNothing);
  });
}
