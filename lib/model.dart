// Should all be immutable classes and no logic!
// No side effects allowed!

import 'domain.dart';

abstract class Model {
  static Model getInitialModel() {
    return ApplicationNotInitializedModel();
  }
}

class ApplicationNotInitializedModel extends Model {}

class ApplicationFailedToInitializeModel extends Model {
  final String reason;

  ApplicationFailedToInitializeModel(this.reason);
}

class UserFailedToSignInModel extends Model {
  final String reason;

  UserFailedToSignInModel(this.reason);
}

class UserNotSignedInModel extends Model {}

class SignInInProgressModel extends Model {}

class SignOutInProgressModel extends Model {}

class DailyWinLoadingModel extends Model {
  final DateTime date;

  DailyWinLoadingModel(this.date);
}

class DailyWinFailedToLoadModel extends Model {
  final DateTime date;
  final String reason;

  DailyWinFailedToLoadModel(this.date, this.reason);
}

class DailyWinModel extends Model {
  final DateTime date;
  final WinData win;

  DailyWinModel(this.date, this.win);
}

class WinEditorModel extends Model {
  final DateTime date;
  final WinData win;

  WinEditorModel(this.date, this.win);
}

class WinEditorSavingModel extends Model {
  final DateTime date;

  WinEditorSavingModel(this.date);
}

class WinEditorFailedToSaveModel extends Model {
  final DateTime date;
  final WinData win;
  final String reason;

  WinEditorFailedToSaveModel(this.date, this.win, this.reason);
}
