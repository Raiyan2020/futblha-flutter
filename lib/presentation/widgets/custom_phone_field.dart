import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl_phone_field/country_picker_dialog.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:futblha/application/config/design_system/decorations.dart';
import 'package:easy_localization/easy_localization.dart' as easy;
import 'package:futblha/generated/locale_keys.g.dart';
import 'package:intl_phone_field/countries.dart';

class CustomPhoneField extends StatelessWidget {
  const CustomPhoneField({
    super.key,
    required this.controller,
    this.onChanged,
    this.onCountryChanged,
    this.initialCountryCode,
    this.validator,
    this.hintText,
    this.autovalidateMode,
  });

  final TextEditingController controller;
  final void Function(PhoneNumber)? onChanged;
  final void Function(Country)? onCountryChanged;
  final String? initialCountryCode;
  final String? Function(PhoneNumber?)? validator;
  final String? hintText;
  final AutovalidateMode? autovalidateMode;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: IntlPhoneField(
        controller: controller,
        dropdownIconPosition: IconPosition.trailing,
        dropdownIcon: const Icon(Icons.keyboard_arrow_down),
        invalidNumberMessage: LocaleKeys.invalid_phone_number.tr(),
        flagsButtonPadding: const EdgeInsetsDirectional.only(start: 14),
        pickerDialogStyle: PickerDialogStyle(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          listTileDivider: const SizedBox.shrink(),
          searchFieldInputDecoration: AppDecorations.inputTextDecoration(
            hint: LocaleKeys.search.tr(),
            fillColor: Theme.of(context).scaffoldBackgroundColor,
          ),
        ),
        decoration: AppDecorations.inputTextDecoration(
          hint: hintText,
          fillColor: Theme.of(context).scaffoldBackgroundColor,
        ),
        initialCountryCode: initialCountryCode,
        inputFormatters: [
          FilteringTextInputFormatter.digitsOnly, // only 0-9 allowed
        ],
        onChanged: onChanged,
        onCountryChanged: onCountryChanged,
        autovalidateMode: autovalidateMode ?? AutovalidateMode.disabled,
        validator: validator,
      ),
    );
  }
}
