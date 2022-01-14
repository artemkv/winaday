// These should be all immutable containers, no logic

import 'package:winaday/dateutil.dart';

class OverallDayResult {
  static const noWinYet = 0;
  static const gotMyWin = 1;
  static const couldNotGetWin = 2;
  static const grind = 3;
  static const awesomeAchievement = 4;
}

class WinData {
  final String text;
  final int overallResult;
  final Set<String> priorities;

  WinData(this.text, this.overallResult, this.priorities);

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

class PriorityListData {
  final List<PriorityData> items;

  PriorityListData(this.items);

  PriorityListData.empty() : items = List.empty();

  PriorityListData.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List)
            .map((x) => PriorityData.fromJson(x))
            .toList();

  Map<String, dynamic> toJson() =>
      {'items': items.map((i) => i.toJson()).toList()};
}

class PriorityData {
  final String id;
  final String text;
  final int color;
  final bool deleted;

  PriorityData(this.id, this.text, this.color, this.deleted);

  PriorityData.fromJson(Map<String, dynamic> json)
      : id = json['id'],
        text = json['text'],
        color = json['color'],
        deleted = json['deleted'];

  Map<String, dynamic> toJson() =>
      {'id': id, 'text': text, 'color': color, 'deleted': deleted};
}

class WinListData {
  final List<WinOnDayData> items;

  WinListData(this.items);

  WinListData.empty() : items = List.empty();

  WinListData.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List)
            .map((x) => WinOnDayData.fromJson(x))
            .toList();
}

class WinOnDayData {
  final DateTime date;
  final WinData win;

  WinOnDayData(this.date, this.win);

  WinOnDayData.fromJson(Map<String, dynamic> json)
      : date = fromCompact(json['date']),
        win = WinData.fromJson(json['win']);
}

class WinDaysData {
  final Set<String> items;

  WinDaysData(this.items);

  WinDaysData.empty() : items = <String>{};

  WinDaysData.fromJson(Map<String, dynamic> json)
      : items = json['items'].cast<String>().toSet();
}
