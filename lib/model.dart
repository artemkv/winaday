// Should all be immutable classes and no logic!
// No side effects allowed!

import 'package:flutter/cupertino.dart';

import 'domain.dart';

@immutable
abstract class Model {
  const Model();

  static Model getInitialModel() {
    return ApplicationNotInitializedModel();
  }
}

@immutable
class ApplicationNotInitializedModel extends Model {}

@immutable
class ApplicationFailedToInitializeModel extends Model {
  final String reason;

  const ApplicationFailedToInitializeModel(this.reason);
}

@immutable
class UserFailedToSignInModel extends Model {
  final String reason;

  const UserFailedToSignInModel(this.reason);
}

@immutable
class UserNotSignedInModel extends Model {
  final bool privacyPolicyAccepted;
  final bool personalDataProcessingAccepted;

  const UserNotSignedInModel(
      this.privacyPolicyAccepted, this.personalDataProcessingAccepted);
}

@immutable
class SignInInProgressModel extends Model {}

@immutable
class SignOutInProgressModel extends Model {}

@immutable
class DailyWinLoadingModel extends Model {
  final DateTime date;
  final DateTime today;
  final WinDaysData winDays;

  const DailyWinLoadingModel(this.date, this.today, this.winDays);
}

@immutable
class DailyWinFailedToLoadModel extends Model {
  final DateTime date;
  final DateTime today;
  final WinDaysData winDays;
  final String reason;

  const DailyWinFailedToLoadModel(
      this.date, this.today, this.winDays, this.reason);
}

@immutable
class DailyWinModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final WinDaysData winDays;
  final WinData win;
  final bool editable;
  final bool askForReview;

  const DailyWinModel(this.date, this.today, this.winDays, this.priorityList,
      this.win, this.editable, this.askForReview);
}

@immutable
class WinEditorModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final WinData win;

  const WinEditorModel(this.date, this.today, this.priorityList, this.win);
}

@immutable
class WinEditorSavingModel extends Model {
  final DateTime date;

  const WinEditorSavingModel(this.date);
}

@immutable
class WinEditorFailedToSaveModel extends Model {
  final DateTime date;
  final WinData win;
  final String reason;

  const WinEditorFailedToSaveModel(this.date, this.win, this.reason);
}

@immutable
class PrioritiesLoadingModel extends Model {
  final DateTime date;
  final DateTime today;

  const PrioritiesLoadingModel(this.date, this.today);
}

@immutable
class PrioritiesFailedToLoadModel extends Model {
  final DateTime date;
  final DateTime today;
  final String reason;

  const PrioritiesFailedToLoadModel(this.date, this.today, this.reason);
}

@immutable
class PrioritiesModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final bool canAddMore;

  const PrioritiesModel(
      this.date, this.today, this.priorityList, this.canAddMore);
}

@immutable
class EditPrioritiesModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  const EditPrioritiesModel(this.date, this.today, this.priorityList);
}

@immutable
class CreatingNewPriorityModel extends Model {
  final DateTime date;
  final DateTime today;

  const CreatingNewPriorityModel(this.date, this.today);
}

@immutable
class PriorityEditorModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final PriorityData priority;

  const PriorityEditorModel(
      this.date, this.today, this.priorityList, this.priority);
}

@immutable
class PrioritiesSavingModel extends Model {
  final DateTime date;

  const PrioritiesSavingModel(this.date);
}

@immutable
class PriorityEditorFailedToSaveModel extends Model {
  final DateTime date;
  final PriorityListData priorityList;
  final String reason;

  const PriorityEditorFailedToSaveModel(
      this.date, this.priorityList, this.reason);
}

@immutable
class EditWinPrioritiesModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final WinData win;

  const EditWinPrioritiesModel(
      this.date, this.today, this.priorityList, this.win);
}

@immutable
class WinListLoadingModel extends Model {
  final DateTime date;
  final DateTime today;

  const WinListLoadingModel(this.date, this.today);
}

@immutable
class WinListModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final DateTime from;
  final List<WinListItem> items;

  const WinListModel(
      this.date, this.today, this.priorityList, this.from, this.items);
}

@immutable
class WinListItem {
  const WinListItem();
}

@immutable
class WinListItemWin extends WinListItem {
  final DateTime date;
  final WinData win;

  const WinListItemWin(this.date, this.win);

  @override
  bool operator ==(Object other) {
    return other is WinListItemWin && date == other.date && win == other.win;
  }

  @override
  int get hashCode => hashValues(date, win);
}

@immutable
class WinListItemNoWin extends WinListItem {
  final DateTime date;

  const WinListItemNoWin(this.date);

  @override
  bool operator ==(Object other) {
    return other is WinListItemNoWin && date == other.date;
  }

  @override
  int get hashCode => date.hashCode;
}

@immutable
class WinListItemMonthSeparator extends WinListItem {
  final int month;

  const WinListItemMonthSeparator(this.month);

  @override
  bool operator ==(Object other) {
    return other is WinListItemMonthSeparator && month == other.month;
  }

  @override
  int get hashCode => month.hashCode;
}

@immutable
class WinListItemYearSeparator extends WinListItem {
  final int year;

  const WinListItemYearSeparator(this.year);

  @override
  bool operator ==(Object other) {
    return other is WinListItemYearSeparator && year == other.year;
  }

  @override
  int get hashCode => year.hashCode;
}

@immutable
class WinListItemLoadMoreTrigger extends WinListItem {
  @override
  bool operator ==(Object other) {
    return other is WinListItemLoadMoreTrigger;
  }

  @override
  int get hashCode => 1;
}

@immutable
class WinListItemLoadingMore extends WinListItem {
  @override
  bool operator ==(Object other) {
    return other is WinListItemLoadingMore;
  }

  @override
  int get hashCode => 1;
}

@immutable
class WinListItemRetryLoadMore extends WinListItem {
  final String reason;

  const WinListItemRetryLoadMore(this.reason);

  @override
  bool operator ==(Object other) {
    return other is WinListItemLoadMoreTrigger;
  }

  @override
  int get hashCode => 1;
}

@immutable
class WinListFailedToLoadModel extends Model {
  final DateTime date;
  final DateTime today;
  final String reason;
  final DateTime from;
  final DateTime to;

  const WinListFailedToLoadModel(
      this.date, this.today, this.from, this.to, this.reason);
}

@immutable
class CalendarViewModel extends Model {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final List<CalendarViewListItem> items;

  const CalendarViewModel(this.date, this.today, this.from, this.items);
}

@immutable
class CalendarViewListItem {
  const CalendarViewListItem();
}

@immutable
class CalendarViewListItemMonth extends CalendarViewListItem {
  final DateTime month;
  final WinDaysData winDays;

  const CalendarViewListItemMonth(this.month, this.winDays);

  @override
  bool operator ==(Object other) {
    return other is CalendarViewListItemMonth && month == other.month;
  }

  @override
  int get hashCode => month.hashCode;
}

@immutable
class CalendarViewListItemNextPageTrigger extends CalendarViewListItem {
  @override
  bool operator ==(Object other) {
    return other is CalendarViewListItemNextPageTrigger;
  }

  @override
  int get hashCode => 1;
}

@immutable
class CalendarViewListItemYearSeparator extends CalendarViewListItem {
  final int year;

  const CalendarViewListItemYearSeparator(this.year);

  @override
  bool operator ==(Object other) {
    return other is CalendarViewListItemYearSeparator && year == other.year;
  }

  @override
  int get hashCode => year.hashCode;
}

@immutable
class StatsLoadingModel extends Model {
  final DateTime date;
  final DateTime today;
  final StatsPeriod period;
  final DateTime from;
  final DateTime to;

  const StatsLoadingModel(
      this.date, this.today, this.period, this.from, this.to);
}

@immutable
class StatsFailedToLoadModel extends Model {
  final DateTime date;
  final DateTime today;
  final StatsPeriod period;
  final DateTime from;
  final DateTime to;
  final String reason;

  const StatsFailedToLoadModel(
      this.date, this.today, this.period, this.from, this.to, this.reason);
}

@immutable
class StatsModel extends Model {
  final DateTime date;
  final DateTime today;
  final StatsPeriod period;
  final DateTime from;
  final DateTime to;
  final int daysTotal;
  final PriorityListData priorityList;
  final WinListShortData stats;
  final bool winsShowAsPie;
  final bool prioritiesShowAsPie;

  const StatsModel(
      this.date,
      this.today,
      this.period,
      this.from,
      this.to,
      this.daysTotal,
      this.priorityList,
      this.stats,
      this.winsShowAsPie,
      this.prioritiesShowAsPie);
}

@immutable
class InsightsLoadingModel extends Model {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;

  const InsightsLoadingModel(this.date, this.today, this.from, this.to);
}

@immutable
class InsightsFailedToLoadModel extends Model {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;
  final String reason;

  const InsightsFailedToLoadModel(
      this.date, this.today, this.from, this.to, this.reason);
}

@immutable
class InsightsModel extends Model {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final DateTime to;
  final PriorityListData priorityList;
  final WinListShortData data;

  const InsightsModel(
      this.date, this.today, this.from, this.to, this.priorityList, this.data);
}

@immutable
class AppSettingsInititalizingModel extends Model {
  final DateTime date;
  final DateTime today;

  const AppSettingsInititalizingModel(this.date, this.today);
}

@immutable
class AppSettingsModel extends Model {
  final DateTime date;
  final DateTime today;
  final AppSettings appSettings;

  const AppSettingsModel(this.date, this.today, this.appSettings);
}

@immutable
class AppSettingsSavingModel extends Model {
  final DateTime date;

  const AppSettingsSavingModel(this.date);
}

@immutable
class DataDeletionConfirmationStateModel extends Model {
  final DateTime date;
  final DateTime today;
  final String text;

  const DataDeletionConfirmationStateModel(this.date, this.today, this.text);
}

@immutable
class DeletingUserDataModel extends Model {
  final DateTime date;

  const DeletingUserDataModel(this.date);
}

@immutable
class FailedToDeleteUserDataModel extends Model {
  final DateTime date;
  final DateTime today;
  final String reason;

  const FailedToDeleteUserDataModel(this.date, this.today, this.reason);
}
