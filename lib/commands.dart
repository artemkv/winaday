import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:winaday/domain.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:quiver/collection.dart';
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
PriorityListData? cachedPriorities;

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
class LoadDailyWin implements Command {
  final DateTime date;

  const LoadDailyWin(this.date);

  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();
    bool editable = date.isSameDate(today) || date.isBefore(today);

    loadPriorities().then((priorityList) {
      if (!editable) {
        return Future<void>.delayed(Duration.zero, () {
          dispatch(DailyWinViewLoaded(
              date, today, priorityList, WinData.empty(), editable));
        });
      }

      var dateKey = date.toCompact();

      if (cache.containsKey(dateKey)) {
        return Future<void>.delayed(Duration.zero, () {
          dispatch(DailyWinViewLoaded(
              date, today, priorityList, cache[dateKey], editable));
        });
      }

      return getWin(dateKey, GoogleSignInFacade.getIdToken).then((json) {
        var winData = WinData.fromJson(json);
        cache[dateKey] = winData;
        dispatch(
            DailyWinViewLoaded(date, today, priorityList, winData, editable));
      });
    }).catchError((err) {
      dispatch(DailyWinViewLoadingFailed(date, today, err.toString()));
    });
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

    postWin(dateKey, win, GoogleSignInFacade.getIdToken).then((_) {
      cache[dateKey] = win;
      listCache.clear();
      calendarCache.clear();
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
      dispatch(NavigateToPrioritiesRequested(date, today));
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
        listCache[intervalKey] = winList.items;
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
      listCache[intervalKey] = winList.items;
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
      // TODO:
      /*dispatch(DailyWinViewLoadingFailed(
          DateTime.now(), DateTime.now(), err.toString()));*/
      // dispatch(WinListNextPageLoadingFailed(err.toString()));
    });
  }
}
