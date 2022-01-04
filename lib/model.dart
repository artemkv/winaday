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

class UserNotSignedInModel extends Model {
  final bool privacyPolicyAccepted;
  final bool personalDataProcessingAccepted;

  UserNotSignedInModel(
      this.privacyPolicyAccepted, this.personalDataProcessingAccepted);
}

class SignInInProgressModel extends Model {}

class SignOutInProgressModel extends Model {}

class DailyWinLoadingModel extends Model {
  final DateTime date;
  final DateTime today;

  DailyWinLoadingModel(this.date, this.today);
}

class DailyWinFailedToLoadModel extends Model {
  final DateTime date;
  final DateTime today;
  final String reason;

  DailyWinFailedToLoadModel(this.date, this.today, this.reason);
}

class DailyWinModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final WinData win;
  final bool editable;

  DailyWinModel(
      this.date, this.today, this.priorityList, this.win, this.editable);
}

class WinEditorModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final WinData win;

  WinEditorModel(this.date, this.today, this.priorityList, this.win);
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

class PrioritiesLoadingModel extends Model {
  final DateTime date;
  final DateTime today;

  PrioritiesLoadingModel(this.date, this.today);
}

class PrioritiesFailedToLoadModel extends Model {
  final DateTime date;
  final DateTime today;
  final String reason;

  PrioritiesFailedToLoadModel(this.date, this.today, this.reason);
}

class PrioritiesModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final bool canAddMore;

  PrioritiesModel(this.date, this.today, this.priorityList, this.canAddMore);
}

class EditPrioritiesModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  EditPrioritiesModel(this.date, this.today, this.priorityList);
}

class CreatingNewPriorityModel extends Model {
  final DateTime date;
  final DateTime today;

  CreatingNewPriorityModel(this.date, this.today);
}

class PriorityEditorModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final PriorityData priority;

  PriorityEditorModel(this.date, this.today, this.priorityList, this.priority);
}

class PrioritiesSavingModel extends Model {
  final DateTime date;

  PrioritiesSavingModel(this.date);
}

class PriorityEditorFailedToSaveModel extends Model {
  final DateTime date;
  final PriorityListData priorityList;
  final String reason;

  PriorityEditorFailedToSaveModel(this.date, this.priorityList, this.reason);
}

class EditWinPrioritiesModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final WinData win;

  EditWinPrioritiesModel(this.date, this.today, this.priorityList, this.win);
}
