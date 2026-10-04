enum GroupType {
  created(1),
  subscribed(2);

  final int value;

  const GroupType(this.value);

  static GroupType getById(int id) {
    for (var status in GroupType.values) {
      if (status.value == id) {
        return status;
      }
    }
    throw ArgumentError('Invalid id: $id');
  }
}
