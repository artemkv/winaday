import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

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

// weekday:
// M T W T F S S
// 1 2 3 4 5 6 7
//
// firstDayOfWeekIdx:
// M T W T F S S
// 1 2 3 4 5 6 0
List<DateTime> getCurrentWeek(BuildContext context, DateTime date) {
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

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }
}

String toCompact(DateTime date) {
  final DateFormat format = DateFormat('yyyyMMdd');
  return format.format(date);
}

DateTime fromCompact(String date) {
  // Apparently, without any separators, format parses the whole value as a year
  String preFormatted =
      "${date.substring(0, 4)}-${date.substring(4, 6)}-${date.substring(6, 8)}";
  final DateFormat format = DateFormat('yyyy-MM-dd');
  return format.parse(preFormatted);
}

DateTime getPreviousMonth(DateTime date) {
  if (date.month > 1) {
    return DateTime(date.year, date.month - 1, 1);
  }
  return DateTime(date.year - 1, 12, 1);
}

DateTime getFirstDayOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

// TODO: unit-test
DateTime getLastDayOfMonth(DateTime date) {
  if (date.month < 12) {
    return DateTime(date.year, date.month + 1, 1)
        .subtract(const Duration(days: 1));
  }
  return DateTime(date.year + 1, 1, 1).subtract(const Duration(days: 1));
}
