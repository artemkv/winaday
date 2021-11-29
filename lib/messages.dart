// Should all be immutable classes and no logic!

import 'domain.dart';

abstract class Message {}

class AppInitializedNotSignedIn implements Message {}

class AppInitializationFailed implements Message {
  final String reason;

  AppInitializationFailed(this.reason);
}

class SignInRequested implements Message {}

class UserSignedIn implements Message {
  final DateTime date;
  final String tokenId;

  UserSignedIn(this.date, this.tokenId);
}

class SignInFailed implements Message {
  final String reason;

  SignInFailed(this.reason);
}

class SignOutRequested implements Message {}

class UserSignedOut implements Message {}

class DailyWinViewLoaded implements Message {
  final DateTime date;
  final WinData win;

  DailyWinViewLoaded(this.date, this.win);
}

class EditWinRequested implements Message {
  final DateTime date;
  final WinData win;

  EditWinRequested(this.date, this.win);
}

class WinSaveRequested implements Message {
  final DateTime date;
  final WinData win;

  WinSaveRequested(this.date, this.win);
}

class WinSaved implements Message {
  final DateTime date;

  WinSaved(this.date);
}
