import 'dart:ui';

import '../../../application/config/design_system/app_colors.dart';

enum TaskType {
  pickup(1, AppColors.primaryBlack),
  delivery(2, AppColors.primaryYellow);

  final int value;
  final Color color;

  const TaskType(this.value, this.color);

  static TaskType getTypeFromInt(int value) {
    for (var element in TaskType.values) {
      if (element.value == value) {
        return element;
      }
    }
    return TaskType.pickup;
  }
}
