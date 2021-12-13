import 'package:winaday/domain.dart';

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

ModelAndCommand reduce(Model model, Message message) {
  if (message is AppInitializedNotSignedIn) {
    return ModelAndCommand.justModel(UserNotSignedInModel(false, false));
  }
  if (message is UserConsentUpdated) {
    return ModelAndCommand.justModel(UserNotSignedInModel(
        message.privacyPolicyAccepted, message.personalDataProcessingAccepted));
  }
  if (message is AppInitializationFailed) {
    return ModelAndCommand.justModel(
        ApplicationFailedToInitializeModel(message.reason));
  }

  if (message is SignInRequested) {
    return ModelAndCommand(SignInInProgressModel(), SignIn());
  }
  if (message is UserSignedIn) {
    return ModelAndCommand(DailyWinLoadingModel(message.today, message.today),
        LoadDailyWin(message.today));
  }
  if (message is SignInFailed) {
    return ModelAndCommand.justModel(UserFailedToSignInModel(message.reason));
  }
  if (message is SignOutRequested) {
    return ModelAndCommand(SignOutInProgressModel(), SignOut());
  }
  if (message is UserSignedOut) {
    return ModelAndCommand.justModel(UserNotSignedInModel(false, false));
  }

  if (message is DailyWinViewLoaded) {
    return ModelAndCommand.justModel(
        DailyWinModel(message.date, message.today, message.win));
  }
  if (message is DailyWinViewLoadingFailed) {
    return ModelAndCommand.justModel(
        DailyWinFailedToLoadModel(message.date, message.today, message.reason));
  }
  if (message is DailyWinViewReloadRequested) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is EditWinRequested) {
    var winToEdit = WinData(
        message.win.text,
        message.win.overallResult == OverallDayResult.noWinYet
            ? OverallDayResult.gotMyWin
            : message.win.overallResult);
    return ModelAndCommand.justModel(
        WinEditorModel(message.date, message.today, winToEdit));
  }
  if (message is CancelEditingWinRequested) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is WinSaveRequested) {
    return ModelAndCommand(
        WinEditorSavingModel(message.date), SaveWin(message.date, message.win));
  }
  if (message is WinSaved) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is SavingWinFailed) {
    return ModelAndCommand.justModel(
        WinEditorFailedToSaveModel(message.date, message.win, message.reason));
  }

  if (message is MoveToPrevDay) {
    DateTime newDate = message.date.subtract(const Duration(days: 1));
    return ModelAndCommand(
        DailyWinLoadingModel(newDate, message.today), LoadDailyWin(newDate));
  }
  if (message is MoveToNextDay) {
    DateTime newDate = message.date.add(const Duration(days: 1));
    return ModelAndCommand(
        DailyWinLoadingModel(newDate, message.today), LoadDailyWin(newDate));
  }
  if (message is MoveToDay) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }

  return ModelAndCommand.justModel(model);
}
