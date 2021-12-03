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

  WinData.fromJson(Map<String, dynamic> json)
      : text = json['text'],
        overallResult = json['overall'];

  Map<String, dynamic> toJson() => {'text': text, 'overall': overallResult};
}
