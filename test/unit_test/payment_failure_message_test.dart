import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:futblha/presentation/pages/payment_method/payment_web_view_page.dart';

void main() {
  test('maps each backend failure reason to its message', () {
    expect(paymentFailureMessageKey('declined'), LocaleKeys.payment_failed_declined);
    expect(paymentFailureMessageKey('expired'), LocaleKeys.payment_failed_expired);
    expect(paymentFailureMessageKey('cancelled'), LocaleKeys.payment_failed_cancelled);
    expect(paymentFailureMessageKey('unknown'), LocaleKeys.payment_failed_unknown);
  });

  test('missing or new reasons fall back to the generic message', () {
    expect(paymentFailureMessageKey(null), LocaleKeys.payment_failed_unknown);
    expect(paymentFailureMessageKey('something_new'), LocaleKeys.payment_failed_unknown);
  });
}
