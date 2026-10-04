class ConfirmGameBookingRequestModel {
  final String paymentMethod;
  final bool useWallet;
  final String? code;

  ConfirmGameBookingRequestModel({required this.paymentMethod, required this.useWallet, this.code});

  Map<String, dynamic> toFormData() {
    final Map<String, dynamic> formData = {
      'payment_method': paymentMethod,
      'use_wallet': useWallet ? '1' : '0',
    };

    if (code != null && code!.isNotEmpty) {
      formData['code'] = code!;
    }

    return formData;
  }
}
