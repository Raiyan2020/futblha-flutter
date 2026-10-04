class BookingPeriod {
  final String startTime;
  final String endTime;

  BookingPeriod({
    required this.startTime,
    required this.endTime,
  });
}

class BookingRequestModel {
  final String? code;
  final int playgroundId;
  final String bookingDate;
  final List<BookingPeriod> periods;
  final String paymentMethod;
  final bool useWallet;

  BookingRequestModel({
    this.code,
    required this.playgroundId,
    required this.bookingDate,
    required this.periods,
    required this.paymentMethod,
    required this.useWallet,
  });

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> formData = {
      'playground_id': playgroundId.toString(),
      'booking_date': bookingDate,
      'payment_method': paymentMethod,
      'use_wallet': useWallet ? '1' : '0',
    };

    if (code != null && code!.isNotEmpty) {
      formData['code'] = code!;
    }

    for (int i = 0; i < periods.length; i++) {
      formData['periods[$i][start_time]'] = periods[i].startTime;
      formData['periods[$i][end_time]'] = periods[i].endTime;
    }

    return formData;
  }
}

