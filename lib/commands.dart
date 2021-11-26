import 'messages.dart';

// This is the only place where side-effects are allowed!

abstract class Command {
  void execute(void Function(Message) dispatch);

  static Command none() {
    return None();
  }

  static Command getInitialCommand() {
    return LoadTodaysWin();
  }
}

class None implements Command {
  @override
  void execute(void Function(Message) dispatch) {}
}

class LoadTodaysWin implements Command {
  @override
  void execute(void Function(Message) dispatch) {
    var date = DateTime.now();

    Future.delayed(
      const Duration(seconds: 2),
      () => 'My win today retrieved asynchronously',
    ).then((value) {
      dispatch(DailyWinViewLoaded(date, value));
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
      () => 'My win saved',
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
