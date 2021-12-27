import 'package:firebase_core/firebase_core.dart';
import 'package:winaday/domain.dart';
import 'package:intl/intl.dart';
// ignore: import_of_legacy_library_into_null_safe
import 'package:quiver/collection.dart';
import 'services/google_sign_in.dart';
import 'services/session_api.dart';
import 'messages.dart';
import 'dateutil.dart';

// This is the only place where side-effects are allowed!

LruMap cache = LruMap(maximumSize: 100);

abstract class Command {
  void execute(void Function(Message) dispatch);

  static Command none() {
    return None();
  }

  static Command getInitialCommand() {
    return InitializeApp();
  }
}

class None implements Command {
  @override
  void execute(void Function(Message) dispatch) {}
}

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

class SignIn implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    GoogleSignInFacade.signInWithGoogle().catchError((err) {
      killSession();
      dispatch(SignInFailed(err.toString()));
    });
  }
}

class SignOut implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    cache.clear();
    killSession();
    GoogleSignInFacade.signOut().then((_) {
      dispatch(UserSignedOut());
    }).catchError((err) {
      dispatch(UserSignedOut());
    });
  }
}

class LoadDailyWin implements Command {
  final DateTime date;

  LoadDailyWin(this.date);

  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();
    bool editable = date.isSameDate(today) || date.isBefore(today);

    if (!editable) {
      Future<void>.delayed(Duration.zero, () {
        dispatch(DailyWinViewLoaded(date, today, WinData.empty(), editable));
      });
      return;
    }

    var dateKey = toCompact(date);

    if (cache.containsKey(dateKey)) {
      Future<void>.delayed(Duration.zero, () {
        dispatch(DailyWinViewLoaded(date, today, cache[dateKey], editable));
      });
      return;
    }

    getWin(dateKey, GoogleSignInFacade.getIdToken).then((json) {
      var winData = WinData.fromJson(json);
      cache[dateKey] = winData;
      dispatch(DailyWinViewLoaded(date, today, winData, editable));
    }).catchError((err) {
      dispatch(DailyWinViewLoadingFailed(
          date, today, err?.message ?? "Unknown error"));
    });
  }
}

class SaveWin implements Command {
  final DateTime date;
  final WinData win;

  SaveWin(this.date, this.win);

  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();

    var dateKey = toCompact(date);

    postWin(dateKey, win, GoogleSignInFacade.getIdToken).then((_) {
      cache[dateKey] = win;
      dispatch(WinSaved(date, today));
    }).catchError((err) {
      dispatch(SavingWinFailed(date, win, err?.message ?? "Unknown error"));
    });
  }
}

String toCompact(DateTime date) {
  final DateFormat formatter = DateFormat('yyyyMMdd');
  return formatter.format(date);
}

class LoadPriorities implements Command {
  final DateTime date;

  LoadPriorities(this.date);

  @override
  void execute(void Function(Message) dispatch) {
    var today = DateTime.now();
    getPriorities(GoogleSignInFacade.getIdToken).then((json) {
      var priorityList = PriorityListData.fromJson(json);
      dispatch(PrioritiesLoaded(date, today, priorityList));
    }).catchError((err) {
      dispatch(PrioritiesLoadingFailed(
          date, today, err?.message ?? "Unknown error"));
    });
  }
}
