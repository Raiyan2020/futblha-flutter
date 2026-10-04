class AddGameResultRequestModel {
  final String result; // "win", "lose", or "draw"

  AddGameResultRequestModel({required this.result});

  Map<String, dynamic> toFormData() {
    return {'result': result};
  }
}
