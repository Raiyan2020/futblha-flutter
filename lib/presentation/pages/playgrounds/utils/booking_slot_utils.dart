/// A booking slot resolved to real date-times on its booking date.
///
/// The API returns slot times without a date (e.g. `17:00`), so [end] is
/// moved to the next day when it is not after [start] (a slot that crosses
/// midnight, e.g. `23:00 - 00:00`).
class SlotInterval {
  final DateTime start;
  final DateTime end;

  const SlotInterval(this.start, this.end);

  /// Half-open overlap: `[start, end)`. Adjacent slots (one ends exactly when
  /// the next starts) do not overlap.
  bool overlaps(SlotInterval other) => start.isBefore(other.end) && other.start.isBefore(end);
}

/// UX-only helpers for the booking slot grid. The backend stays the source of
/// truth: everything here only hides choices that would be rejected anyway.
class BookingSlotUtils {
  BookingSlotUtils._();

  static final RegExp _timePattern = RegExp(r'^(\d{1,2})(?::(\d{2}))?(?::\d{2})?\s*(AM|PM)?$');

  static const _arabicDigits = '٠١٢٣٤٥٦٧٨٩';

  /// Parses a slot time such as `17:00`, `17:00:00`, `5:00 PM` or `5:00 م`.
  /// Returns null when the format is not recognized.
  static ({int hour, int minute})? parseTime(String? raw) {
    if (raw == null) return null;
    var value = raw.trim();
    if (value.isEmpty) return null;
    for (var i = 0; i < _arabicDigits.length; i++) {
      value = value.replaceAll(_arabicDigits[i], '$i');
    }
    value = value.replaceAll('ص', 'AM').replaceAll('م', 'PM').toUpperCase();

    final match = _timePattern.firstMatch(value);
    if (match == null) return null;
    var hour = int.parse(match.group(1)!);
    final minuteText = match.group(2);
    final period = match.group(3);
    final minute = minuteText == null ? 0 : int.parse(minuteText);
    if (minute > 59) return null;
    if (period == null) {
      // 24-hour times need minutes ("17:00"), and a valid hour.
      if (minuteText == null || hour > 23) return null;
    } else {
      if (hour < 1 || hour > 12) return null;
      hour = hour % 12 + (period == 'PM' ? 12 : 0);
    }
    return (hour: hour, minute: minute);
  }

  /// Resolves a slot on [date] (only the calendar day of [date] is used).
  /// Returns null when either time cannot be parsed, or the slot has zero length.
  static SlotInterval? toInterval(DateTime date, String? startAt, String? endAt) {
    final start = parseTime(startAt);
    final end = parseTime(endAt);
    if (start == null || end == null) return null;
    final startDate = DateTime(date.year, date.month, date.day, start.hour, start.minute);
    var endDate = DateTime(date.year, date.month, date.day, end.hour, end.minute);
    if (endDate.isAtSameMomentAs(startDate)) return null;
    if (endDate.isBefore(startDate)) {
      endDate = endDate.add(const Duration(days: 1));
    }
    return SlotInterval(startDate, endDate);
  }

  /// True when the slot on [date] has already started at [now].
  /// Unparseable slots return false and are left for the backend to judge.
  static bool hasStarted(DateTime date, String? startAt, String? endAt, DateTime now) {
    final interval = toInterval(date, startAt, endAt);
    if (interval == null) return false;
    return !interval.start.isAfter(now);
  }

  /// True when [candidate] overlaps any of [selected] on the same [date].
  static bool overlapsAny(
    DateTime date,
    ({String? startAt, String? endAt}) candidate,
    Iterable<({String? startAt, String? endAt})> selected,
  ) {
    final interval = toInterval(date, candidate.startAt, candidate.endAt);
    if (interval == null) return false;
    for (final other in selected) {
      final otherInterval = toInterval(date, other.startAt, other.endAt);
      if (otherInterval != null && interval.overlaps(otherInterval)) {
        return true;
      }
    }
    return false;
  }

  static String formatSlot(String? startAt, String? endAt) {
    if (startAt == null || endAt == null) return '';
    return '$startAt - $endAt';
  }
}
