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
  final PriorityListData priorityList;
  final WinData win;
  final bool editable;

  DailyWinViewLoaded(
      this.date, this.today, this.priorityList, this.win, this.editable);
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
  final PriorityListData priorityList;
  final WinData win;

  EditWinRequested(this.date, this.today, this.priorityList, this.win);
}

class CancelEditingWinRequested implements Message {
  final DateTime date;
  final DateTime today;

  CancelEditingWinRequested(this.date, this.today);
}

class WinChangesConfirmed implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final WinData win;

  WinChangesConfirmed(this.date, this.today, this.priorityList, this.win);
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

class NavigateToPrioritiesRequested implements Message {
  final DateTime date;
  final DateTime today;

  NavigateToPrioritiesRequested(this.date, this.today);
}

class PrioritiesLoaded implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  PrioritiesLoaded(this.date, this.today, this.priorityList);
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

class ExitPrioritiesRequested implements Message {
  final DateTime date;
  final DateTime today;

  ExitPrioritiesRequested(this.date, this.today);
}

class EditPrioritiesRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  EditPrioritiesRequested(this.date, this.today, this.priorityList);
}

class PrioritiesReorderRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final PriorityData priority;
  final PriorityData exchangeWith;

  PrioritiesReorderRequested(this.date, this.today, this.priorityList,
      this.priority, this.exchangeWith);
}

class SaveChangesInPrioritiesRequested implements Message {
  final DateTime date;
  final PriorityListData priorityList;

  SaveChangesInPrioritiesRequested(this.date, this.priorityList);
}

class EditExistingPriorityRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final PriorityData priority;

  EditExistingPriorityRequested(
      this.date, this.today, this.priorityList, this.priority);
}

class EditNewPriorityRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  EditNewPriorityRequested(this.date, this.today, this.priorityList);
}

class NewPriorityCreated implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final PriorityData priority;

  NewPriorityCreated(this.date, this.today, this.priorityList, this.priority);
}

class DeletePriorityRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final PriorityData priority;

  DeletePriorityRequested(
      this.date, this.today, this.priorityList, this.priority);
}

class CancelEditingPrioritiesRequested implements Message {
  final DateTime date;
  final DateTime today;

  CancelEditingPrioritiesRequested(this.date, this.today);
}

class CancelEditingPriorityRequested implements Message {
  final DateTime date;
  final DateTime today;

  CancelEditingPriorityRequested(this.date, this.today);
}

class PrioritySaveRequested implements Message {
  final DateTime date;
  final PriorityListData priorityList;
  final PriorityData priority;

  PrioritySaveRequested(this.date, this.priorityList, this.priority);
}

class SavingPrioritiesFailed implements Message {
  final DateTime date;
  final PriorityListData priorityList;
  final String reason;

  SavingPrioritiesFailed(this.date, this.priorityList, this.reason);
}

class LinkWinToPriorities implements Message {
  final DateTime date;
  final DateTime today;
  final WinData win;
  final PriorityListData priorityList;

  LinkWinToPriorities(this.date, this.today, this.win, this.priorityList);
}

class ToggleWinPriority implements Message {
  final DateTime date;
  final DateTime today;
  final WinData win;
  final PriorityListData priorityList;
  final PriorityData priority;

  ToggleWinPriority(
      this.date, this.today, this.win, this.priorityList, this.priority);
}

class NavigateToWinListRequested implements Message {
  final DateTime date;
  final DateTime today;

  NavigateToWinListRequested(this.date, this.today);
}

class BackToDailyWinViewRequested implements Message {
  final DateTime date;
  final DateTime today;

  BackToDailyWinViewRequested(this.date, this.today);
}

class WinListFirstPageLoaded implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final DateTime from;
  final DateTime to;
  final List<WinOnDayData> wins;

  WinListFirstPageLoaded(
      this.date, this.today, this.priorityList, this.from, this.to, this.wins);
}

class WinListFirstPageLoadingFailed implements Message {
  final DateTime date;
  final DateTime today;
  final String reason;
  final DateTime from;
  final DateTime to;

  WinListFirstPageLoadingFailed(
      this.date, this.today, this.from, this.to, this.reason);
}

class WinListFirstPageReloadRequested implements Message {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;

  WinListFirstPageReloadRequested(this.date, this.today, this.from, this.to);
}

class LoadWinListNextPageRequested implements Message {}

class WinListNextPageLoaded implements Message {
  final List<WinOnDayData> wins;
  final DateTime from;
  final DateTime to;

  WinListNextPageLoaded(this.from, this.to, this.wins);
}

class WinListNextPageLoadingFailed implements Message {
  final String reason;

  WinListNextPageLoadingFailed(this.reason);
}

class NavigateToCalendarRequested implements Message {
  final DateTime date;
  final DateTime today;

  NavigateToCalendarRequested(this.date, this.today);
}

class CalendarViewNextPageRequested implements Message {}

class CalendarViewDaysWithWinsReceived implements Message {
  final DateTime month;
  final WinDaysData winDays;

  CalendarViewDaysWithWinsReceived(this.month, this.winDays);
}
