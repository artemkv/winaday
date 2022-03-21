import 'package:flutter/material.dart';
import 'package:winaday/commands_journey.dart';
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
    return ModelAndCommand(
        DailyWinLoadingModel(message.today, message.today, WinDaysData.empty()),
        CommandList(
            [LoadDailyWinWithInitialData(message.today), ReportSignIn()]));
  }
  if (message is SignInFailed) {
    return ModelAndCommand.justModel(UserFailedToSignInModel(message.reason));
  }
  if (message is SignOutRequested) {
    return ModelAndCommand(
        SignOutInProgressModel(), CommandList([SignOut(), ReportSignOut()]));
  }
  if (message is UserSignedOut) {
    return ModelAndCommand.justModel(const UserNotSignedInModel(false, false));
  }

  if (message is DailyWinViewInitialDataLoaded) {
    var winDays = getWinDaysIfOnModel(model);
    var receivedWinDays = message.wins
        .where((x) => x.win.isWin())
        .map((x) => x.date.toCompact())
        .toSet();
    var udpatedWinDays = WinDaysData(winDays.items.union(receivedWinDays));

    return ModelAndCommand.justModel(DailyWinModel(
        message.date,
        message.today,
        udpatedWinDays,
        message.priorityList,
        message.win,
        message.editable,
        false));
  }
  if (message is DailyWinViewLoaded) {
    var winDays = getWinDaysIfOnModel(model);
    var thisMonth = message.date;
    var prevMonth = getPreviousMonth(thisMonth);
    var nextMonth = getNextMonth(thisMonth);

    var commands = [
      LoadWinDays(thisMonth),
      LoadWinDays(prevMonth),
      LoadWinDays(nextMonth),
      ReportMovedToDay(),
    ];
    if (message.askForReview) {
      commands.add(ReportLoyalUser());
    }

    return ModelAndCommand(
        DailyWinModel(
            message.date,
            message.today,
            winDays,
            message.priorityList,
            message.win,
            message.editable,
            message.askForReview),
        CommandList(commands));
  }
  if (message is DailyWinViewLoadingFailed) {
    var winDays = getWinDaysIfOnModel(model);
    return ModelAndCommand(
        DailyWinFailedToLoadModel(
            message.date, message.today, winDays, message.reason),
        ReportDailyWinViewLoadingFailed());
  }
  if (message is DailyWinViewReloadRequested) {
    var winDays = getWinDaysIfOnModel(model);
    return ModelAndCommand(
        DailyWinLoadingModel(message.date, message.today, winDays),
        LoadDailyWin(message.date));
  }
  if (message is EditWinRequested) {
    var winToEdit = WinData(
        message.win.text,
        message.win.overallResult == OverallDayResult.noWinYet
            ? OverallDayResult.gotMyWin
            : message.win.overallResult,
        message.win.priorities);
    return ModelAndCommand(
        WinEditorModel(
            message.date, message.today, message.priorityList, winToEdit),
        ReportEditWin());
  }
  if (message is CancelEditingWinRequested) {
    return ModelAndCommand(
        DailyWinLoadingModel(message.date, message.today, WinDaysData.empty()),
        LoadDailyWin(message.date));
  }
  if (message is WinChangesConfirmed) {
    if (message.win.isWin() &&
        message.win.priorities.isEmpty &&
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
    return ModelAndCommand(
        DailyWinLoadingModel(message.date, message.today, WinDaysData.empty()),
        CommandList([LoadDailyWin(message.date), ReportWinSaved()]));
  }
  if (message is SavingWinFailed) {
    return ModelAndCommand(
        WinEditorFailedToSaveModel(message.date, message.win, message.reason),
        ReportSavingWinFailed());
  }

  if (message is MoveToPrevDay) {
    var winDays = getWinDaysIfOnModel(model);
    DateTime newDate = message.date.prevDay();
    return ModelAndCommand(
        DailyWinLoadingModel(newDate, message.today, winDays),
        LoadDailyWin(newDate));
  }
  if (message is MoveToNextDay) {
    var winDays = getWinDaysIfOnModel(model);
    DateTime newDate = message.date.nextDay();
    return ModelAndCommand(
        DailyWinLoadingModel(newDate, message.today, winDays),
        LoadDailyWin(newDate));
  }
  if (message is MoveToPrevWeek) {
    var winDays = getWinDaysIfOnModel(model);
    DateTime newDate = message.date.prevWeek();
    return ModelAndCommand(
        DailyWinLoadingModel(newDate, message.today, winDays),
        LoadDailyWin(newDate));
  }
  if (message is MoveToNextWeek) {
    var winDays = getWinDaysIfOnModel(model);
    DateTime newDate = message.date.nextWeek();
    return ModelAndCommand(
        DailyWinLoadingModel(newDate, message.today, winDays),
        LoadDailyWin(newDate));
  }
  if (message is MoveToDay) {
    var winDays = getWinDaysIfOnModel(model);
    return ModelAndCommand(
        DailyWinLoadingModel(message.date, message.today, winDays),
        LoadDailyWin(message.date));
  }

  if (message is NavigateToPrioritiesRequested) {
    return ModelAndCommand(
        PrioritiesLoadingModel(message.date, message.today),
        CommandList(
            [LoadPriorities(message.date), ReportNavigateToPriorities()]));
  }
  if (message is PrioritiesLoadingFailed) {
    return ModelAndCommand(
        PrioritiesFailedToLoadModel(
            message.date, message.today, message.reason),
        ReportPrioritiesLoadingFailed());
  }
  if (message is PrioritiesReloadRequested) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        LoadPriorities(message.date));
  }
  if (message is ExitPrioritiesRequested) {
    return ModelAndCommand(
        DailyWinLoadingModel(message.date, message.today, WinDaysData.empty()),
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
    return ModelAndCommand(
        EditPrioritiesModel(message.date, message.today, message.priorityList),
        ReportEditPriorities());
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
    return ModelAndCommand(
      PrioritiesSavingModel(message.date),
      SavePriorities(message.date, message.priorityList),
    );
  }
  if (message is CancelEditingPrioritiesRequested) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        LoadPriorities(message.date));
  }

  if (message is EditExistingPriorityRequested) {
    return ModelAndCommand(
        PriorityEditorModel(message.date, message.today, message.priorityList,
            message.priority),
        ReportEditPriority());
  }
  if (message is EditNewPriorityRequested) {
    return ModelAndCommand(
        CreatingNewPriorityModel(message.date, message.today),
        CreateNewPriority(message.date, message.today, message.priorityList));
  }
  if (message is NewPriorityCreated) {
    return ModelAndCommand(
        PriorityEditorModel(message.date, message.today, message.priorityList,
            message.priority),
        ReportEditPriority());
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

    return ModelAndCommand(
      PrioritiesSavingModel(message.date),
      SavePriorities(message.date, PriorityListData(List.from(updatedList))),
    );
  }
  if (message is PrioritiesSaved) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        CommandList([LoadPriorities(message.date), ReportPrioritiesSaved()]));
  }
  if (message is SavingPrioritiesFailed) {
    return ModelAndCommand(
        PriorityEditorFailedToSaveModel(
            message.date, message.priorityList, message.reason),
        ReportSavingPrioritiesFailed());
  }

  if (message is LinkWinToPriorities) {
    return ModelAndCommand(
        EditWinPrioritiesModel(
            message.date, message.today, message.priorityList, message.win),
        ReportEditWinPriorities());
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
    return ModelAndCommand(
        WinListLoadingModel(message.date, message.today),
        CommandList([
          LoadWinListFirstPage(message.date, from, message.today),
          ReportNavigateToWinList()
        ]));
  }
  if (message is BackToDailyWinViewRequested) {
    return ModelAndCommand(
        DailyWinLoadingModel(message.date, message.today, WinDaysData.empty()),
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
    return ModelAndCommand(
        WinListFailedToLoadModel(message.date, message.today, message.from,
            message.to, message.reason),
        ReportWinListFirstPageLoadingFailed());
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
      return ModelAndCommand(
          WinListModel(model.date, model.today, model.priorityList, model.from,
              updatedItems),
          ReportWinListNextPageLoadingFailed());
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
          LoadWinDays(twoMonthsAgo),
          ReportNavigateToCalendar()
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
    if (model is DailyWinModel) {
      var winDaysUpdated =
          WinDaysData(model.winDays.items.union(message.winDays.items));
      return ModelAndCommand.justModel(DailyWinModel(
          model.date,
          model.today,
          winDaysUpdated,
          model.priorityList,
          model.win,
          model.editable,
          model.askForReview));
    }
    if (model is DailyWinLoadingModel) {
      var winDaysUpdated =
          WinDaysData(model.winDays.items.union(message.winDays.items));
      return ModelAndCommand.justModel(
          DailyWinLoadingModel(model.date, model.today, winDaysUpdated));
    }
    if (model is DailyWinFailedToLoadModel) {
      var winDaysUpdated =
          WinDaysData(model.winDays.items.union(message.winDays.items));
      return ModelAndCommand.justModel(DailyWinFailedToLoadModel(
          model.date, model.today, winDaysUpdated, model.reason));
    }
  }

  if (message is NavigateToStatsRequested) {
    if (message.period == StatsPeriod.month) {
      var from = getFirstDayOfMonth(message.today);
      var to = getLastDayOfMonth(message.today);
      return ModelAndCommand(
          StatsLoadingModel(
              message.date, message.today, message.period, from, to),
          CommandList([
            LoadStats(message.date, message.period, from, to),
            ReportNavigateToStats()
          ]));
    } else {
      var from = getFirstDayOfYear(message.today);
      var to = getLastDayOfMonth(message.today);
      return ModelAndCommand(
          StatsLoadingModel(
              message.date, message.today, message.period, from, to),
          CommandList([
            LoadStats(message.date, message.period, from, to),
            ReportNavigateToStats()
          ]));
    }
  }
  if (message is StatsLoadingFailed) {
    return ModelAndCommand(
        StatsFailedToLoadModel(message.date, message.today, message.period,
            message.from, message.to, message.reason),
        ReportStatsLoadingFailed());
  }
  if (message is StatsReloadRequested) {
    return ModelAndCommand(
        StatsLoadingModel(message.date, message.today, message.period,
            message.from, message.to),
        LoadStats(message.date, message.period, message.from, message.to));
  }
  if (message is StatsLoaded) {
    return ModelAndCommand.justModel(StatsModel(
        message.date,
        message.today,
        message.period,
        message.from,
        message.to,
        getDaysInIntervalUpToToday(message.from, message.to, message.today),
        message.priorityList,
        message.stats,
        true,
        true));
  }
  if (message is ExitStatsRequested) {
    return ModelAndCommand(
        DailyWinLoadingModel(message.date, message.today, WinDaysData.empty()),
        LoadDailyWin(message.date));
  }
  if (message is StatsTogglePieHistogramsWins) {
    if (model is StatsModel) {
      return ModelAndCommand(
          StatsModel(
              model.date,
              model.today,
              model.period,
              model.from,
              model.to,
              model.daysTotal,
              model.priorityList,
              model.stats,
              !model.winsShowAsPie,
              model.prioritiesShowAsPie),
          ReportToggleStatsPieToHistograms());
    }
  }
  if (message is StatsTogglePieHistogramsPriorities) {
    if (model is StatsModel) {
      return ModelAndCommand(
          StatsModel(
              model.date,
              model.today,
              model.period,
              model.from,
              model.to,
              model.daysTotal,
              model.priorityList,
              model.stats,
              model.winsShowAsPie,
              !model.prioritiesShowAsPie),
          ReportToggleStatsPieToHistograms());
    }
  }
  if (message is MoveToPrevMonthStats) {
    if (model is StatsModel) {
      var prevMonth = getPreviousMonth(model.from);
      var from = getFirstDayOfMonth(prevMonth);
      var to = getLastDayOfMonth(prevMonth);
      return ModelAndCommand(
          StatsLoadingModel(
              message.date, message.today, StatsPeriod.month, from, to),
          LoadStats(message.date, StatsPeriod.month, from, to));
    }
  }
  if (message is MoveToNextMonthStats) {
    if (model is StatsModel) {
      var nextMonth = getNextMonth(model.from);
      var from = getFirstDayOfMonth(nextMonth);
      var to = getLastDayOfMonth(nextMonth);
      return ModelAndCommand(
          StatsLoadingModel(
              message.date, message.today, StatsPeriod.month, from, to),
          LoadStats(message.date, StatsPeriod.month, from, to));
    }
  }
  if (message is MoveToPrevYearStats) {
    if (model is StatsModel) {
      var prevYear = getPreviousYear(model.from);
      var from = getFirstDayOfYear(prevYear);
      var to = getLastDayOfYear(prevYear);
      return ModelAndCommand(
          StatsLoadingModel(
              message.date, message.today, StatsPeriod.year, from, to),
          LoadStats(message.date, StatsPeriod.year, from, to));
    }
  }
  if (message is MoveToNextYearStats) {
    if (model is StatsModel) {
      var nextYear = getNextYear(model.from);
      var from = getFirstDayOfYear(nextYear);
      var to = getLastDayOfYear(nextYear);
      return ModelAndCommand(
          StatsLoadingModel(
              message.date, message.today, StatsPeriod.year, from, to),
          LoadStats(message.date, StatsPeriod.year, from, to));
    }
  }
  if (message is AgreedOnLeavingFeedback) {
    Model updatedModel = model;
    if (model is DailyWinModel) {
      updatedModel = DailyWinModel(model.date, model.today, model.winDays,
          model.priorityList, model.win, model.editable, false);
    }
    return ModelAndCommand(updatedModel, NavigateToRatingInAppStore());
  }
  if (message is RejectedLeavingFeedback) {
    Model updatedModel = model;
    if (model is DailyWinModel) {
      updatedModel = DailyWinModel(model.date, model.today, model.winDays,
          model.priorityList, model.win, model.editable, false);
    }
    return ModelAndCommand(updatedModel, NeverAskForReviewAgain());
  }

  if (message is NavigateToInsightsRequested) {
    var from = DateTime(
        message.today.year, message.today.month, message.today.day - 89);
    var to = message.today;
    return ModelAndCommand(
        InsightsLoadingModel(message.date, message.today, from, to),
        CommandList([
          LoadInsightData(message.date, from, to),
          ReportNavigateToInsights()
        ]));
  }
  if (message is InsightsLoadingFailed) {
    return ModelAndCommand(
        InsightsFailedToLoadModel(message.date, message.today, message.from,
            message.to, message.reason),
        ReportInsightsLoadingFailed());
  }
  if (message is InsightsReloadRequested) {
    return ModelAndCommand(
        InsightsLoadingModel(
            message.date, message.today, message.from, message.to),
        LoadInsightData(message.date, message.from, message.to));
  }
  if (message is InsightsLoaded) {
    return ModelAndCommand.justModel(InsightsModel(message.date, message.today,
        message.from, message.to, message.priorityList, message.data));
  }
  if (message is ExitInsightsRequested) {
    return ModelAndCommand(
        DailyWinLoadingModel(message.date, message.today, WinDaysData.empty()),
        LoadDailyWin(message.date));
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

WinDaysData getWinDaysIfOnModel(Model model) {
  if (model is DailyWinModel) {
    return model.winDays;
  }
  if (model is DailyWinLoadingModel) {
    return model.winDays;
  }
  if (model is DailyWinFailedToLoadModel) {
    return model.winDays;
  }
  return WinDaysData.empty();
}
