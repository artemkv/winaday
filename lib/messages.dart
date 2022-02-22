// Should all be immutable classes and no logic!

import 'package:flutter/material.dart';

import 'domain.dart';

@immutable
abstract class Message {}

@immutable
class ReInitializationRequested implements Message {}

@immutable
class AppInitializedNotSignedIn implements Message {}

@immutable
class AppInitializationFailed implements Message {
  final String reason;

  const AppInitializationFailed(this.reason);
}

@immutable
class UserConsentUpdated implements Message {
  final bool privacyPolicyAccepted;
  final bool personalDataProcessingAccepted;

  const UserConsentUpdated(
      this.privacyPolicyAccepted, this.personalDataProcessingAccepted);
}

@immutable
class SignInRequested implements Message {}

@immutable
class UserSignedIn implements Message {
  final DateTime today;

  const UserSignedIn(this.today);
}

@immutable
class SignInFailed implements Message {
  final String reason;

  const SignInFailed(this.reason);
}

@immutable
class SignOutRequested implements Message {}

@immutable
class UserSignedOut implements Message {}

@immutable
class DailyWinViewInitialDataLoaded implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final List<WinOnDayData> wins;
  final WinData win;
  final bool editable;

  const DailyWinViewInitialDataLoaded(this.date, this.today, this.priorityList,
      this.wins, this.win, this.editable);
}

@immutable
class DailyWinViewLoaded implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final WinData win;
  final bool editable;
  final bool askForReview;

  const DailyWinViewLoaded(this.date, this.today, this.priorityList, this.win,
      this.editable, this.askForReview);
}

@immutable
class DailyWinViewLoadingFailed implements Message {
  final DateTime date;
  final DateTime today;
  final String reason;

  const DailyWinViewLoadingFailed(this.date, this.today, this.reason);
}

@immutable
class DailyWinViewReloadRequested implements Message {
  final DateTime date;
  final DateTime today;

  const DailyWinViewReloadRequested(this.date, this.today);
}

@immutable
class MoveToNextDay implements Message {
  final DateTime date;
  final DateTime today;

  const MoveToNextDay(this.date, this.today);
}

@immutable
class MoveToPrevDay implements Message {
  final DateTime date;
  final DateTime today;

  const MoveToPrevDay(this.date, this.today);
}

@immutable
class MoveToNextWeek implements Message {
  final DateTime date;
  final DateTime today;

  const MoveToNextWeek(this.date, this.today);
}

@immutable
class MoveToPrevWeek implements Message {
  final DateTime date;
  final DateTime today;

  const MoveToPrevWeek(this.date, this.today);
}

@immutable
class MoveToDay implements Message {
  final DateTime date;
  final DateTime today;

  const MoveToDay(this.date, this.today);
}

@immutable
class EditWinRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final WinData win;

  const EditWinRequested(this.date, this.today, this.priorityList, this.win);
}

@immutable
class CancelEditingWinRequested implements Message {
  final DateTime date;
  final DateTime today;

  const CancelEditingWinRequested(this.date, this.today);
}

@immutable
class WinChangesConfirmed implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final WinData win;

  const WinChangesConfirmed(this.date, this.today, this.priorityList, this.win);
}

@immutable
class WinSaveRequested implements Message {
  final DateTime date;
  final WinData win;

  const WinSaveRequested(this.date, this.win);
}

@immutable
class WinSaved implements Message {
  final DateTime date;
  final DateTime today;

  const WinSaved(this.date, this.today);
}

@immutable
class SavingWinFailed implements Message {
  final DateTime date;
  final WinData win;
  final String reason;

  const SavingWinFailed(this.date, this.win, this.reason);
}

@immutable
class NavigateToPrioritiesRequested implements Message {
  final DateTime date;
  final DateTime today;

  const NavigateToPrioritiesRequested(this.date, this.today);
}

@immutable
class PrioritiesLoaded implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  const PrioritiesLoaded(this.date, this.today, this.priorityList);
}

@immutable
class PrioritiesLoadingFailed implements Message {
  final DateTime date;
  final DateTime today;
  final String reason;

  const PrioritiesLoadingFailed(this.date, this.today, this.reason);
}

@immutable
class PrioritiesReloadRequested implements Message {
  final DateTime date;
  final DateTime today;

  const PrioritiesReloadRequested(this.date, this.today);
}

@immutable
class ExitPrioritiesRequested implements Message {
  final DateTime date;
  final DateTime today;

  const ExitPrioritiesRequested(this.date, this.today);
}

@immutable
class EditPrioritiesRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  const EditPrioritiesRequested(this.date, this.today, this.priorityList);
}

@immutable
class PrioritiesReorderRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final PriorityData priority;
  final PriorityData exchangeWith;

  const PrioritiesReorderRequested(this.date, this.today, this.priorityList,
      this.priority, this.exchangeWith);
}

@immutable
class SaveChangesInPrioritiesRequested implements Message {
  final DateTime date;
  final PriorityListData priorityList;

  const SaveChangesInPrioritiesRequested(this.date, this.priorityList);
}

@immutable
class EditExistingPriorityRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final PriorityData priority;

  const EditExistingPriorityRequested(
      this.date, this.today, this.priorityList, this.priority);
}

@immutable
class EditNewPriorityRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  const EditNewPriorityRequested(this.date, this.today, this.priorityList);
}

@immutable
class NewPriorityCreated implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final PriorityData priority;

  const NewPriorityCreated(
      this.date, this.today, this.priorityList, this.priority);
}

@immutable
class DeletePriorityRequested implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final PriorityData priority;

  const DeletePriorityRequested(
      this.date, this.today, this.priorityList, this.priority);
}

@immutable
class CancelEditingPrioritiesRequested implements Message {
  final DateTime date;
  final DateTime today;

  const CancelEditingPrioritiesRequested(this.date, this.today);
}

@immutable
class CancelEditingPriorityRequested implements Message {
  final DateTime date;
  final DateTime today;

  const CancelEditingPriorityRequested(this.date, this.today);
}

@immutable
class PrioritySaveRequested implements Message {
  final DateTime date;
  final PriorityListData priorityList;
  final PriorityData priority;

  const PrioritySaveRequested(this.date, this.priorityList, this.priority);
}

@immutable
class SavingPrioritiesFailed implements Message {
  final DateTime date;
  final PriorityListData priorityList;
  final String reason;

  const SavingPrioritiesFailed(this.date, this.priorityList, this.reason);
}

@immutable
class LinkWinToPriorities implements Message {
  final DateTime date;
  final DateTime today;
  final WinData win;
  final PriorityListData priorityList;

  const LinkWinToPriorities(this.date, this.today, this.win, this.priorityList);
}

@immutable
class ToggleWinPriority implements Message {
  final DateTime date;
  final DateTime today;
  final WinData win;
  final PriorityListData priorityList;
  final PriorityData priority;

  const ToggleWinPriority(
      this.date, this.today, this.win, this.priorityList, this.priority);
}

@immutable
class NavigateToWinListRequested implements Message {
  final DateTime date;
  final DateTime today;

  const NavigateToWinListRequested(this.date, this.today);
}

@immutable
class BackToDailyWinViewRequested implements Message {
  final DateTime date;
  final DateTime today;

  const BackToDailyWinViewRequested(this.date, this.today);
}

@immutable
class WinListFirstPageLoaded implements Message {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final DateTime from;
  final DateTime to;
  final List<WinOnDayData> wins;

  const WinListFirstPageLoaded(
      this.date, this.today, this.priorityList, this.from, this.to, this.wins);
}

@immutable
class WinListFirstPageLoadingFailed implements Message {
  final DateTime date;
  final DateTime today;
  final String reason;
  final DateTime from;
  final DateTime to;

  const WinListFirstPageLoadingFailed(
      this.date, this.today, this.from, this.to, this.reason);
}

@immutable
class WinListFirstPageReloadRequested implements Message {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;

  const WinListFirstPageReloadRequested(
      this.date, this.today, this.from, this.to);
}

@immutable
class LoadWinListNextPageRequested implements Message {}

@immutable
class WinListRetryLoadNextPageRequested implements Message {}

@immutable
class WinListNextPageLoaded implements Message {
  final List<WinOnDayData> wins;
  final DateTime from;
  final DateTime to;

  const WinListNextPageLoaded(this.from, this.to, this.wins);
}

@immutable
class WinListNextPageLoadingFailed implements Message {
  final String reason;

  const WinListNextPageLoadingFailed(this.reason);
}

@immutable
class NavigateToCalendarRequested implements Message {
  final DateTime date;
  final DateTime today;

  const NavigateToCalendarRequested(this.date, this.today);
}

@immutable
class CalendarViewNextPageRequested implements Message {}

@immutable
class CalendarViewDaysWithWinsReceived implements Message {
  final DateTime month;
  final WinDaysData winDays;

  const CalendarViewDaysWithWinsReceived(this.month, this.winDays);
}

@immutable
class NavigateToStatsRequested implements Message {
  final DateTime date;
  final DateTime today;

  const NavigateToStatsRequested(this.date, this.today);
}

@immutable
class StatsLoaded implements Message {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;
  final PriorityListData priorityList;
  final WinListShortData stats;

  const StatsLoaded(
      this.date, this.today, this.from, this.to, this.priorityList, this.stats);
}

@immutable
class StatsLoadingFailed implements Message {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;
  final String reason;

  const StatsLoadingFailed(
      this.date, this.today, this.from, this.to, this.reason);
}

@immutable
class StatsReloadRequested implements Message {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;

  const StatsReloadRequested(this.date, this.today, this.from, this.to);
}

@immutable
class ExitStatsRequested implements Message {
  final DateTime date;
  final DateTime today;

  const ExitStatsRequested(this.date, this.today);
}

@immutable
class StatsTogglePieHistogramsWins implements Message {}

@immutable
class StatsTogglePieHistogramsPriorities implements Message {}

@immutable
class MoveToNextMonthStats implements Message {
  final DateTime date;
  final DateTime today;

  const MoveToNextMonthStats(this.date, this.today);
}

@immutable
class MoveToPrevMonthStats implements Message {
  final DateTime date;
  final DateTime today;

  const MoveToPrevMonthStats(this.date, this.today);
}

@immutable
class AgreedOnLeavingFeedback implements Message {}

@immutable
class RejectedLeavingFeedback implements Message {}

@immutable
class NavigateToInsightsRequested implements Message {
  final DateTime date;
  final DateTime today;

  const NavigateToInsightsRequested(this.date, this.today);
}

@immutable
class InsightsLoaded implements Message {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;
  final PriorityListData priorityList;
  final WinListShortData data;

  const InsightsLoaded(
      this.date, this.today, this.from, this.to, this.priorityList, this.data);
}

@immutable
class InsightsLoadingFailed implements Message {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;
  final String reason;

  const InsightsLoadingFailed(
      this.date, this.today, this.from, this.to, this.reason);
}

@immutable
class InsightsReloadRequested implements Message {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;

  const InsightsReloadRequested(this.date, this.today, this.from, this.to);
}

@immutable
class ExitInsightsRequested implements Message {
  final DateTime date;
  final DateTime today;

  const ExitInsightsRequested(this.date, this.today);
}
