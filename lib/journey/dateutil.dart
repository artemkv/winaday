extension DateFunctions on DateTime {
  bool isSameYear(DateTime other) {
    return year == other.year;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
