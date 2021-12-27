// These should be all immutable containers, no logic

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

  WinData(this.text, this.overallResult);

  WinData.empty()
      : text = "",
        overallResult = OverallDayResult.noWinYet;

  WinData.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        overallResult = json['overall'];

  Map<String, dynamic> toJson() => {'text': text, 'overall': overallResult};
}

class PriorityListData {
  final List<PriorityData> items;

  PriorityListData(this.items);

  PriorityListData.empty() : items = List.empty();

  PriorityListData.fromJson(Map<String, dynamic> json)
      : items = (json['items'] as List)
            .map((x) => PriorityData.fromJson(x))
            .toList();
}

class PriorityData {
  final String text;

  PriorityData(this.text);

  PriorityData.empty() : text = "";

  PriorityData.fromJson(Map<String, dynamic> json) : text = json['text'];

  Map<String, dynamic> toJson() => {'text': text};
}
