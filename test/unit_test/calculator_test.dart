// test/unit_test/calculator_test.dart

import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/utils/calculator.dart';

void main() {
  group('Calculator', () {
    test('add two positive numbers', () {
      expect(Calculator.add(2, 3), 5);
    });

    test('add two negative numbers', () {
      expect(Calculator.add(-2, -3), -5);
    });

    test('add a positive and a negative number', () {
      expect(Calculator.add(2, -3), -1);
    });

    test('add zero to a number', () {
      expect(Calculator.add(5, 0), 5);
    });
  });
}
