import 'package:easy_localization/easy_localization.dart';

import '../../../generated/locale_keys.g.dart';

class AppValidator {
  static const String requiredFieldMessage = LocaleKeys.required_field;
  static const String invalidPasswordConfirmation = LocaleKeys.passwords_do_not_match;
  static const String invalidPasswordLength = LocaleKeys.password_length;
  static const String invalidEmail = LocaleKeys.invalid_email;
  static const String invalidPhoneNumber = LocaleKeys.invalid_phone_number;
  static const String invalidPhoneNumberLength = LocaleKeys.phone_number_length;

  String? validatorRequired(dynamic value, {String? message}) {
    if (value == null || value == '') {
      return message?.tr() ?? requiredFieldMessage.tr();
    }
    return null;
  }

  String? validatorPassword(String? password, {String? confirmPassword}) {
    if (validatorRequired(password) != null) {
      return validatorRequired(password);
    }

    if (confirmPassword != null && password != confirmPassword) {
      return invalidPasswordConfirmation.tr();
    }

    if (password!.length < 6 || password.length > 16) {
      return invalidPasswordLength.tr();
    }

    return null;
  }

  String? validatorEmail(String? value) {
    if (validatorRequired(value) != null) {
      return validatorRequired(value);
    }

    bool emailValid = RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+").hasMatch(value!);

    if (!emailValid) {
      return invalidEmail.tr();
    }

    return null;
  }

  String? validateMobile(String number) {
    if (number.isNotEmpty) {
      if (number.length == 8) {
        return null;
      } else {
        return invalidPhoneNumberLength.tr();
      }
    } else {
      return invalidPhoneNumber.tr();
    }
  }

  String? validateCountryCode(String? value, String? dialNumber) {
    if (value != null && dialNumber != null && value.isNotEmpty) {
      String number = dialNumber + value;
      return (number.length >= 9 && number.length <= 15) ? null : invalidPhoneNumberLength;
    } else {
      return invalidPhoneNumber.tr();
    }
  }
}

bool validateMobile(String mobile) {
  return mobile.isNotEmpty && mobile.length == 8;
}

bool validatePassword(String password) {
  if (password.isEmpty || password.length < 8) {
    return false;
  }

  return RegExp(r'^(?=.*[a-z])(?=.*[A-Z]?)(?=.*\d)').hasMatch(password);
}

bool validateRequired(String value) {
  if (value.isEmpty || value.length < 3) {
    return false;
  }
  return true;
}

bool isValidEmail(String email) {
  // Regular expression for a simple email validation
  final emailRegex = RegExp(r'^[\w-]+(\.[\w-]+)*@([\w-]+\.)+[a-zA-Z]{2,7}$');
  return emailRegex.hasMatch(email);
}
