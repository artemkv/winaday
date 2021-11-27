import 'package:flutter/material.dart';
import 'model.dart';
import 'messages.dart';

// These should be all stateless! No side effects allowed!

Widget home(Model model, void Function(Message) dispatch) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('Win a day'),
      ),
      body: body(model, dispatch));
}

Widget body(Model model, void Function(Message) dispatch) {
  if (model is ApplicationNotInitializedModel) {
    return applicationNotInitialized();
  }
  if (model is ApplicationFailedToInitializeModel) {
    return applicationFailedToInitialize(model);
  }

  if (model is UserNotSignedInModel) {
    return userNotSignedIn(dispatch);
  }
  if (model is SignInInProgressModel) {
    return signInInProgress();
  }
  if (model is SignOutInProgressModel) {
    return signOutInProgress();
  }

  if (model is DailyWinLoadingModel) {
    return dailyWinLoading(model);
  }
  if (model is DailyWinModel) {
    return dailyWin(model, dispatch);
  }
  if (model is WinEditorModel) {
    return winEditor(model, dispatch);
  }
  if (model is WinEditorSavingModel) {
    return winEditorSaving(model);
  }
  return unknownModel(model);
}

Widget unknownModel(Model model) {
  return Text("Unknown model: " + model.runtimeType.toString());
}

Widget applicationNotInitialized() {
  return Text("Not initialized, initializing...");
}

Widget applicationFailedToInitialize(ApplicationFailedToInitializeModel model) {
  return Text("Failed to initialize: " + model.reason);
}

Widget userNotSignedIn(void Function(Message) dispatch) {
  return Column(children: [
    Text("Welcome"),
    ElevatedButton(
      onPressed: () {
        dispatch(SignInRequested());
      },
      child: const Text('Sign in'),
    )
  ]);
}

Widget signInInProgress() {
  return Column(
    children: const [],
  );
}

Widget signOutInProgress() {
  return Column(
    children: const [],
  );
}

Widget dailyWinLoading(DailyWinLoadingModel model) {
  return Column(children: [Text("Loading data for " + model.date.toString())]);
}

Widget dailyWin(DailyWinModel model, void Function(Message) dispatch) {
  return Column(children: [
    GestureDetector(
      child: Text("DailyWin: " + model.win),
      onTap: () {
        dispatch(EditWinRequested(model.date, model.win));
      },
    ),
    ElevatedButton(
      onPressed: () {
        dispatch(SignOutRequested());
      },
      child: const Text('Sign out'),
    )
  ]);
}

Widget winEditor(WinEditorModel model, void Function(Message) dispatch) {
  return Column(children: [
    Text("Editor: " + model.win),
    ElevatedButton(
      onPressed: () {
        dispatch(WinSaveRequested(model.date, model.win));
      },
      child: const Text('Save'),
    )
  ]);
}

Widget winEditorSaving(WinEditorSavingModel model) {
  return Column(children: [Text("Saving... " + model.date.toString())]);
}
