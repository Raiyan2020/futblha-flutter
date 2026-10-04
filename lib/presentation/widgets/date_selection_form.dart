import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:futblha/generated/locale_keys.g.dart';

import '../../application/config/app_assets.dart';
import '../../application/config/design_system/app_colors.dart';
import 'package:futblha/presentation/widgets/app_date_picker.dart';

class DateSelectionForm extends StatefulWidget {
  final Function(String) onDateSelected;
  final String? initialValue;

  const DateSelectionForm({super.key, required this.onDateSelected, this.initialValue});

  @override
  State<DateSelectionForm> createState() => _DateSelectionFormState();
}

class _DateSelectionFormState extends State<DateSelectionForm> {
  late TextEditingController _dateController;

  @override
  void initState() {
    super.initState();
    _dateController = TextEditingController(text: widget.initialValue);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        RichText(
          text: TextSpan(
            style: DefaultTextStyle.of(context).style,
            children: [
              TextSpan(
                text: LocaleKeys.date_of_birth.tr(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              TextSpan(
                text: LocaleKeys.optional.tr(),
                style: const TextStyle(
                  color: AppColors.primaryGrey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        GestureDetector(
          onTap: () => _selectDate(context),
          child: TextFormField(
            controller: _dateController,
            readOnly: true,
            onTap: () => _selectDate(context),
            decoration: InputDecoration(
              hintText: LocaleKeys.date_hint.tr(),
              suffixIcon: IconButton(
                icon: SvgPicture.asset(AppAssets.ic_calender),
                onPressed: () => _selectDate(context),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showAppDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      setState(() {
        widget.onDateSelected(getFormattedDate(picked));
        _dateController.text = getFormattedDate(picked);
      });
    }
  }

  String getFormattedDate(DateTime picked) {
    return DateFormat('MM/dd/yyyy', 'en').format(picked);
  }
}
