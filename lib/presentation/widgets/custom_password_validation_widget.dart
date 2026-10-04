import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../application/config/app_assets.dart';
import '../../application/config/design_system/app_colors.dart';

enum PasswordStrengthLevel { weak, good, veryGood }

final validIcon = SvgPicture.asset(AppAssets.ic_valid_password);
final invalidIcon = SvgPicture.asset(AppAssets.ic_invalid_password);

extension PasswordStrengthLevelExtension on PasswordStrengthLevel {
  Color get color {
    switch (this) {
      case PasswordStrengthLevel.weak:
        return AppColors.errorColor;
      case PasswordStrengthLevel.good:
      case PasswordStrengthLevel.veryGood:
        return AppColors.primaryColor;
    }
  }

  String get subText {
    switch (this) {
      case PasswordStrengthLevel.weak:
        return LocaleKeys.password_strength_weak.tr();
      case PasswordStrengthLevel.good:
        return LocaleKeys.password_strength_good.tr();
      case PasswordStrengthLevel.veryGood:
        return LocaleKeys.password_strength_very_good.tr();
    }
  }
}

typedef PasswordValidationCallback = void Function(bool isValid);

class PasswordValidationWidget extends StatefulWidget {
  final PasswordValidationCallback? onValidationChanged;
  final String? userName;
  final String? password;
  final String? confirmPassword;

  const PasswordValidationWidget({
    super.key,
    this.userName,
    this.password,
    this.confirmPassword,
    this.onValidationChanged,
  });

  @override
  State<PasswordValidationWidget> createState() => _PasswordValidationWidgetState();
}

class _PasswordValidationWidgetState extends State<PasswordValidationWidget> {
  @override
  Widget build(BuildContext context) {
    return _buildPasswordStrengthWidget();
  }

  Widget _buildPasswordStrengthWidget() {
    String password = widget.password ?? '';
    String confirmPassword = widget.confirmPassword ?? '';

    SvgPicture strengthIcon;
    String strengthText;
    String strengthSubText;
    Color strengthTextColor;

    List<ValidationRule> validationRules = [
      ValidationRule(
        message: LocaleKeys.cannot_contain_name.tr(),
        isValid:
            isPasswordValid(widget.userName.toString(), password) &&
            password.contains(RegExp(r'[a-zA-Z]')),
      ),
      ValidationRule(message: LocaleKeys.at_least_8_characters.tr(), isValid: password.length >= 8),
      ValidationRule(
        message: LocaleKeys.contains_number_or_symbol.tr(),
        isValid:
            password.contains(RegExp(r'[0-9]')) ||
            password.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]')),
      ),
      ValidationRule(
        message: LocaleKeys.validation_password_match.tr(),
        isValid: password == confirmPassword && password.isNotEmpty,
      ),
    ];

    int passwordStrength = validationRules.where((rule) => rule.isValid).length;
    strengthIcon = passwordStrength > 0 ? validIcon : invalidIcon;
    strengthText = LocaleKeys.password_strength.tr();
    switch (passwordStrength) {
      case 1:
        strengthTextColor = PasswordStrengthLevel.weak.color;
        strengthSubText = PasswordStrengthLevel.weak.subText;
        break;
      case 2:
        strengthTextColor = PasswordStrengthLevel.good.color;
        strengthSubText = PasswordStrengthLevel.good.subText;
        break;
      case 3:
      case 4:
        strengthTextColor = PasswordStrengthLevel.veryGood.color;
        strengthSubText = PasswordStrengthLevel.veryGood.subText;
        break;
      default:
        strengthTextColor = PasswordStrengthLevel.weak.color;
        strengthSubText = PasswordStrengthLevel.weak.subText;
    }
    bool isDataValid = validationRules.every((rule) => rule.isValid);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        setState(() {
          if (password != confirmPassword) {
            widget.onValidationChanged?.call(false);
          } else {
            widget.onValidationChanged?.call(isDataValid);
          }
        });
      }
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildValidationRow(
          strengthIcon,
          strengthText,
          strengthSubText: strengthSubText,
          strengthTextColor: strengthTextColor,
        ),
        _buildValidationRules(validationRules),
      ],
    );
  }

  bool isPasswordValid(String username, String password) {
    if (password.toLowerCase().contains(username.toLowerCase())) {
      return false;
    }

    return true;
  }

  ListView _buildValidationRules(List<ValidationRule> validationRules) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: validationRules.length,
      itemBuilder: (context, index) {
        return _buildValidationRow(
          validationRules[index].isValid ? validIcon : invalidIcon,
          validationRules[index].message,
        );
      },
    );
  }

  Widget _buildValidationRow(
    SvgPicture prefixIcon,
    String text, {
    String? strengthSubText,
    Color? strengthTextColor,
  }) {
    return Row(
      children: [
        prefixIcon,
        const SizedBox(width: 8.0),
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(text: text, style: Theme.of(context).textTheme.titleMedium),
              TextSpan(text: ' ', style: Theme.of(context).textTheme.titleMedium),
              TextSpan(
                text: strengthSubText ?? '',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(color: strengthTextColor),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class ValidationRule {
  final String message;
  final bool isValid;

  ValidationRule({required this.message, required this.isValid});
}
