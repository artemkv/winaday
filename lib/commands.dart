import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:winaday/domain.dart';
import 'package:package_info_plus/package_info_plus.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:quiver/collection.dart';
import 'package:launch_review/launch_review.dart';
import 'package:winaday/journey/journey.dart';
import 'package:winaday/services/local_data.dart';
import 'services/google_sign_in.dart';
import 'services/session_api.dart';
import 'package:uuid/uuid.dart';
import 'messages.dart';
import 'dateutil.dart';

// This is the only place where side-effects are allowed!

var uuid = const Uuid();

LruMap cache = LruMap(maximumSize: 100);
LruMap listCache = LruMap(maximumSize: 100);
LruMap calendarCache = LruMap(maximumSize: 100);
LruMap statsCache = LruMap(maximumSize: 100);
LruMap insightsCache = LruMap(maximumSize: 100);
PriorityListData? cachedPriorities;

bool savedWinInCurrentSession = false;
int savedWinsLastTwoWeeksOnStart = 0;

@immutable
abstract class Command {
  void execute(void Function(Message) dispatch);

  static Command none() {
    return None();
  }

  static Command getInitialCommand() {
    return InitializeApp();
  }
}

@immutable
class None implements Command {
  @override
  void execute(void Function(Message) dispatch) {}
}

@immutable
class CommandList implements Command {
  final List<Command> items;

  const CommandList(this.items);

  @override
  void execute(void Function(Message) dispatch) {
    for (var cmd in items) {
      cmd.execute(dispatch);
    }
  }
}

@immutable
class InitializeApp implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();

    Firebase.initializeApp()
        .then((app) => Future<FirebaseApp>.delayed(
              const Duration(milliseconds: 500),
              () => app,
            ))
        .then((_) {
      GoogleSignInFacade.subscribeToIdTokenChanges(
        (_) {
          dispatch(UserSignedIn(today));
        },
        () {
          killSession();
          dispatch(UserSignedOut());
        },
        (err) {
          killSession();
          dispatch(SignInFailed(err.toString()));
        },
      );
    }).catchError((err) {
      dispatch(AppInitializationFailed(err.toString()));
    });

    PackageInfo.fromPlatform().then((PackageInfo packageInfo) {
      Journey.initialize(
          'e04b43c9-69c1-4172-9dfd-a3ef1aa17d5e',
          '663b16c8-c35e-4887-b964-35a74e5732d2',
          packageInfo.version,
          kReleaseMode);
    });
  }
}

@immutable
class SignIn implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    GoogleSignInFacade.signInWithGoogle().catchError((err) {
      killSession();
      dispatch(SignInFailed(err.toString()));
    });
  }
}

@immutable
class SignOut implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    cache.clear();
    listCache.clear();
    calendarCache.clear();
    statsCache.clear();
    insightsCache.clear();
    cachedPriorities = null;
    killSession();
    GoogleSignInFacade.signOut().then((_) {
      dispatch(UserSignedOut());
    }).catchError((err) {
      dispatch(UserSignedOut());
    });
  }
}

@immutable
class LoadDailyWinWithInitialData implements Command {
  final DateTime date;

  const LoadDailyWinWithInitialData(this.date);

  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();
    bool editable = date.isSameDate(today) || date.isBefore(today);

    loadPriorities().then((priorityList) {
      // Load 2 weeks in advance, up to requested day (which is normally today)
      var from = DateTime(date.year, date.month, date.day - 13);
      var to = DateTime(date.year, date.month, date.day);

      var intervalKey = '${from.toCompact()}-${to.toCompact()}';

      return getWins(
              from.toCompact(), to.toCompact(), GoogleSignInFacade.getIdToken)
          .then((json) async {
        var winList = WinListData.fromJson(json);
        savedWinsLastTwoWeeksOnStart = winList.items.length;

        // uncomment if need to test review flow
        // await LocalData.resetReviewFlowCompleted();

        // udpate caches
        listCache[intervalKey] = winList.items;
        feedDailyWinCacheFromWinList(from, to, winList);

        var win = WinData.empty();
        if (winList.items.isNotEmpty &&
            winList.items.last.date.isSameDate(date)) {
          win = winList.items.last.win;
        }
        dispatch(DailyWinViewInitialDataLoaded(
            date, today, priorityList, winList.items, win, editable));
      });
    }).catchError((err) {
      dispatch(DailyWinViewLoadingFailed(date, today, err.toString()));
    });
  }
}

@immutable
class LoadDailyWin implements Command {
  final DateTime date;

  const LoadDailyWin(this.date);

  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () => loadDailyWin(dispatch));
  }

  Future<void> loadDailyWin(void Function(Message) dispatch) async {
    var today = DateTime.now();
    bool editable = date.isSameDate(today) || date.isBefore(today);
    bool askForReview = await shouldToAskForReview();

    try {
      var priorityList = await loadPriorities();

      if (!editable) {
        dispatch(DailyWinViewLoaded(date, today, priorityList, WinData.empty(),
            editable, askForReview));
        return;
      }

      var dateKey = date.toCompact();
      if (cache.containsKey(dateKey)) {
        dispatch(DailyWinViewLoaded(
            date, today, priorityList, cache[dateKey], editable, askForReview));
        return;
      }

      var json = await getWin(dateKey, GoogleSignInFacade.getIdToken);
      var winData = WinData.fromJson(json);
      cache[dateKey] = winData;
      dispatch(DailyWinViewLoaded(
          date, today, priorityList, winData, editable, askForReview));
    } catch (err) {
      dispatch(DailyWinViewLoadingFailed(date, today, err.toString()));
    }
  }

  Future<bool> shouldToAskForReview() async {
    if (!savedWinInCurrentSession) {
      return false;
    }

    if (savedWinsLastTwoWeeksOnStart < 6) {
      return false;
    }

    var reviewFlowCompleted = await LocalData.reviewFlowCompleted();
    return !reviewFlowCompleted;
  }
}

@immutable
class SaveWin implements Command {
  final DateTime date;
  final WinData win;

  const SaveWin(this.date, this.win);

  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();

    var dateKey = date.toCompact();
    var monthKey = getFirstDayOfMonth(date).toCompact();

    postWin(dateKey, win, GoogleSignInFacade.getIdToken).then((_) {
      cache[dateKey] = win;
      listCache.clear();
      calendarCache.remove(monthKey);
      statsCache.clear();
      insightsCache.clear();
      savedWinInCurrentSession = true;
      dispatch(WinSaved(date, today));
    }).catchError((err) {
      dispatch(SavingWinFailed(date, win, err.toString()));
    });
  }
}

@immutable
class LoadPriorities implements Command {
  final DateTime date;

  const LoadPriorities(this.date);

  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();
    loadPriorities().then((priorityList) {
      dispatch(PrioritiesLoaded(date, today, priorityList));
    }).catchError((err) {
      dispatch(PrioritiesLoadingFailed(date, today, err.toString()));
    });
  }
}

@immutable
class CreateNewPriority implements Command {
  final DateTime date;
  final DateTime today;
  final PriorityListData priorityList;

  const CreateNewPriority(this.date, this.today, this.priorityList);

  @override
  void execute(void Function(Message) dispatch) {
    var newPriority = PriorityData(uuid.v4(), "", 0, false);
    var newPriorityList =
        PriorityListData(List.from(priorityList.items)..add(newPriority));

    Future<void>.delayed(Duration.zero, () {
      dispatch(NewPriorityCreated(date, today, newPriorityList, newPriority));
    });
  }
}

@immutable
class SavePriorities implements Command {
  final DateTime date;
  final PriorityListData priorityList;

  const SavePriorities(this.date, this.priorityList);

  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();

    postPriorities(priorityList, GoogleSignInFacade.getIdToken).then((_) {
      cachedPriorities = priorityList;
      dispatch(PrioritiesSaved(date, today));
    }).catchError((err) {
      dispatch(SavingPrioritiesFailed(date, priorityList, err.toString()));
    });
  }
}

Future<PriorityListData> loadPriorities() async {
  if (cachedPriorities != null) {
    return Future<PriorityListData>.delayed(Duration.zero, () {
      return cachedPriorities!;
    });
  }

  return getPriorities(GoogleSignInFacade.getIdToken).then((json) {
    var priorityList = PriorityListData.fromJson(json);
    cachedPriorities = priorityList;
    return priorityList;
  });
}

@immutable
class LoadWinListFirstPage implements Command {
  final DateTime date;
  final DateTime from;
  final DateTime to;

  const LoadWinListFirstPage(this.date, this.from, this.to);

  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();

    loadPriorities().then((priorityList) {
      var intervalKey = '${from.toCompact()}-${to.toCompact()}';

      if (listCache.containsKey(intervalKey)) {
        return Future<void>.delayed(Duration.zero, () {
          dispatch(WinListFirstPageLoaded(
              date, today, priorityList, from, to, listCache[intervalKey]));
        });
      }

      return getWins(
              from.toCompact(), to.toCompact(), GoogleSignInFacade.getIdToken)
          .then((json) {
        var winList = WinListData.fromJson(json);

        // udpate caches
        listCache[intervalKey] = winList.items;
        feedDailyWinCacheFromWinList(from, to, winList);

        dispatch(WinListFirstPageLoaded(
            date, today, priorityList, from, to, winList.items));
      });
    }).catchError((err) {
      dispatch(
          WinListFirstPageLoadingFailed(date, today, from, to, err.toString()));
    });
  }
}

@immutable
class LoadWinListNextPage implements Command {
  final DateTime from;
  final DateTime to;

  const LoadWinListNextPage(this.from, this.to);

  @override
  void execute(void Function(Message) dispatch) {
    var intervalKey = '${from.toCompact()}-${to.toCompact()}';

    if (listCache.containsKey(intervalKey)) {
      Future<void>.delayed(Duration.zero, () {
        dispatch(WinListNextPageLoaded(from, to, listCache[intervalKey]));
      });
      return;
    }

    getWins(from.toCompact(), to.toCompact(), GoogleSignInFacade.getIdToken)
        .then((json) {
      var winList = WinListData.fromJson(json);

      // udpate caches
      listCache[intervalKey] = winList.items;
      feedDailyWinCacheFromWinList(from, to, winList);

      dispatch(WinListNextPageLoaded(from, to, winList.items));
    }).catchError((err) {
      dispatch(WinListNextPageLoadingFailed(err.toString()));
    });
  }
}

@immutable
class LoadWinDays implements Command {
  final DateTime month;

  const LoadWinDays(this.month);

  @override
  void execute(void Function(Message) dispatch) {
    var from = getFirstDayOfMonth(month);
    var to = getLastDayOfMonth(month);

    var today = DateTime.now();
    bool editable = from.isSameDate(today) || from.isBefore(today);
    if (!editable) {
      Future<void>.delayed(Duration.zero, () {
        dispatch(CalendarViewDaysWithWinsReceived(month, WinDaysData.empty()));
      });
      return;
    }

    var monthKey = from.toCompact();

    if (calendarCache.containsKey(monthKey)) {
      Future<void>.delayed(Duration.zero, () {
        dispatch(
            CalendarViewDaysWithWinsReceived(month, calendarCache[monthKey]));
      });
      return;
    }

    getWinDays(from.toCompact(), to.toCompact(), GoogleSignInFacade.getIdToken)
        .then((json) {
      var winDays = WinDaysData.fromJson(json);
      calendarCache[monthKey] = winDays;
      dispatch(CalendarViewDaysWithWinsReceived(month, winDays));
    }).catchError((err) {
      // Ignore
    });
  }
}

@immutable
class LoadStats implements Command {
  final DateTime date;
  final DateTime from;
  final DateTime to;

  const LoadStats(this.date, this.from, this.to);

  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();
    bool hasStats = to.isSameMonth(today) || to.isBefore(today);

    loadPriorities().then((priorityList) {
      if (!hasStats) {
        return Future<void>.delayed(Duration.zero, () {
          dispatch(StatsLoaded(
              date, today, from, to, priorityList, WinListShortData.empty()));
        });
      }

      var intervalKey = '${from.toCompact()}-${to.toCompact()}';
      if (statsCache.containsKey(intervalKey)) {
        return Future<void>.delayed(Duration.zero, () {
          dispatch(StatsLoaded(
              date, today, from, to, priorityList, statsCache[intervalKey]));
        });
      }

      return getStats(
              from.toCompact(), to.toCompact(), GoogleSignInFacade.getIdToken)
          .then((json) {
        var stats = WinListShortData.fromJson(json);
        statsCache[intervalKey] = stats;
        dispatch(StatsLoaded(date, today, from, to, priorityList, stats));
      });
    }).catchError((err) {
      dispatch(StatsLoadingFailed(date, today, from, to, err.toString()));
    });
  }
}

feedDailyWinCacheFromWinList(DateTime from, DateTime to, WinListData winList) {
  var winsByDate = {for (var x in winList.items) x.date.toCompact(): x.win};

  var day = from;
  while (day.isBefore(to) || day.isSameDate(to)) {
    var dateKey = day.toCompact();
    var win = winsByDate[dateKey] ?? WinData.empty();
    cache[dateKey] = win;
    day = day.nextDay();
  }
}

@immutable
class NavigateToRatingInAppStore implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(
            Duration.zero, () => LocalData.setReviewFlowCompleted())
        .then((_) => LaunchReview.launch());
  }
}

@immutable
class NeverAskForReviewAgain implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(
        Duration.zero, () => LocalData.setReviewFlowCompleted());
  }
}

@immutable
class LoadInsightData implements Command {
  final DateTime date;
  final DateTime from;
  final DateTime to;

  const LoadInsightData(this.date, this.from, this.to);

  @override
  void execute(void Function(Message) dispatch) {
    Future<void>.delayed(Duration.zero, () => loadData(dispatch));
  }

  Future<void> loadData(void Function(Message) dispatch) async {
    var today = DateTime.now();
    bool validPeriod = to.isSameMonth(today) || to.isBefore(today);

    try {
      var priorityList = await loadPriorities();
      if (!validPeriod) {
        dispatch(InsightsLoaded(
            date, today, from, to, priorityList, WinListShortData.empty()));
        return;
      }

      var intervalKey = '${from.toCompact()}-${to.toCompact()}';
      if (insightsCache.containsKey(intervalKey)) {
        dispatch(InsightsLoaded(
            date, today, from, to, priorityList, insightsCache[intervalKey]));
        return;
      }

      var json = await getStats(
          from.toCompact(), to.toCompact(), GoogleSignInFacade.getIdToken);
      var data = WinListShortData.fromJson(json);
      insightsCache[intervalKey] = data;
      dispatch(InsightsLoaded(date, today, from, to, priorityList, data));
    } catch (err) {
      dispatch(InsightsLoadingFailed(date, today, from, to, err.toString()));
    }
  }
}
