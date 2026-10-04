class AddRateRequestModel {
  final int playgroundId;
  final int rate;

  AddRateRequestModel({required this.playgroundId, required this.rate});

  Map<String, dynamic> toFormData() {
    return {'playground_id': playgroundId.toString(), 'rate': rate.toString()};
  }
}
