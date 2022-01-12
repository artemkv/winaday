// Should all be immutable classes and no logic!
// No side effects allowed!

import 'package:flutter/cupertino.dart';

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

class WinListLoadingModel extends Model {
  final DateTime date;
  final DateTime today;

  WinListLoadingModel(this.date, this.today);
}

class WinListModel extends Model {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;
  final DateTime from;
  final List<WinListItem> items;

  WinListModel(this.date, this.today, this.priorityList, this.from, this.items);
}

class WinListItem {}

class WinListItemWin extends WinListItem {
  final DateTime date;
  final WinData win;

  WinListItemWin(this.date, this.win);

  @override
  bool operator ==(Object other) {
    return other is WinListItemWin && date == other.date && win == other.win;
  }

  @override
  int get hashCode => hashValues(date, win);
}

class WinListItemNoWin extends WinListItem {
  final DateTime date;

  WinListItemNoWin(this.date);

  @override
  bool operator ==(Object other) {
    return other is WinListItemNoWin && date == other.date;
  }

  @override
  int get hashCode => date.hashCode;
}

class WinListItemMonthSeparator extends WinListItem {
  final int month;

  WinListItemMonthSeparator(this.month);

  @override
  bool operator ==(Object other) {
    return other is WinListItemMonthSeparator && month == other.month;
  }

  @override
  int get hashCode => month.hashCode;
}

class WinListItemYearSeparator extends WinListItem {
  final int year;

  WinListItemYearSeparator(this.year);

  @override
  bool operator ==(Object other) {
    return other is WinListItemYearSeparator && year == other.year;
  }

  @override
  int get hashCode => year.hashCode;
}

class WinListItemLoadMoreTrigger extends WinListItem {
  @override
  bool operator ==(Object other) {
    return other is WinListItemLoadMoreTrigger;
  }

  @override
  int get hashCode => 1;
}

class WinListItemLoadingMore extends WinListItem {
  @override
  bool operator ==(Object other) {
    return other is WinListItemLoadingMore;
  }

  @override
  int get hashCode => 1;
}

class WinListItemRetryLoadMore extends WinListItem {
  final String reason;

  WinListItemRetryLoadMore(this.reason);

  @override
  bool operator ==(Object other) {
    return other is WinListItemLoadMoreTrigger;
  }

  @override
  int get hashCode => 1;
}

class WinListFailedToLoadModel extends Model {
  final DateTime date;
  final DateTime today;
  final String reason;
  final DateTime from;
  final DateTime to;

  WinListFailedToLoadModel(
      this.date, this.today, this.from, this.to, this.reason);
}

class CalendarViewModel extends Model {
  final DateTime date;
  final DateTime today;
  final DateTime from;
  final List<CalendarViewListItem> items;

  CalendarViewModel(this.date, this.today, this.from, this.items);
}

class CalendarViewListItem {}

class CalendarViewListItemMonth extends CalendarViewListItem {
  final DateTime month;

  CalendarViewListItemMonth(this.month);

  @override
  bool operator ==(Object other) {
    return other is CalendarViewListItemMonth && month == other.month;
  }

  @override
  int get hashCode => month.hashCode;
}

class CalendarViewListItemNextPageTrigger extends CalendarViewListItem {
  @override
  bool operator ==(Object other) {
    return other is CalendarViewListItemNextPageTrigger;
  }

  @override
  int get hashCode => 1;
}

class CalendarViewListItemYearSeparator extends CalendarViewListItem {
  final int year;

  CalendarViewListItemYearSeparator(this.year);

  @override
  bool operator ==(Object other) {
    return other is CalendarViewListItemYearSeparator && year == other.year;
  }

  @override
  int get hashCode => year.hashCode;
}
