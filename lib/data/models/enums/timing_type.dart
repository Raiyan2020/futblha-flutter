enum TimingType { MORNING, EVENING }

TimingType getTypeFromInt(int value) {
  switch (value) {
    case 1:
      return TimingType.MORNING;
    case 2:
      return TimingType.EVENING;
    default:
      throw ArgumentError("Invalid value: $value");
  }
}

int getIntFromTimingType(TimingType value) {
  switch (value) {
    case TimingType.MORNING:
      return 1;
    case TimingType.EVENING:
      return 2;
  }
}
