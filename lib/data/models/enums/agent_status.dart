enum AgentStatus {
  offline(1),
  available(2),
  unavailable(3),
  busy(4),
  blocked(5);

  final int value;

  const AgentStatus(this.value);

  static AgentStatus getById(int id) {
    for (var status in AgentStatus.values) {
      if (status.value == id) {
        return status;
      }
    }
    throw ArgumentError('Invalid id: $id');
  }
}
