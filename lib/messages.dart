// Should all be immutable classes and no logic!

import 'domain.dart';

abstract class Message {}

class ReInitializationRequested implements Message {}

class AppInitializedNotSignedIn implements Message {}

class AppInitializationFailed implements Message {
  final String reason;

  AppInitializationFailed(this.reason);
}

class UserConsentUpdated implements Message {
  final bool privacyPolicyAccepted;
  final bool personalDataProcessingAccepted;

  UserConsentUpdated(
      this.privacyPolicyAccepted, this.personalDataProcessingAccepted);
}

class SignInRequested implements Message {}

class UserSignedIn implements Message {
  final DateTime today;

  UserSignedIn(this.today);
}

class SignInFailed implements Message {
  final String reason;

  SignInFailed(this.reason);
}

class SignOutRequested implements Message {}

class UserSignedOut implements Message {}

class DailyWinViewLoaded implements Message {
  final DateTime date;
  final DateTime today;
  final WinData win;
  final bool editable;

  DailyWinViewLoaded(this.date, this.today, this.win, this.editable);
}

class DailyWinViewLoadingFailed implements Message {
  final DateTime date;
  final DateTime today;
  final String reason;

  DailyWinViewLoadingFailed(this.date, this.today, this.reason);
}

class DailyWinViewReloadRequested implements Message {
  final DateTime date;
  final DateTime today;

  DailyWinViewReloadRequested(this.date, this.today);
}

class MoveToNextDay implements Message {
  final DateTime date;
  final DateTime today;

  MoveToNextDay(this.date, this.today);
}

class MoveToPrevDay implements Message {
  final DateTime date;
  final DateTime today;

  MoveToPrevDay(this.date, this.today);
}

class MoveToNextWeek implements Message {
  final DateTime date;
  final DateTime today;

  MoveToNextWeek(this.date, this.today);
}

class MoveToPrevWeek implements Message {
  final DateTime date;
  final DateTime today;

  MoveToPrevWeek(this.date, this.today);
}

class MoveToDay implements Message {
  final DateTime date;
  final DateTime today;

  MoveToDay(this.date, this.today);
}

class EditWinRequested implements Message {
  final DateTime date;
  final DateTime today;
  final WinData win;

  EditWinRequested(this.date, this.today, this.win);
}

class CancelEditingWinRequested implements Message {
  final DateTime date;
  final DateTime today;

  CancelEditingWinRequested(this.date, this.today);
}

class WinSaveRequested implements Message {
  final DateTime date;
  final WinData win;

  WinSaveRequested(this.date, this.win);
}

class WinSaved implements Message {
  final DateTime date;
  final DateTime today;

  WinSaved(this.date, this.today);
}

class SavingWinFailed implements Message {
  final DateTime date;
  final WinData win;
  final String reason;

  SavingWinFailed(this.date, this.win, this.reason);
}

class EditPrioritiesRequested implements Message {
  final DateTime date;
  final DateTime today;

  EditPrioritiesRequested(this.date, this.today);
}

class PrioritiesLoaded implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  PrioritiesLoaded(this.date, this.today, this.priorityList);
}

class DoneEditingPriorities implements Message {
  final DateTime date;
  final DateTime today;

  DoneEditingPriorities(this.date, this.today);
}

class PrioritiesLoadingFailed implements Message {
  final DateTime date;
  final DateTime today;
  final String reason;

  PrioritiesLoadingFailed(this.date, this.today, this.reason);
}

class PrioritiesReloadRequested implements Message {
  final DateTime date;
  final DateTime today;

  PrioritiesReloadRequested(this.date, this.today);
}

class EditExistingPriorityRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final int priorityIdx;

  EditExistingPriorityRequested(
      this.date, this.today, this.priorityList, this.priorityIdx);
}

class EditNewPriorityRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  EditNewPriorityRequested(this.date, this.today, this.priorityList);
}

class CancelEditingPriorityRequested implements Message {
  final DateTime date;
  final DateTime today;

  CancelEditingPriorityRequested(this.date, this.today);
}

class PrioritySaveRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final int priorityIdx;
  final PriorityData priority;

  PrioritySaveRequested(this.date, this.today, this.priorityList,
      this.priorityIdx, this.priority);
}
