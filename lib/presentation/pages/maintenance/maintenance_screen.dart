import 'package:auto_route/auto_route.dart';
import 'package:flutter/material.dart';
import 'package:futblha/application/config/design_system/app_theme_colors.dart';

@RoutePage()
class MaintenanceScreen extends StatelessWidget {
  const MaintenanceScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.cardBackground,
      body: const SizedBox.expand(),
    );
  }
}
