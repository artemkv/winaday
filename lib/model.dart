// Should all be immutable classes and no logic!
// No side effects allowed!

abstract class Model {
  static Model getInitialModel() {
    return UserNotSignedInModel();
  }
}

class UserNotSignedInModel extends Model {}

class DailyWinLoadingModel extends Model {
  final DateTime date;

  DailyWinLoadingModel(this.date);
}

class DailyWinModel extends Model {
  final DateTime date;
  final String win;

  DailyWinModel(this.date, this.win);
}

class WinEditorModel extends Model {
  final DateTime date;
  final String win;

  WinEditorModel(this.date, this.win);
}

class WinEditorSavingModel extends Model {
  final DateTime date;

  WinEditorSavingModel(this.date);
}
