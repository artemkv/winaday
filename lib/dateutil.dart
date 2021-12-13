import 'package:flutter/material.dart';

const monthNames = <String>[
  "January",
  "February",
  "March",
  "April",
  "May",
  "June",
  "July",
  "August",
  "September",
  "October",
  "November",
  "December"
];

String getDayString(DateTime date) {
  return '${monthNames[date.month - 1]} ${date.year}';
}

List<DateTime> getCurrentWeek(
    BuildContext context, DateTime date, DateTime today) {
  var firstDayOfWeekIdx = MaterialLocalizations.of(context).firstDayOfWeekIndex;
  if (firstDayOfWeekIdx > date.weekday) {
    firstDayOfWeekIdx -= 7;
  }
  var goBack = date.weekday - firstDayOfWeekIdx;
  if (goBack >= 7) {
    goBack -= 7;
  }

  var firstDayOfWeek = date.subtract(Duration(days: goBack));
  return [
    firstDayOfWeek.add(const Duration(days: 0)),
    firstDayOfWeek.add(const Duration(days: 1)),
    firstDayOfWeek.add(const Duration(days: 2)),
    firstDayOfWeek.add(const Duration(days: 3)),
    firstDayOfWeek.add(const Duration(days: 4)),
    firstDayOfWeek.add(const Duration(days: 5)),
    firstDayOfWeek.add(const Duration(days: 6))
  ];
}

extension DateOnlyCompare on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}
