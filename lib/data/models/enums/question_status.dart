import 'package:flutter/material.dart';

enum QuestionStatus {
  correct(1, Colors.green, Icons.check_circle),
  incorrect(2, Colors.red, Icons.cancel),
  notAnswered(1, Colors.grey, Icons.lock),
  current(2, Colors.black, Icons.arrow_forward_ios);

  final int value;
  final Color color;
  final IconData icon;

  const QuestionStatus(this.value, this.color, this.icon);

  static QuestionStatus getTypeFromInt(int value) {
    for (var element in QuestionStatus.values) {
      if (element.value == value) {
        return element;
      }
    }
    return QuestionStatus.correct;
  }
}
