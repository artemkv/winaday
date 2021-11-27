import 'package:firebase_core/firebase_core.dart';
import 'messages.dart';
import 'services/google_sign_in.dart';

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
          dispatch(UserSignedIn(DateTime.now(), idToken));
        },
        () {
          dispatch(UserSignedOut());
        },
        (err) {
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
      dispatch(SignInFailed(err.toString()));
    });
  }
}

class SignOut implements Command {
  @override
  void execute(void Function(Message) dispatch) {
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
    Future.delayed(
      const Duration(seconds: 2),
      () => 'My win today retrieved asynchronously',
    ).then((value) {
      dispatch(DailyWinViewLoaded(date, value));
    });
  }
}

class SaveWin implements Command {
  final DateTime date;
  final String win;

  SaveWin(this.date, this.win);

  @override
  void execute(void Function(Message) dispatch) {
    Future.delayed(
      const Duration(seconds: 2),
      () {
        dispatch(WinSaved(date));
      },
    );
  }
}
