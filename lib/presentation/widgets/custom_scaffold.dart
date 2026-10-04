import 'package:flutter/material.dart';
import 'package:futblha/presentation/widgets/scaffold_pading.dart';

class CustomScaffold extends StatelessWidget {
  const CustomScaffold({super.key, this.appBar, required this.body, this.hasPadding = false});
  final PreferredSizeWidget? appBar;
  final Widget body;
  final bool hasPadding;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: appBar,
      body: Padding(
        padding: hasPadding ? symmetricPadding(15, 12) : EdgeInsets.zero,
        child: body,
      ),
    );
  }
}
