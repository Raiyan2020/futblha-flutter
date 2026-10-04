import 'package:flutter/material.dart';

import 'custom_elevated_button.dart';

class CircularElevatedButton extends CustomElevatedButton {
  const CircularElevatedButton({
    super.key,
    required super.title,
    super.isEnabled,
    super.filled,
    super.onPressed,
  });

  @override
  Widget build(BuildContext context, {BorderRadius? borderRadius}) {
    return SizedBox(
      width: double.infinity,
      child: super.build(context,
          borderRadius: const BorderRadius.only(
            topLeft: Radius.circular(20),
            bottomRight: Radius.circular(20),
          )),
    );
  }
}
