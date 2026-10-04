import '../playgrounds/booking_request_model.dart';

class UpdateGameBookingRequestModel {
  final String? code;
  final int playgroundId;
  final String bookingDate;
  final List<BookingPeriod> periods;
  final String? paymentMethod;
  final bool? useWallet;

  UpdateGameBookingRequestModel({
    this.code,
    required this.playgroundId,
    required this.bookingDate,
    required this.periods,
    this.paymentMethod,
    this.useWallet,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> formData = {
      'playground_id': playgroundId.toString(),
      'booking_date': bookingDate,
    };

    if (code != null && code!.isNotEmpty) {
      formData['code'] = code!;
    }

    if (paymentMethod != null) {
      formData['payment_method'] = paymentMethod!;
    }

    if (useWallet != null) {
      formData['use_wallet'] = useWallet! ? '1' : '0';
    }

    for (int i = 0; i < periods.length; i++) {
      formData['periods[$i][start_time]'] = periods[i].startTime;
      formData['periods[$i][end_time]'] = periods[i].endTime;
    }

    return formData;
  }
}
