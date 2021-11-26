// Should all be immutable classes and no logic!

abstract class Model {
  static Model getInitialModel() {
    return DailyWinViewLoadingModel(DateTime.now());
  }
}

class DailyWinViewLoadingModel extends Model {
  final DateTime date;

  DailyWinViewLoadingModel(this.date);
}

class DailyWinViewModel extends Model {
  final DateTime date;
  final String win;

  DailyWinViewModel(this.date, this.win);
}

class WinEditorViewModel extends Model {
  final DateTime date;
  final String win;

  WinEditorViewModel(this.date, this.win);
}
