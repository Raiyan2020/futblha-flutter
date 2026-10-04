class AddBalanceRequestModel {
  final double amount;
  final String paymentMethod;

  AddBalanceRequestModel({
    required this.amount,
    required this.paymentMethod,
  });

  Map<String, dynamic> toFormData() {
    return {
      'amount': amount.toString(),
      'payment_method': paymentMethod,
    };
  }
}

