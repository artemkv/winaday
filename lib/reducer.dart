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
  if (message is ReInitializationRequested) {
    return ModelAndCommand(ApplicationNotInitializedModel(), InitializeApp());
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
    return ModelAndCommand.justModel(DailyWinModel(message.date, message.today,
        message.priorityList, message.win, message.editable));
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
            : message.win.overallResult,
        message.win.priorities);
    return ModelAndCommand.justModel(
        WinEditorModel(message.date, message.today, winToEdit));
  }
  if (message is CancelEditingWinRequested) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is WinChangesConfirmed) {
    if (message.win.priorities.isEmpty) {
      return ModelAndCommand(WinEditorSavingModel(message.date),
          LoadPrioritiesForLinking(message.date, message.win));
    } else {
      return ModelAndCommand(WinEditorSavingModel(message.date),
          SaveWin(message.date, message.win));
    }
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
  if (message is MoveToPrevWeek) {
    DateTime newDate = message.date.subtract(const Duration(days: 7));
    return ModelAndCommand(
        DailyWinLoadingModel(newDate, message.today), LoadDailyWin(newDate));
  }
  if (message is MoveToNextWeek) {
    DateTime newDate = message.date.add(const Duration(days: 7));
    return ModelAndCommand(
        DailyWinLoadingModel(newDate, message.today), LoadDailyWin(newDate));
  }
  if (message is MoveToDay) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }

  if (message is NavigateToPrioritiesRequested) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        LoadPriorities(message.date));
  }
  if (message is PrioritiesLoadingFailed) {
    return ModelAndCommand.justModel(PrioritiesFailedToLoadModel(
        message.date, message.today, message.reason));
  }
  if (message is PrioritiesReloadRequested) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        LoadPriorities(message.date));
  }
  if (message is ExitPrioritiesRequested) {
    return ModelAndCommand(DailyWinLoadingModel(message.date, message.today),
        LoadDailyWin(message.date));
  }
  if (message is PrioritiesLoaded) {
    return ModelAndCommand.justModel(PrioritiesModel(
        message.date,
        message.today,
        message.priorityList,
        canAddMorePriorities(message.priorityList)));
  }
  if (message is EditPrioritiesRequested) {
    return ModelAndCommand.justModel(
        EditPrioritiesModel(message.date, message.today, message.priorityList));
  }
  if (message is PrioritiesReorderRequested) {
    var reordered = message.priorityList.items.map((e) {
      if (e.id == message.priority.id) {
        return message.exchangeWith;
      } else if (e.id == message.exchangeWith.id) {
        return message.priority;
      } else {
        return e;
      }
    });

    return ModelAndCommand.justModel(EditPrioritiesModel(
        message.date, message.today, PriorityListData(List.from(reordered))));
  }
  if (message is DeletePriorityRequested) {
    var updatedList = message.priorityList.items.map((e) {
      if (e.id == message.priority.id) {
        return PriorityData(message.priority.id, message.priority.text,
            message.priority.color, true);
      } else {
        return e;
      }
    });

    return ModelAndCommand.justModel(EditPrioritiesModel(
        message.date, message.today, PriorityListData(List.from(updatedList))));
  }
  if (message is SaveChangesInPrioritiesRequested) {
    return ModelAndCommand(PrioritiesSavingModel(message.date),
        SavePriorities(message.date, message.priorityList));
  }
  if (message is CancelEditingPrioritiesRequested) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        LoadPriorities(message.date));
  }

  if (message is EditExistingPriorityRequested) {
    return ModelAndCommand.justModel(PriorityEditorModel(
        message.date, message.today, message.priorityList, message.priority));
  }
  if (message is EditNewPriorityRequested) {
    return ModelAndCommand(
        CreatingNewPriorityModel(message.date, message.today),
        CreateNewPriority(message.date, message.today, message.priorityList));
  }
  if (message is NewPriorityCreated) {
    return ModelAndCommand.justModel(PriorityEditorModel(
        message.date, message.today, message.priorityList, message.priority));
  }
  if (message is CancelEditingPriorityRequested) {
    return ModelAndCommand(PrioritiesLoadingModel(message.date, message.today),
        LoadPriorities(message.date));
  }
  if (message is PrioritySaveRequested) {
    var updatedList = message.priorityList.items.map((e) {
      if (e.id == message.priority.id) {
        return message.priority;
      } else {
        return e;
      }
    });

    return ModelAndCommand(PrioritiesSavingModel(message.date),
        SavePriorities(message.date, PriorityListData(List.from(updatedList))));
  }
  if (message is SavingPrioritiesFailed) {
    return ModelAndCommand.justModel(PriorityEditorFailedToSaveModel(
        message.date, message.priorityList, message.reason));
  }

  if (message is LinkWinToPriorities) {
    return ModelAndCommand.justModel(EditWinPrioritiesModel(
        message.date, message.today, message.priorityList, message.win));
  }
  if (message is ToggleWinPriority) {
    Map<String, PriorityData> udpatedPriorities;
    if (message.win.priorities.containsKey(message.priority.id)) {
      udpatedPriorities = {
        for (var item in message.win.priorities.values
            .where((x) => x.id != message.priority.id))
          item.id: item
      };
    } else {
      udpatedPriorities = {
        for (var item in message.win.priorities.values) item.id: item
      };
      udpatedPriorities[message.priority.id] = message.priority;
    }

    var updatedWin =
        WinData(message.win.text, message.win.overallResult, udpatedPriorities);

    return ModelAndCommand.justModel(EditWinPrioritiesModel(
        message.date, message.today, message.priorityList, updatedWin));
  }

  return ModelAndCommand.justModel(model);
}

bool canAddMorePriorities(PriorityListData priorityList) {
  return priorityList.items
          .where((element) => !element.deleted)
          .toList()
          .length <
      9;
}
