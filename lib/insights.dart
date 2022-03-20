import 'package:flutter/material.dart';
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

  var counters = cnt.entries.toList();
  counters.sort((a, b) {
    if (a.value == b.value) {
      return a.key.compareTo(b.key);
    }
    return b.value.compareTo(a.value);
  });

  var days = {
    for (var c in counters)
      LabeledValue(getDayName(c.key), c.value / total * 100)
  }.toList();
  return days;
}

List<LabeledValue> getNoWinWeekDays(WinListShortData data) {
  Map<int, int> cnt = {};
  int total = 0;

  for (var x in data.items) {
    if (x.win.overallResult == OverallDayResult.couldNotGetWin) {
      var d = x.date.weekday;
      cnt[d] = (cnt[d] ?? 0) + 1;
      total++;
    }
  }

  var counters = cnt.entries.toList();
  counters.sort((a, b) {
    if (a.value == b.value) {
      return a.key.compareTo(b.key);
    }
    return b.value.compareTo(a.value);
  });

  var days = {
    for (var c in counters)
      LabeledValue(getDayName(c.key), c.value / total * 100)
  }.toList();
  return days;
}

class LabeledValue {
  final String label;
  final double value;
  final int color;

  LabeledValue(this.label, this.value, {this.color = 0});

  @override
  bool operator ==(Object other) {
    return other is LabeledValue &&
        label == other.label &&
        value == other.value &&
        color == other.color;
  }

  @override
  int get hashCode {
    return Object.hashAll([label, value, color]);
  }

  @override
  String toString() {
    return '$label: $value (color: $color)';
  }
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

List<LabeledValue> getAwesomePrioritiesWeighted(
    WinListShortData data, PriorityListData priorityList) {
  Map<String, int> awesomeCount = {};
  Map<String, int> totalCount = {};

  for (var x in data.items) {
    for (var p in x.win.priorities) {
      totalCount[p] = (totalCount[p] ?? 0) + 1;
    }
    if (x.win.overallResult == OverallDayResult.awesomeAchievement) {
      for (var p in x.win.priorities) {
        awesomeCount[p] = (awesomeCount[p] ?? 0) + 1;
      }
    }
  }

  var priorities = priorityList.items
      .map((p) => LabeledValue(
          p.text, (awesomeCount[p.id] ?? 0) / (totalCount[p.id] ?? 1) * 100,
          color: p.color))
      .where((v) => v.value > 0)
      .toList();
  priorities.sort((a, b) => b.value.compareTo(a.value));
  return priorities;
}

List<PriorityData> getMostPopularPriorityCombination(
    WinListShortData data, PriorityListData priorityList) {
  Map<Combination, int> cnt = {};

  for (var x in data.items) {
    var combinations = getCombinations(x.win.priorities);
    for (var c in combinations) {
      cnt[c] = (cnt[c] ?? 0) + 1;
    }
  }

  Map<String, PriorityData> priorities = {
    for (var p in priorityList.items) p.id: p
  };

  var combinationCounts = cnt.entries.toList();
  combinationCounts.sort((a, b) => b.value.compareTo(a.value));

  if (combinationCounts.isNotEmpty) {
    return combinationCounts.first.key
        .toList()
        .map((id) => priorities[id])
        .where((x) => x != null)
        .map((x) => x!)
        .toList();
  }

  return [];
}

@immutable
class Combination {
  final String a;
  final String b;

  const Combination(this.a, this.b);

  @override
  bool operator ==(Object other) {
    return other is Combination &&
        ((a == other.a && b == other.b) || (a == other.b && b == other.a));
  }

  @override
  int get hashCode {
    if (a.compareTo(b) <= 0) {
      return (a + b).hashCode;
    } else {
      return (b + a).hashCode;
    }
  }

  @override
  String toString() {
    return a + ',' + b;
  }

  List<String> toList() {
    if (a.compareTo(b) <= 0) {
      return [a, b];
    } else {
      return [b, a];
    }
  }
}

List<Combination> getCombinations(Set<String> s) {
  Set<Combination> cs = {};

  for (var a in s) {
    for (var b in s) {
      if (a != b) {
        var c = Combination(a, b);
        cs.add(c);
      }
    }
  }

  var csl = cs.toList();
  csl.sort((a, b) => a.toString().compareTo(b.toString()));
  return csl;
}
