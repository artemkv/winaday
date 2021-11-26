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
    ).then((value) => dispatch(DailyWinViewLoaded(date, value)));
  }
}
