// These should be all immutable containers, no logic

import 'package:flutter/foundation.dart';
import 'dateutil.dart';

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

  bool isWin() {
    return overallResult == OverallDayResult.gotMyWin ||
        overallResult == OverallDayResult.awesomeAchievement;
  }
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

  @override
  String toString() {
    return '$id($text)';
  }
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

@immutable
class WinShortData {
  final int overallResult;
  final Set<String> priorities;

  const WinShortData(this.overallResult, this.priorities);

  WinShortData.empty()
      : overallResult = OverallDayResult.noWinYet,
        priorities = <String>{};

  WinShortData.fromJson(Map<String, dynamic> json)
      : overallResult = json['overall'],
        priorities = json['priorities'] != null
            ? json['priorities'].cast<String>().toSet()
            : <String>{};

  @override
  bool operator ==(Object other) {
    return other is WinShortData &&
        overallResult == other.overallResult &&
        priorities == other.priorities;
  }

  @override
  int get hashCode {
    return Object.hashAll([overallResult, priorities]);
  }
}

@immutable
class WinOnDayShortData {
  final DateTime date;
  final WinShortData win;

  const WinOnDayShortData(this.date, this.win);

  WinOnDayShortData.fromJson(Map<String, dynamic> json)
      : date = fromCompact(json['date']),
        win = WinShortData.fromJson(json['win']);

  @override
  bool operator ==(Object other) {
    return other is WinOnDayShortData && date == other.date && win == other.win;
  }

  @override
  int get hashCode {
    return Object.hashAll([date, win]);
  }
}

@immutable
class WinListShortData {
  final List<WinOnDayShortData> items;

  const WinListShortData(this.items);

  WinListShortData.empty() : items = List.empty();

  WinListShortData.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List)
            .map((x) => WinOnDayShortData.fromJson(x))
            .toList();

  @override
  bool operator ==(Object other) {
    return other is WinListShortData && listEquals(items, other.items);
  }

  @override
  int get hashCode {
    return Object.hashAll(items);
  }
}

class ReviewPanelState {
  static const askIfLikesTheApp = 0;
  static const likesTheApp = 1;
  static const doesNotLikeTheApp = 2;
}

enum StatsPeriod { month, year }

@immutable
class AppSettings {
  final bool showNotifications;
  final int notificationTimeHour;
  final int notificationTimeMinute;

  const AppSettings(this.showNotifications, this.notificationTimeHour,
      this.notificationTimeMinute);

  const AppSettings.empty()
      : showNotifications = false,
        notificationTimeHour = 0,
        notificationTimeMinute = 0;
}
