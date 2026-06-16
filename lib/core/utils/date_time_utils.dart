class DateTimeUtils {
  static int nowMillis() => DateTime.now().millisecondsSinceEpoch;

  static int startOfDayMillis(DateTime date) {
    return DateTime(date.year, date.month, date.day).millisecondsSinceEpoch;
  }

  static int endOfDayMillis(DateTime date) {
    return DateTime(date.year, date.month, date.day, 23, 59, 59, 999).millisecondsSinceEpoch;
  }

  static int startOfWeekMillis(DateTime date) {
    final monday = date.subtract(Duration(days: date.weekday - 1));
    return DateTime(monday.year, monday.month, monday.day).millisecondsSinceEpoch;
  }

  static int startOfMonthMillis(DateTime date) {
    return DateTime(date.year, date.month, 1).millisecondsSinceEpoch;
  }

  static DateRange today() {
    final now = DateTime.now();
    return DateRange(
      start: startOfDayMillis(now),
      end: endOfDayMillis(now),
    );
  }

  static DateRange thisWeek() {
    final now = DateTime.now();
    return DateRange(
      start: startOfWeekMillis(now),
      end: endOfDayMillis(now),
    );
  }

  static DateRange thisMonth() {
    final now = DateTime.now();
    final nextMonth = DateTime(now.year, now.month + 1, 1);
    return DateRange(
      start: startOfMonthMillis(now),
      end: nextMonth.millisecondsSinceEpoch - 1,
    );
  }
}

class DateRange {
  final int start;
  final int end;

  const DateRange({required this.start, required this.end});
}
