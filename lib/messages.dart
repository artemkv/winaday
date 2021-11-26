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
