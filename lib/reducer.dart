import 'model.dart';
import 'messages.dart';
import 'commands.dart';

class ModelAndCommand {
  final Model model;
  final Command command;

  ModelAndCommand(this.model, this.command);
  ModelAndCommand.justModel(Model model) : this(model, Command.none());
}

// reduce must be a pure function!

class Reducer {
  static ModelAndCommand reduce(Model model, Message message) {
    if (message is AppInitializedNotSignedIn) {
      return ModelAndCommand.justModel(UserNotSignedInModel());
    }
    if (message is AppInitializationFailed) {
      return ModelAndCommand.justModel(
          ApplicationFailedToInitializeModel(message.reason));
    }

    if (message is SignInRequested) {
      return ModelAndCommand(SignInInProgressModel(), SignIn());
    }
    if (message is UserSignedIn) {
      return ModelAndCommand(
          DailyWinLoadingModel(message.date), LoadDailyWin(message.date));
    }
    if (message is SignInFailed) {
      return ModelAndCommand.justModel(UserNotSignedInModel());
    }
    if (message is SignOutRequested) {
      return ModelAndCommand(SignOutInProgressModel(), SignOut());
    }
    if (message is UserSignedOut) {
      return ModelAndCommand.justModel(UserNotSignedInModel());
    }

    if (message is DailyWinViewLoaded) {
      return ModelAndCommand.justModel(
          DailyWinModel(message.date, message.win));
    }
    if (message is EditWinRequested) {
      return ModelAndCommand.justModel(
          WinEditorModel(message.date, message.win));
    }
    if (message is WinSaveRequested) {
      return ModelAndCommand(WinEditorSavingModel(message.date),
          SaveWin(message.date, message.win));
    }
    if (message is WinSaved) {
      return ModelAndCommand(
          DailyWinLoadingModel(message.date), LoadDailyWin(message.date));
    }
    return ModelAndCommand.justModel(model);
  }
}
