import 'dart:async';
import 'dart:ui' as ui;

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../application/config/design_system/app_colors.dart';

final GlobalKey<State<OtpWidget>> otpWidgetKey = GlobalKey<State<OtpWidget>>();

class OtpWidget extends StatefulWidget {
  final int length;
  final ValueChanged<String> onCompleted;
  final ValueChanged<bool> isFilled;
  final VoidCallback onResendOtpClicked;

  const OtpWidget({
    super.key,
    required this.length,
    required this.onCompleted,
    required this.isFilled,
    required this.onResendOtpClicked,
  });

  @override
  State<OtpWidget> createState() => _OtpWidgetState();
}

class _OtpWidgetState extends State<OtpWidget> {
  static const double otpFieldWidth = 50.0;
  static const double verticalSpacing = 16.0;
  static const int initialResendCounter = 30;

  late List<FocusNode> _focusNodes;
  late List<TextEditingController> _controllers;
  Timer? _resendTimer;
  int _resendCounter = initialResendCounter;

  @override
  void initState() {
    super.initState();
    _focusNodes = List.generate(widget.length, (index) => FocusNode());
    _controllers = List.generate(widget.length, (index) => TextEditingController());
    startResendTimer();
  }

  @override
  void dispose() {
    _resendTimer?.cancel();
    for (var node in _focusNodes) {
      node.dispose();
    }
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }

  void clearControllers() {
    for (var controller in _controllers) {
      controller.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        buildOtpInputRow(),
        const SizedBox(height: verticalSpacing),
        buildResendRow(),
      ],
    );
  }

  Widget buildOtpInputRow() {
    return Directionality(
      textDirection: ui.TextDirection.ltr,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(
          widget.length,
          (index) => SizedBox(width: otpFieldWidth, child: buildOtpTextField(index)),
        ),
      ),
    );
  }

  Widget buildOtpTextField(int index) {
    return TextField(
      controller: _controllers[index],
      focusNode: _focusNodes[index],
      keyboardType: TextInputType.number,
      textAlign: TextAlign.center,
      textDirection: ui.TextDirection.ltr,
      inputFormatters: [
        FilteringTextInputFormatter.digitsOnly, // Allow only numeric input
      ],
      maxLength: 1,
      onChanged: (value) {
        if (value.isNotEmpty && index < widget.length - 1) {
          _focusNodes[index + 1].requestFocus();
        }
        if (isOtpEntered()) {
          widget.isFilled(true);
          widget.onCompleted(getOtp());
        } else {
          widget.isFilled(false);
        }
      },
      decoration: const InputDecoration(counterText: '', border: OutlineInputBorder()),
    );
  }

  Widget buildResendRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        Text(LocaleKeys.get_code_text.tr()),
        Flexible(child: buildResendText()),
      ],
    );
  }

  Widget buildResendText() {
    return _resendCounter > 0
        ? Text(
            " ${LocaleKeys.resend_otp_text.tr()} 0:$_resendCounter",
            style: Theme.of(context).textTheme.titleMedium?.copyWith(color: AppColors.primaryColor),
          )
        : GestureDetector(
            onTap: () {
              startResendTimer();
              widget.onResendOtpClicked();
            },
            child: Text(
              LocaleKeys.resend_otp_button.tr(),
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
                color: AppColors.primaryColor,
                decoration: TextDecoration.underline,
              ),
            ),
          );
  }

  bool isOtpEntered() {
    for (var controller in _controllers) {
      if (controller.text.isEmpty) {
        return false;
      }
    }
    return true;
  }

  String getOtp() {
    StringBuffer otpBuffer = StringBuffer();
    for (var controller in _controllers) {
      otpBuffer.write(controller.text);
    }
    return otpBuffer.toString();
  }

  void startResendTimer() {
    _resendCounter = initialResendCounter; // Reset the counter
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_resendCounter > 0) {
          _resendCounter--;
        } else {
          timer.cancel();
        }
      });
    });
  }
}
