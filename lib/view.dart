import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:winaday/domain.dart';
import 'model.dart';
import 'messages.dart';
import 'theme.dart';

// These should be all stateless! No side effects allowed!

const TEXT_PADDING = 12.0;
const TEXT_FONT_SIZE = 16.0;
const THEME_COLOR = oceanPurple;

Widget home(Model model, void Function(Message) dispatch) {
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
    return dailyWinLoading(model, dispatch);
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
  return welcomeScreen(false, () {});
}

Widget applicationFailedToInitialize(ApplicationFailedToInitializeModel model) {
  return Text("Failed to initialize: " + model.reason);
}

Widget userNotSignedIn(void Function(Message) dispatch) {
  return welcomeScreen(true, () {
    dispatch(SignInRequested());
  });
}

Widget welcomeScreen(bool showSignInButton, void Function() onSignInClick) {
  return Material(
    type: MaterialType.transparency,
    child: Container(
        decoration: const BoxDecoration(color: THEME_COLOR),
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    "All you need is",
                    style: GoogleFonts.yesevaOne(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                  ),
                  Text(
                    "one win a day",
                    style: GoogleFonts.yesevaOne(
                        textStyle: const TextStyle(
                            color: Colors.white,
                            fontSize: 40,
                            fontWeight: FontWeight.bold)),
                  ),
                  Visibility(
                      visible: showSignInButton,
                      maintainState: true,
                      maintainAnimation: true,
                      maintainSize: true,
                      child: Padding(
                          padding: const EdgeInsets.all(12.0),
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                primary: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 20, vertical: 10)),
                            onPressed: () {
                              onSignInClick();
                            },
                            child: const Text("Sign in",
                                style: TextStyle(
                                    color: THEME_COLOR,
                                    fontSize: 24,
                                    fontWeight: FontWeight.bold)),
                          )))
                ]))),
  );
}

Widget signInInProgress() {
  return Material(
      type: MaterialType.transparency,
      child: Container(
          decoration: const BoxDecoration(color: THEME_COLOR),
          child: Column(
            children: const [],
          )));
}

// TODO:
Widget signOutInProgress() {
  return Column(
    children: const [],
  );
}

Widget dailyWinLoading(
    DailyWinLoadingModel model, void Function(Message) dispatch) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('One win a day'),
    ),
    body: Center(
        // TODO: single-source
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [CircularProgressIndicator(value: null)])),
  );
}

// TODO: add the calendar etc.
Widget dailyWin(DailyWinModel model, void Function(Message) dispatch) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('One win a day'),
        actions: [
          PopupMenuButton(
            itemBuilder: (context) => [
              const PopupMenuItem<int>(
                value: 0,
                child: Text("Sign out"),
              ),
            ],
            onSelected: (val) {
              if (val == 0) {
                // this is if you add more items
                dispatch(SignOutRequested());
              }
            },
          )
        ],
      ),
      body: Center(
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(TEXT_PADDING),
              child: Text(
                model.win.text,
                style: const TextStyle(fontSize: TEXT_FONT_SIZE),
              ))
        ]),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dispatch(EditWinRequested(model.date, model.win));
        },
        child: const Icon(Icons.edit),
        backgroundColor: melonYellow,
      ));
}

Widget winEditor(WinEditorModel model, void Function(Message) dispatch) {
  TextEditingController controller = TextEditingController()
    ..text = model.win.text;

  return Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('Edit win'),
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Save',
          onPressed: () {
            var updatedWin = WinData(model.win.text + "_upd");
            dispatch(WinSaveRequested(model.date, updatedWin));
          },
        )
      ],
    ),
    body: WillPopScope(
        onWillPop: () async {
          dispatch(CancelEditingWinRequested(model.date));
          return false;
        },
        child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(TEXT_PADDING),
              child: TextField(
                controller: controller,
                style: const TextStyle(fontSize: TEXT_FONT_SIZE),
                maxLines: null,
                keyboardType: TextInputType.multiline,
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    hintText: 'Write down you win here'),
              ))
        ])),
  );
}

Widget winEditorSaving(WinEditorSavingModel model) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('One win a day'),
    ),
    body: Center(
        // TODO: single-source
        child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: const [CircularProgressIndicator(value: null)])),
  );
}
