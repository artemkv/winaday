import 'package:firebase_core/firebase_core.dart';
import 'package:winaday/domain.dart';
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
    Firebase.initializeApp().then((_) {
      GoogleSignInFacade.subscribeToIdTokenChanges(
        (idToken) {
          setIdToken(idToken);
          dispatch(UserSignedIn(DateTime.now(), idToken));
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
    getWin().then((json) {
      var winData = WinData.fromJson(json);
      dispatch(DailyWinViewLoaded(date, winData));
    }).catchError((err) {
      // TODO: dispatch DailyWinViewLoadingFailed
    });
  }
}

class SaveWin implements Command {
  final DateTime date;
  final WinData win;

  SaveWin(this.date, this.win);

  @override
  void execute(void Function(Message) dispatch) {
    postWin(win).then((_) {
      dispatch(WinSaved(date));
    }).catchError((err) {
      // TODO: dispatch SavingWinFailed
    });
  }
}
