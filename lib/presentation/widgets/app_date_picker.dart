import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:futblha/generated/locale_keys.g.dart';

/// Shows the Material calendar on Android and a year / month / day wheel picker on iOS.
Future<DateTime?> showAppDatePicker({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
  TransitionBuilder? builder,
}) {
  if (Theme.of(context).platform != TargetPlatform.iOS) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      initialEntryMode: DatePickerEntryMode.calendarOnly,
      builder: builder,
    );
  }
  return _showCupertinoDatePicker(context, initialDate, firstDate, lastDate);
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

Future<DateTime?> _showCupertinoDatePicker(
  BuildContext context,
  DateTime initialDate,
  DateTime firstDate,
  DateTime lastDate,
) {
  final first = _dateOnly(firstDate);
  final last = _dateOnly(lastDate);
  var selected = _dateOnly(initialDate);
  if (selected.isBefore(first)) selected = first;
  if (selected.isAfter(last)) selected = last;

  return showCupertinoModalPopup<DateTime>(
    context: context,
    builder: (popupContext) {
      final background = CupertinoColors.systemBackground.resolveFrom(popupContext);
      final labelColor = CupertinoColors.label.resolveFrom(popupContext);
      final labelStyle = TextStyle(color: labelColor, fontSize: 17, fontWeight: FontWeight.w700);

      return Material(
        color: background,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        clipBehavior: Clip.antiAlias,
        child: SafeArea(
          top: false,
          child: SizedBox(
            height: 340,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    CupertinoButton(
                      onPressed: () => Navigator.pop(popupContext),
                      child: Text(LocaleKeys.cancel.tr()),
                    ),
                    CupertinoButton(
                      onPressed: () => Navigator.pop(popupContext, selected),
                      child: Text(
                        LocaleKeys.confirm.tr(),
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    Expanded(child: Text(LocaleKeys.date_year.tr(), textAlign: TextAlign.center, style: labelStyle)),
                    Expanded(child: Text(LocaleKeys.date_month.tr(), textAlign: TextAlign.center, style: labelStyle)),
                    Expanded(child: Text(LocaleKeys.date_day.tr(), textAlign: TextAlign.center, style: labelStyle)),
                  ],
                ),
                Expanded(
                  child: _YearMonthDayPicker(
                    initialDate: selected,
                    firstDate: first,
                    lastDate: last,
                    onChanged: (date) => selected = date,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class _YearMonthDayPicker extends StatefulWidget {
  final DateTime initialDate;
  final DateTime firstDate;
  final DateTime lastDate;
  final ValueChanged<DateTime> onChanged;

  const _YearMonthDayPicker({
    required this.initialDate,
    required this.firstDate,
    required this.lastDate,
    required this.onChanged,
  });

  @override
  State<_YearMonthDayPicker> createState() => _YearMonthDayPickerState();
}

class _YearMonthDayPickerState extends State<_YearMonthDayPicker> {
  static const double _itemExtent = 36;

  late int _year = widget.initialDate.year;
  late int _month = widget.initialDate.month;
  late int _day = widget.initialDate.day;

  late final FixedExtentScrollController _yearController =
      FixedExtentScrollController(initialItem: _year - widget.firstDate.year);
  late FixedExtentScrollController _monthController =
      FixedExtentScrollController(initialItem: _month - _minMonth);
  late FixedExtentScrollController _dayController = FixedExtentScrollController(initialItem: _day - _minDay);

  int get _minMonth => _year == widget.firstDate.year ? widget.firstDate.month : 1;

  int get _maxMonth => _year == widget.lastDate.year ? widget.lastDate.month : 12;

  int get _minDay =>
      _year == widget.firstDate.year && _month == widget.firstDate.month ? widget.firstDate.day : 1;

  int get _maxDay => _year == widget.lastDate.year && _month == widget.lastDate.month
      ? widget.lastDate.day
      : DateUtils.getDaysInMonth(_year, _month);

  @override
  void dispose() {
    _yearController.dispose();
    _monthController.dispose();
    _dayController.dispose();
    super.dispose();
  }

  // Swaps in a controller for a column whose range changed; the old one is disposed after it detaches.
  FixedExtentScrollController _replaceController(FixedExtentScrollController old, int initialItem) {
    WidgetsBinding.instance.addPostFrameCallback((_) => old.dispose());
    return FixedExtentScrollController(initialItem: initialItem);
  }

  void _update({int? year, int? month, int? day}) {
    final oldMonthRange = (_minMonth, _maxMonth);
    final oldDayRange = (_minDay, _maxDay);
    setState(() {
      _year = year ?? _year;
      _month = (month ?? _month).clamp(_minMonth, _maxMonth);
      _day = (day ?? _day).clamp(_minDay, _maxDay);
      if (oldMonthRange != (_minMonth, _maxMonth)) {
        _monthController = _replaceController(_monthController, _month - _minMonth);
      }
      if (oldDayRange != (_minDay, _maxDay)) {
        _dayController = _replaceController(_dayController, _day - _minDay);
      }
    });
    widget.onChanged(DateTime(_year, _month, _day));
  }

  Widget _buildColumn({
    required Key key,
    required FixedExtentScrollController controller,
    required int min,
    required int max,
    required ValueChanged<int> onSelected,
  }) {
    return Expanded(
      child: CupertinoPicker(
        key: key,
        scrollController: controller,
        itemExtent: _itemExtent,
        onSelectedItemChanged: (index) => onSelected(min + index),
        children: [
          for (var value = min; value <= max; value++) Center(child: Text('$value')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _buildColumn(
          key: const ValueKey('year'),
          controller: _yearController,
          min: widget.firstDate.year,
          max: widget.lastDate.year,
          onSelected: (year) => _update(year: year),
        ),
        _buildColumn(
          key: ValueKey('month-$_minMonth-$_maxMonth'),
          controller: _monthController,
          min: _minMonth,
          max: _maxMonth,
          onSelected: (month) => _update(month: month),
        ),
        _buildColumn(
          key: ValueKey('day-$_minDay-$_maxDay'),
          controller: _dayController,
          min: _minDay,
          max: _maxDay,
          onSelected: (day) => _update(day: day),
        ),
      ],
    );
  }
}
