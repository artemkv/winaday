import 'package:flutter/material.dart';
import 'package:winaday/dateutil.dart';
import 'package:winaday/domain.dart';

import 'model.dart';
import 'messages.dart';
import 'commands.dart';

@immutable
class ModelAndCommand {
  final Model model;
  final Command command;

  const ModelAndCommand(this.model, this.command);
  ModelAndCommand.justModel(Model model) : this(model, Command.none());
}

// reduce must be a pure function!

ModelAndCommand reduce(Model model, Message message) {
  if (message is AppInitializedNotSignedIn) {
    return ModelAndCommand.justModel(const UserNotSignedInModel(false, false));
  }
  if (message is UserConsentUpdated) {
    return ModelAndCommand.justModel(UserNotSignedInModel(
        message.privacyPolicyAccepted, message.personalDataProcessingAccepted));
  }
  if (message is AppInitializationFailed) {
    return ModelAndCommand.justModel(
        ApplicationFailedToInitializeModel(message.reason));
  }
  if (message is ReInitializationRequested) {
    return ModelAndCommand(ApplicationNotInitializedModel(), InitializeApp());
  }

  if (message is SignInRequested) {
    return ModelAndCommand(SignInInProgressModel(), SignIn());
  }
  if (message is UserSignedIn) {
    return ModelAndCommand(DailyWinLoadingModel(message.today, message.today),
        LoadDailyWin(message.today));
  }
  if (message is SignInFailed) {
    return ModelAndCommand.justModel(UserFailedToSignInModel(message.reason));
  }
  if (message is SignOutRequested) {
    return ModelAndCommand(SignOutInProgressModel(), SignOut());
  }
  if (message is UserSignedOut) {
    return ModelAndCommand.justModel(const UserNotSignedInModel(false, false));
  }

  if (message is DailyWinViewLoaded) {
    if (model is DailyWinModel) {
      var updatedWins = {for (var x in model.wins.entries) x.key: x.value};
      updatedWins[message.date.toCompact()] =
          DailyWinModelWinDataLoaded(message.win, message.editable);
      return ModelAndCommand.justModel(DailyWinModel(
          model.date, model.today, message.priorityList, updatedWins));
    } else {
      var wins = {
        message.date.toCompact():
            DailyWinModelWinDataLoaded(message.win, message.editable)
      };
      return ModelAndCommand.justModel(DailyWinModel(
          message.date, message.today, message.priorityList, wins));
    }
  }
  if (message is DailyWinViewLoadingFailed) {
    return ModelAndCommand.justModel(
        DailyWinFailedToLoadModel(message.date, message.today, message.reason));
  }
  if (message is DailyWinViewReloadRequested) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is EditWinRequested) {
    var winToEdit = WinData(
        message.win.text,
        message.win.overallResult == OverallDayResult.noWinYet
            ? OverallDayResult.gotMyWin
            : message.win.overallResult,
        message.win.priorities);
    return ModelAndCommand.justModel(WinEditorModel(
        message.date, message.today, message.priorityList, winToEdit));
  }
  if (message is CancelEditingWinRequested) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is WinChangesConfirmed) {
    if (message.win.priorities.isEmpty &&
        message.priorityList.items
            .where((x) => !x.deleted)
            .isNotEmpty) // consider adding activeItems property on PriorityListData object
    {
      return ModelAndCommand.justModel(EditWinPrioritiesModel(
          message.date, message.today, message.priorityList, message.win));
    } else {
      return ModelAndCommand(WinEditorSavingModel(message.date),
          SaveWin(message.date, message.win));
    }
  }
  if (message is WinSaveRequested) {
    return ModelAndCommand(
        WinEditorSavingModel(message.date), SaveWin(message.date, message.win));
  }
  if (message is WinSaved) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is SavingWinFailed) {
    return ModelAndCommand.justModel(
        WinEditorFailedToSaveModel(message.date, message.win, message.reason));
  }

  if (message is MoveToDayByOffset) {
    if (model is DailyWinModel) {
      DateTime newDate = message.date.moveTo(message.offset);
      return ModelAndCommand(
          DailyWinModel(newDate, model.today, model.priorityList, model.wins),
          LoadDailyWin(newDate));
    }
  }
  if (message is MoveToPrevWeek) {
    DateTime newDate = message.date.prevWeek();
    return ModelAndCommand(
        DailyWinLoadingModel(newDate, message.today), LoadDailyWin(newDate));
  }
  if (message is MoveToNextWeek) {
    DateTime newDate = message.date.nextWeek();
    return ModelAndCommand(
        DailyWinLoadingModel(newDate, message.today), LoadDailyWin(newDate));
  }
  if (message is MoveToDay) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }

  if (message is NavigateToPrioritiesRequested) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        LoadPriorities(message.date));
  }
  if (message is PrioritiesLoadingFailed) {
    return ModelAndCommand.justModel(PrioritiesFailedToLoadModel(
        message.date, message.today, message.reason));
  }
  if (message is PrioritiesReloadRequested) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        LoadPriorities(message.date));
  }
  if (message is ExitPrioritiesRequested) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is PrioritiesLoaded) {
    return ModelAndCommand.justModel(PrioritiesModel(
        message.date,
        message.today,
        message.priorityList,
        canAddMorePriorities(message.priorityList)));
  }
  if (message is EditPrioritiesRequested) {
    return ModelAndCommand.justModel(
        EditPrioritiesModel(message.date, message.today, message.priorityList));
  }
  if (message is PrioritiesReorderRequested) {
    var reordered = message.priorityList.items.map((e) {
      if (e.id == message.priority.id) {
        return message.exchangeWith;
      } else if (e.id == message.exchangeWith.id) {
        return message.priority;
      } else {
        return e;
      }
    });

    return ModelAndCommand.justModel(EditPrioritiesModel(
        message.date, message.today, PriorityListData(List.from(reordered))));
  }
  if (message is DeletePriorityRequested) {
    var updatedList = message.priorityList.items.map((e) {
      if (e.id == message.priority.id) {
        return PriorityData(message.priority.id, message.priority.text,
            message.priority.color, true);
      } else {
        return e;
      }
    });

    return ModelAndCommand.justModel(EditPrioritiesModel(
        message.date, message.today, PriorityListData(List.from(updatedList))));
  }
  if (message is SaveChangesInPrioritiesRequested) {
    return ModelAndCommand(PrioritiesSavingModel(message.date),
        SavePriorities(message.date, message.priorityList));
  }
  if (message is CancelEditingPrioritiesRequested) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        LoadPriorities(message.date));
  }

  if (message is EditExistingPriorityRequested) {
    return ModelAndCommand.justModel(PriorityEditorModel(
        message.date, message.today, message.priorityList, message.priority));
  }
  if (message is EditNewPriorityRequested) {
    return ModelAndCommand(
        CreatingNewPriorityModel(message.date, message.today),
        CreateNewPriority(message.date, message.today, message.priorityList));
  }
  if (message is NewPriorityCreated) {
    return ModelAndCommand.justModel(PriorityEditorModel(
        message.date, message.today, message.priorityList, message.priority));
  }
  if (message is CancelEditingPriorityRequested) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        LoadPriorities(message.date));
  }
  if (message is PrioritySaveRequested) {
    var updatedList = message.priorityList.items.map((e) {
      if (e.id == message.priority.id) {
        return message.priority;
      } else {
        return e;
      }
    });

    return ModelAndCommand(PrioritiesSavingModel(message.date),
        SavePriorities(message.date, PriorityListData(List.from(updatedList))));
  }
  if (message is SavingPrioritiesFailed) {
    return ModelAndCommand.justModel(PriorityEditorFailedToSaveModel(
        message.date, message.priorityList, message.reason));
  }

  if (message is LinkWinToPriorities) {
    return ModelAndCommand.justModel(EditWinPrioritiesModel(
        message.date, message.today, message.priorityList, message.win));
  }
  if (message is ToggleWinPriority) {
    Set<String> udpatedPriorities = getUpdatedWinPriorities(
        message.win, message.priority, message.priorityList);

    var updatedWin =
        WinData(message.win.text, message.win.overallResult, udpatedPriorities);

    return ModelAndCommand.justModel(EditWinPrioritiesModel(
        message.date, message.today, message.priorityList, updatedWin));
  }

  if (message is NavigateToWinListRequested) {
    var from = DateTime(
        message.today.year, message.today.month, message.today.day - 13);
    return ModelAndCommand(WinListLoadingModel(message.date, message.today),
        LoadWinListFirstPage(message.date, from, message.today));
  }
  if (message is BackToDailyWinViewRequested) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is WinListFirstPageLoaded) {
    return ModelAndCommand.justModel(WinListModel(
        message.date,
        message.today,
        message.priorityList,
        message.from,
        toWinListItems(message.from, message.to, message.wins)));
  }
  if (message is WinListFirstPageLoadingFailed) {
    return ModelAndCommand.justModel(WinListFailedToLoadModel(
        message.date, message.today, message.from, message.to, message.reason));
  }
  if (message is WinListFirstPageReloadRequested) {
    return ModelAndCommand(WinListLoadingModel(message.date, message.today),
        LoadWinListFirstPage(message.date, message.from, message.to));
  }
  if (message is LoadWinListNextPageRequested) {
    if (model is WinListModel) {
      var from =
          DateTime(model.from.year, model.from.month, model.from.day - 14);
      return ModelAndCommand(
          model, LoadWinListNextPage(from, model.from.prevDay()));
    }
  }
  if (message is WinListRetryLoadNextPageRequested) {
    if (model is WinListModel) {
      var updatedItems = <WinListItem>[WinListItemLoadingMore()];
      updatedItems.addAll(model.items.getRange(
          1, model.items.length)); // old items except the retry trigger
      var from =
          DateTime(model.from.year, model.from.month, model.from.day - 14);
      return ModelAndCommand(
          WinListModel(model.date, model.today, model.priorityList, model.from,
              updatedItems),
          LoadWinListNextPage(from, model.from.prevDay()));
    }
  }
  if (message is WinListNextPageLoaded) {
    if (model is WinListModel) {
      var updatedItems =
          List.of(toWinListItems(message.from, message.to, message.wins));
      updatedItems.addAll(model.items.getRange(
          1, model.items.length)); // old items except the load more trigger

      return ModelAndCommand.justModel(WinListModel(model.date, model.today,
          model.priorityList, message.from, updatedItems));
    }
  }
  if (message is WinListNextPageLoadingFailed) {
    if (model is WinListModel) {
      var updatedItems = <WinListItem>[
        WinListItemRetryLoadMore(message.reason)
      ];
      updatedItems.addAll(model.items.getRange(
          1, model.items.length)); // old items except the loading spinner
      return ModelAndCommand.justModel(WinListModel(model.date, model.today,
          model.priorityList, model.from, updatedItems));
    }
  }

  if (message is NavigateToCalendarRequested) {
    var thisMonth = message.today;
    var prevMonth = getPreviousMonth(thisMonth);
    var twoMonthsAgo = getPreviousMonth(prevMonth);

    return ModelAndCommand(
        CalendarViewModel(message.date, message.today, twoMonthsAgo,
            toCalendarViewListItems([twoMonthsAgo, prevMonth, thisMonth])),
        CommandList([
          LoadWinDays(thisMonth),
          LoadWinDays(prevMonth),
          LoadWinDays(twoMonthsAgo)
        ]));
  }
  if (message is CalendarViewNextPageRequested) {
    if (model is CalendarViewModel) {
      var back1Month = getPreviousMonth(model.from);
      var back2Month = getPreviousMonth(back1Month);
      var back3Month = getPreviousMonth(back2Month);
      var updatedItems =
          toCalendarViewListItems([back3Month, back2Month, back1Month]);
      updatedItems.addAll(model.items.getRange(
          1, model.items.length)); // old items except the load more trigger

      return ModelAndCommand(
          CalendarViewModel(model.date, model.today, back3Month, updatedItems),
          CommandList([
            LoadWinDays(back1Month),
            LoadWinDays(back2Month),
            LoadWinDays(back3Month)
          ]));
    }
  }
  if (message is CalendarViewDaysWithWinsReceived) {
    if (model is CalendarViewModel) {
      var updatedItems = model.items.map((x) {
        if (x is CalendarViewListItemMonth) {
          if (x.month.isSameMonth(message.month)) {
            return CalendarViewListItemMonth(x.month, message.winDays);
          }
        }
        return x;
      }).toList();
      return ModelAndCommand.justModel(
          CalendarViewModel(model.date, model.today, model.from, updatedItems));
    }
  }

  if (message is NavigateToStatsRequested) {
    var from = getFirstDayOfMonth(message.today);
    var to = getLastDayOfMonth(message.today);
    return ModelAndCommand(
        StatsLoadingModel(message.date, message.today, from, to),
        LoadStats(message.date, from, to));
  }
  if (message is StatsLoadingFailed) {
    return ModelAndCommand.justModel(StatsFailedToLoadModel(
        message.date, message.today, message.from, message.to, message.reason));
  }
  if (message is StatsReloadRequested) {
    return ModelAndCommand(
        StatsLoadingModel(
            message.date, message.today, message.from, message.to),
        LoadStats(message.date, message.from, message.to));
  }
  if (message is StatsLoaded) {
    return ModelAndCommand.justModel(MonthlyStatsModel(
        message.date,
        message.today,
        message.from,
        message.to,
        getDaysInIntervalUpToToday(message.from, message.to, message.today),
        message.priorityList,
        message.stats,
        true,
        true));
  }
  if (message is ExitStatsRequested) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is StatsTogglePieHistogramsWins) {
    if (model is MonthlyStatsModel) {
      return ModelAndCommand.justModel(MonthlyStatsModel(
          model.date,
          model.today,
          model.from,
          model.to,
          model.daysTotal,
          model.priorityList,
          model.stats,
          !model.winsShowAsPie,
          model.prioritiesShowAsPie));
    }
  }
  if (message is StatsTogglePieHistogramsPriorities) {
    if (model is MonthlyStatsModel) {
      return ModelAndCommand.justModel(MonthlyStatsModel(
          model.date,
          model.today,
          model.from,
          model.to,
          model.daysTotal,
          model.priorityList,
          model.stats,
          model.winsShowAsPie,
          !model.prioritiesShowAsPie));
    }
  }
  if (message is MoveToPrevMonthStats) {
    if (model is MonthlyStatsModel) {
      var prevMonth = getPreviousMonth(model.from);
      var from = getFirstDayOfMonth(prevMonth);
      var to = getLastDayOfMonth(prevMonth);
      return ModelAndCommand(
          StatsLoadingModel(message.date, message.today, from, to),
          LoadStats(message.date, from, to));
    }
  }
  if (message is MoveToNextMonthStats) {
    if (model is MonthlyStatsModel) {
      var nextMonth = getNextMonth(model.from);
      var from = getFirstDayOfMonth(nextMonth);
      var to = getLastDayOfMonth(nextMonth);
      return ModelAndCommand(
          StatsLoadingModel(message.date, message.today, from, to),
          LoadStats(message.date, from, to));
    }
  }

  return ModelAndCommand.justModel(model);
}

bool canAddMorePriorities(PriorityListData priorityList) {
  return priorityList.items
          .where((element) => !element.deleted)
          .toList()
          .length <
      9;
}

Set<String> getUpdatedWinPriorities(
    WinData win, PriorityData toggledPriority, PriorityListData priorityList) {
  Set<String> activePriorities =
      priorityList.items.where((x) => !x.deleted).map((x) => x.id).toSet();

  Set<String> udpatedPriorities;
  if (win.priorities.contains(toggledPriority.id)) {
    udpatedPriorities = win.priorities
        .where((x) => activePriorities.contains(x) && x != toggledPriority.id)
        .toSet();
  } else {
    udpatedPriorities = win.priorities
        .where((x) => activePriorities.contains(x))
        .toSet()
        .union({toggledPriority.id});
  }
  return udpatedPriorities;
}

List<WinListItem> toWinListItems(
    DateTime from, final DateTime to, List<WinOnDayData> wins) {
  var winsByDate = {for (var x in wins) x.date.toCompact(): x.win};

  List<WinListItem> winListItems = [];
  winListItems.add(WinListItemLoadMoreTrigger());

  var day = from;
  var prevDay = day;
  while (day.isBefore(to) || day.isSameDate(to)) {
    if (prevDay.year != day.year) {
      winListItems.add(WinListItemYearSeparator(day.year));
    }
    if (prevDay.month != day.month) {
      winListItems.add(WinListItemMonthSeparator(day.month));
    }

    if (winsByDate.containsKey(day.toCompact())) {
      winListItems.add(WinListItemWin(day, winsByDate[day.toCompact()]!));
    } else {
      winListItems.add(WinListItemNoWin(day));
    }
    prevDay = day;
    day = day.nextDay();
  }
  return winListItems;
}

List<CalendarViewListItem> toCalendarViewListItems(List<DateTime> dates) {
  List<CalendarViewListItem> calendarListItems = [
    CalendarViewListItemNextPageTrigger()
  ];
  for (int i = 0; i < dates.length; i++) {
    var date = dates[i];
    if (i > 0) {
      var prevDate = dates[i - 1];
      if (prevDate.year != date.year) {
        calendarListItems.add(CalendarViewListItemYearSeparator(date.year));
      }
    }
    calendarListItems.add(CalendarViewListItemMonth(date, WinDaysData.empty()));
  }
  return calendarListItems;
}
