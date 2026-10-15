import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/data/models/request_model/games/create_game_request_model.dart';
import 'package:futblha/presentation/pages/games/create_game_page.dart';

CreateGameRequestModel _request({required String type, String? paymentTiming}) =>
    CreateGameRequestModel(
      playgroundId: 1,
      bookingDate: '2026-10-20',
      periods: [GamePeriod(startTime: '17:00', endTime: '18:00')],
      type: type,
      players: 10,
      position: 'attacker',
      paymentTiming: paymentTiming,
    );

void main() {
  test('API values match the backend contract', () {
    expect(GamePaymentTiming.immediate.apiValue, 'immediate');
    expect(GamePaymentTiming.afterPlayersComplete.apiValue, 'after_players_complete');
  });

  test('public and my_diwanya games send payment_timing', () {
    expect(
      _request(type: 'public', paymentTiming: 'immediate').toFormData()['payment_timing'],
      'immediate',
    );
    expect(
      _request(
        type: 'my_diwanya',
        paymentTiming: 'after_players_complete',
      ).toFormData()['payment_timing'],
      'after_players_complete',
    );
  });

  test('private games never send payment_timing', () {
    expect(_request(type: 'private').toFormData().containsKey('payment_timing'), isFalse);
  });

  test('existing fields are unchanged', () {
    final data = _request(type: 'public', paymentTiming: 'immediate').toFormData();
    expect(data['playground_id'], '1');
    expect(data['booking_date'], '2026-10-20');
    expect(data['type'], 'public');
    expect(data['players'], '10');
    expect(data['position'], 'attacker');
    expect(data['periods[0][start_time]'], '17:00');
    expect(data['periods[0][end_time]'], '18:00');
  });
}
