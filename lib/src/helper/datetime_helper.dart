part of '../../pluto_grid.dart';

class DatetimeHelper {
  static List<DateTime> getDaysInBetween(DateTime startDate, DateTime endDate) {
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
}
