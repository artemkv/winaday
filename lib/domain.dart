// These should be all immutable containers, no logic

import 'package:flutter/material.dart';
import 'package:winaday/dateutil.dart';

class OverallDayResult {
  static const noWinYet = 0;
  static const gotMyWin = 1;
  static const couldNotGetWin = 2;
  static const grind = 3;
  static const awesomeAchievement = 4;
}

@immutable
class WinData {
  final String text;
  final int overallResult;
  final Set<String> priorities;

  const WinData(this.text, this.overallResult, this.priorities);

  WinData.empty()
      : text = "",
        overallResult = OverallDayResult.noWinYet,
        priorities = <String>{};

  WinData.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        overallResult = json['overall'],
        priorities = json['priorities'] != null
            ? json['priorities'].cast<String>().toSet()
            : <String>{};

  Map<String, dynamic> toJson() => {
        'text': text,
        'overall': overallResult,
        'priorities': priorities.toList()
      };
}

@immutable
class PriorityListData {
  final List<PriorityData> items;

  const PriorityListData(this.items);

  PriorityListData.empty() : items = List.empty();

  PriorityListData.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List)
            .map((x) => PriorityData.fromJson(x))
            .toList();

  Map<String, dynamic> toJson() =>
      {'items': items.map((i) => i.toJson()).toList()};
}

@immutable
class PriorityData {
  final String id;
  final String text;
  final int color;
  final bool deleted;

  const PriorityData(this.id, this.text, this.color, this.deleted);

  PriorityData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        color = json['color'],
        deleted = json['deleted'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'color': color, 'deleted': deleted};
}

@immutable
class WinListData {
  final List<WinOnDayData> items;

  const WinListData(this.items);

  WinListData.empty() : items = List.empty();

  WinListData.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List)
            .map((x) => WinOnDayData.fromJson(x))
            .toList();
}

@immutable
class WinOnDayData {
  final DateTime date;
  final WinData win;

  const WinOnDayData(this.date, this.win);

  WinOnDayData.fromJson(Map<String, dynamic> json)
      : date = fromCompact(json['date']),
        win = WinData.fromJson(json['win']);
}

@immutable
class WinDaysData {
  final Set<String> items;

  const WinDaysData(this.items);

  WinDaysData.empty() : items = <String>{};

  WinDaysData.fromJson(Map<String, dynamic> json)
      : items = json['items'].cast<String>().toSet();
}
