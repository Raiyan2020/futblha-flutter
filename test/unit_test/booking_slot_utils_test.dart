import 'package:flutter_test/flutter_test.dart';
import 'package:futblha/presentation/pages/playgrounds/utils/booking_slot_utils.dart';

void main() {
  final day = DateTime(2026, 10, 15);

  SlotInterval interval(String start, String end) => BookingSlotUtils.toInterval(day, start, end)!;

  group('parseTime', () {
    test('parses 24h, seconds, 12h and Arabic formats', () {
      expect(BookingSlotUtils.parseTime('17:00'), (hour: 17, minute: 0));
      expect(BookingSlotUtils.parseTime('17:30:00'), (hour: 17, minute: 30));
      expect(BookingSlotUtils.parseTime('5:00 PM'), (hour: 17, minute: 0));
      expect(BookingSlotUtils.parseTime('05:00 pm'), (hour: 17, minute: 0));
      expect(BookingSlotUtils.parseTime('12:00 AM'), (hour: 0, minute: 0));
      expect(BookingSlotUtils.parseTime('٥:٠٠ م'), (hour: 17, minute: 0));
      expect(BookingSlotUtils.parseTime('٩:٣٠ ص'), (hour: 9, minute: 30));
    });

    test('returns null for missing or malformed values', () {
      expect(BookingSlotUtils.parseTime(null), isNull);
      expect(BookingSlotUtils.parseTime(''), isNull);
      expect(BookingSlotUtils.parseTime('soon'), isNull);
      expect(BookingSlotUtils.parseTime('25:00'), isNull);
    });
  });

  group('toInterval', () {
    test('resolves times on the booking date', () {
      final i = interval('17:00', '18:00');
      expect(i.start, DateTime(2026, 10, 15, 17));
      expect(i.end, DateTime(2026, 10, 15, 18));
    });

    test('a slot crossing midnight ends on the next day', () {
      final i = interval('23:00', '00:00');
      expect(i.start, DateTime(2026, 10, 15, 23));
      expect(i.end, DateTime(2026, 10, 16));
    });

    test('zero-length or unparseable slots are rejected', () {
      expect(BookingSlotUtils.toInterval(day, '17:00', '17:00'), isNull);
      expect(BookingSlotUtils.toInterval(day, 'x', '18:00'), isNull);
      expect(BookingSlotUtils.toInterval(day, '17:00', null), isNull);
    });
  });

  group('overlap (existing 17:00-18:00)', () {
    final existing = interval('17:00', '18:00');

    test('exact same time conflicts', () {
      expect(interval('17:00', '18:00').overlaps(existing), isTrue);
    });

    test('partial overlap at the end conflicts', () {
      expect(interval('17:30', '18:30').overlaps(existing), isTrue);
    });

    test('partial overlap at the start conflicts', () {
      expect(interval('16:30', '17:30').overlaps(existing), isTrue);
    });

    test('contained inside conflicts', () {
      expect(interval('17:15', '17:45').overlaps(existing), isTrue);
    });

    test('containing the existing booking conflicts', () {
      expect(interval('16:00', '19:00').overlaps(existing), isTrue);
    });

    test('adjacent after (starts when it ends) is allowed', () {
      expect(interval('18:00', '19:00').overlaps(existing), isFalse);
    });

    test('adjacent before (ends when it starts) is allowed', () {
      expect(interval('16:00', '17:00').overlaps(existing), isFalse);
    });

    test('overlap check is symmetric', () {
      final a = interval('17:30', '18:30');
      expect(a.overlaps(existing), existing.overlaps(a));
    });

    test('a midnight-crossing slot overlaps a late slot', () {
      expect(interval('23:00', '01:00').overlaps(interval('23:30', '00:00')), isTrue);
      expect(interval('22:00', '23:00').overlaps(interval('23:00', '00:00')), isFalse);
    });
  });

  group('overlapsAny', () {
    test('detects a conflict with any selected slot', () {
      final selected = [
        (startAt: '16:00' as String?, endAt: '17:00' as String?),
        (startAt: '19:00' as String?, endAt: '20:00' as String?),
      ];
      expect(
        BookingSlotUtils.overlapsAny(day, (startAt: '19:30', endAt: '20:30'), selected),
        isTrue,
      );
      expect(
        BookingSlotUtils.overlapsAny(day, (startAt: '17:00', endAt: '18:00'), selected),
        isFalse,
      );
    });
  });

  group('hasStarted', () {
    final now = DateTime(2026, 10, 15, 17, 30);

    test('earlier slots today have started', () {
      expect(BookingSlotUtils.hasStarted(day, '16:00', '17:00', now), isTrue);
    });

    test('a slot already in progress has started', () {
      expect(BookingSlotUtils.hasStarted(day, '17:00', '18:00', now), isTrue);
    });

    test('a slot starting exactly now has started', () {
      expect(BookingSlotUtils.hasStarted(day, '17:30', '18:30', now), isTrue);
    });

    test('later slots today have not started', () {
      expect(BookingSlotUtils.hasStarted(day, '18:00', '19:00', now), isFalse);
    });

    test('slots on a future date have not started', () {
      expect(BookingSlotUtils.hasStarted(DateTime(2026, 10, 16), '08:00', '09:00', now), isFalse);
    });

    test('unparseable slots are left to the backend', () {
      expect(BookingSlotUtils.hasStarted(day, 'x', 'y', now), isFalse);
    });
  });
}
