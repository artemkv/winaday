import 'package:winaday/dateutil.dart';

import 'domain.dart';

List<LabeledValue> getAwesomeWeekDays(WinListShortData data) {
  Map<int, int> cnt = {};
  int total = 0;

  for (var x in data.items) {
    if (x.win.overallResult == OverallDayResult.awesomeAchievement) {
      var d = x.date.weekday;
      cnt[d] = (cnt[d] ?? 0) + 1;
      total++;
    }
  }

  var days = {
    for (var e in cnt.entries)
      LabeledValue(getDayName(e.key), e.value / total * 100)
  }.toList();
  days.sort((a, b) => b.value.compareTo(a.value));
  return days;
}

class LabeledValue {
  final String label;
  final double value;
  final int color;

  LabeledValue(this.label, this.value, {this.color = 0});
}

List<LabeledValue> getAwesomePriorities(
    WinListShortData data, PriorityListData priorityList) {
  Map<String, int> cnt = {};
  int total = 0;

  for (var x in data.items) {
    if (x.win.overallResult == OverallDayResult.awesomeAchievement) {
      for (var p in x.win.priorities) {
        cnt[p] = (cnt[p] ?? 0) + 1;
        total++;
      }
    }
  }

  var priorities = priorityList.items
      .map((p) =>
          LabeledValue(p.text, (cnt[p.id] ?? 0) / total * 100, color: p.color))
      .where((v) => v.value > 0)
      .toList();
  priorities.sort((a, b) => b.value.compareTo(a.value));
  return priorities;
}

List<PriorityData> getMostPopularPriorityCombination(
    WinListShortData data, PriorityListData priorityList) {
  Map<Set<String>, int> cnt = {};

  for (var x in data.items) {
    for (var p1 in x.win.priorities) {
      for (var p2 in x.win.priorities) {
        if (p1 != p2) {
          var key = {p1, p2};
          cnt[key] = (cnt[key] ?? 0) + 1;
        }
      }
    }
  }

  Map<String, PriorityData> priorities = {
    for (var p in priorityList.items) p.id: p
  };

  var combinations = cnt.entries.toList();
  combinations.sort((a, b) => b.value.compareTo(a.value));

  if (combinations.isNotEmpty) {
    return combinations.first.key
        .toList()
        .map((id) => priorities[id])
        .where((x) => x != null)
        .map((x) => x!)
        .toList();
  }

  return [];
}
