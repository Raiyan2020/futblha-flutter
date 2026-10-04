extension NameExtraction on String {
  String extractFirstAndSecondName() {
    List<String> nameParts = split(' ');

    if (nameParts.isNotEmpty) {
      String firstName = nameParts.first.trim();
      String lastName = nameParts.length > 1 ? nameParts[1].trim() : '';

      if (firstName.isNotEmpty) {
        return "$firstName $lastName".trim();
      }
    }

    return "";
  }
}
