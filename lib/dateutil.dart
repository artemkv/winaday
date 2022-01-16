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

  var firstDayOfWeek = DateTime(date.year, date.month, date.day - goBack);
  return [
    DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day),
    DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day + 1),
    DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day + 2),
    DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day + 3),
    DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day + 4),
    DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day + 5),
    DateTime(firstDayOfWeek.year, firstDayOfWeek.month, firstDayOfWeek.day + 6),
  ];
}

extension DateFunctions on DateTime {
  bool isSameDate(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }

  bool isSameMonth(DateTime other) {
    return year == other.year && month == other.month;
  }

  String toCompact() {
    final DateFormat format = DateFormat('yyyyMMdd');
    return format.format(this);
  }

  DateTime prevDay() {
    return DateTime(year, month, day - 1);
  }

  DateTime nextDay() {
    return DateTime(year, month, day + 1);
  }

  DateTime prevWeek() {
    return DateTime(year, month, day - 7);
  }

  DateTime nextWeek() {
    return DateTime(year, month, day + 7);
  }
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

DateTime getNextMonth(DateTime date) {
  if (date.month < 12) {
    return DateTime(date.year, date.month + 1, 1);
  }
  return DateTime(date.year + 1, 1, 1);
}

DateTime getFirstDayOfMonth(DateTime date) {
  return DateTime(date.year, date.month, 1);
}

DateTime getLastDayOfMonth(DateTime date) {
  if (date.month < 12) {
    return DateTime(date.year, date.month + 1, 0);
  }
  return DateTime(date.year + 1, 1, 0);
}

int getDaysInInterval(DateTime from, DateTime to) {
  int count = 0;
  var day = from;
  while (day.isBefore(to) || day.isSameDate(to)) {
    count++;
    day = day.nextDay();
  }
  return count;
}
