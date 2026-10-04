class BookingAvailableRequestModel {
  final String position;

  BookingAvailableRequestModel({required this.position});

  Map<String, dynamic> toFormData() {
    return {'position': position};
  }
}
