

enum DriverFlowStatus {
  NoReach(0),
  ReachFirst(1),
  StartFirst(2);

  final int value;

  const DriverFlowStatus(this.value);

  static DriverFlowStatus getTypeFromInt(int value) {
    for (var element in DriverFlowStatus.values) {
      if (element.value == value) {
        return element;
      }
    }
    return DriverFlowStatus.NoReach;
  }
}
