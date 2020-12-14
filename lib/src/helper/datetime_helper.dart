import 'package:intl/intl.dart' as intl;

class DatetimeHelper {
  static List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
    if (endDate.isBefore(startDate)) {
      endDate = startDate;
    }

    List<DateTime> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(startDate.add(Duration(days: i)));
    }

    return days;
  }

  static DateTime moveToFirstWeekday(DateTime date) {
    if (date.weekday == DateTime.sunday) {
      return date;
    }

    return date.add(Duration(days: -date.weekday));
  }

  static DateTime moveToLastWeekday(DateTime date) {
    if (date.weekday == DateTime.saturday) {
      return date;
    }

    int moveCount =
        date.weekday == DateTime.sunday ? 6 : DateTime.saturday - date.weekday;

    return date.add(Duration(days: moveCount));
  }

  static DateTime parseOrNullWithFormat(String date, String format) {
    try {
      return intl.DateFormat(format).parseStrict(date);
    } catch (e) {
      return null;
    }
  }
}
