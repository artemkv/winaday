// Should all be immutable classes and no logic!

abstract class Message {}

class DailyWinViewLoaded implements Message {
  final DateTime date;
  final String win;

  DailyWinViewLoaded(this.date, this.win);
}

class EditWinRequested implements Message {
  final DateTime date;
  final String win;

  EditWinRequested(this.date, this.win);
}

class WinSaveRequested implements Message {
  final DateTime date;
  final String win;

  WinSaveRequested(this.date, this.win);
}

class WinSaved implements Message {
  final DateTime date;

  WinSaved(this.date);
}
