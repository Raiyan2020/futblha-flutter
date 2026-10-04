import 'package:flutter/material.dart';

import '../../main.dart';

enum Environment { dev, prod }

class AppConfig extends InheritedWidget {
  final Environment environment;
  final String appTitle;

  const AppConfig({
    super.key,
    required MyApp super.child,
    required this.environment,
    required this.appTitle,
  });

  static AppConfig of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<AppConfig>()!;
  }

  @override
  bool updateShouldNotify(covariant InheritedWidget oldWidget) => false;
}
