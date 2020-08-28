part of '../../pluto_grid.dart';

class DatetimeHelper {
  static List<String> getDaysInBetween(
    DateTime startDate,
    DateTime endDate, {
    format: 'yyyy-MM-dd',
  }) {
    List<String> days = [];
    for (int i = 0; i <= endDate.difference(startDate).inDays; i++) {
      days.add(
          intl.DateFormat(format).format(startDate.add(Duration(days: i))));
    }
    return days;
  }
}
