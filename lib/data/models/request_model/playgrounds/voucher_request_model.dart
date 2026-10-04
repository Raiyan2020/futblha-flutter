class VoucherRequestModel {
  final String code;

  VoucherRequestModel({
    required this.code,
  });

  Map<String, dynamic> toFormData() {
    return {
      'code': code,
    };
  }
}

