import 'package:firebase_core/firebase_core.dart';
import 'package:winaday/domain.dart';
import 'package:intl/intl.dart';
import 'services/google_sign_in.dart';
import 'services/session_api.dart';
import 'messages.dart';

// This is the only place where side-effects are allowed!

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
              const Duration(seconds: 2),
              () => app,
            ))
        .then((_) {
      GoogleSignInFacade.subscribeToIdTokenChanges(
        (idToken) {
          setIdToken(idToken);
          dispatch(UserSignedIn(today, idToken));
        },
        () {
          cleanIdToken();
          dispatch(UserSignedOut());
        },
        (err) {
          cleanIdToken();
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
      cleanIdToken();
      dispatch(SignInFailed(err.toString()));
    });
  }
}

class SignOut implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    cleanIdToken();
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

    getWin(toCompact(date)).then((json) {
      var winData = WinData.fromJson(json);
      dispatch(DailyWinViewLoaded(date, today, winData));
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

    postWin(toCompact(date), win).then((_) {
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
