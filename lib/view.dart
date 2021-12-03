import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:winaday/domain.dart';
import 'model.dart';
import 'messages.dart';
import 'theme.dart';
import 'dateutil.dart';

// These should be all stateless! No side effects allowed!

const TEXT_PADDING = 12.0;
const TEXT_FONT_SIZE = 16.0;
const THEME_COLOR = magenta;

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
  if (model is DailyWinFailedToLoadModel) {
    return dailyWinFailedToLoad(model, dispatch);
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
  if (model is WinEditorFailedToSaveModel) {
    return winEditorFailedToSave(model, dispatch);
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
  // TODO: nicer view for rendering this error
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

Widget signOutInProgress() {
  return Material(
      type: MaterialType.transparency,
      child: Container(
          decoration: const BoxDecoration(color: THEME_COLOR),
          child: Column(
            children: const [],
          )));
}

Widget dailyWinLoading(
    DailyWinLoadingModel model, void Function(Message) dispatch) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('One win a day'),
        elevation: 0.0,
        actions: contextMenu(dispatch),
      ),
      body: Center(
          child: Column(children: [
        calendarStripe(model.date, dispatch),
        Expanded(child: spinner())
      ])));
}

Widget dailyWinFailedToLoad(
    DailyWinFailedToLoadModel model, void Function(Message) dispatch) {
  return Scaffold(
      appBar: AppBar(
        title: const Text('One win a day'),
        elevation: 0.0,
        actions: contextMenu(dispatch),
      ),
      body: Center(
          child: Column(children: [
        calendarStripe(model.date, dispatch),
        // TODO: maybe think about nicer way to show errors
        Padding(
            padding: const EdgeInsets.all(TEXT_PADDING),
            child: Text("Failed to contact the server: " + model.reason,
                style: const TextStyle(
                    fontSize: TEXT_FONT_SIZE, color: Colors.red))),
        Expanded(
            child: GestureDetector(
                onTap: () {
                  dispatch(DailyWinViewReloadRequested(model.date));
                },
                child: const Center(
                    child: Text("Click to reload",
                        style: TextStyle(
                            fontSize: TEXT_FONT_SIZE, color: Colors.grey)))))
      ])));
}

Widget dailyWin(DailyWinModel model, void Function(Message) dispatch) {
  const yesterday = 1;
  const today = 2;
  const tomorrow = 3;

  final PageController controller = PageController(initialPage: today);

  return Scaffold(
      appBar: AppBar(
        title: const Text('One win a day'),
        elevation: 0.0,
        actions: contextMenu(dispatch),
      ),
      body: Column(children: [
        calendarStripe(model.date, dispatch),
        Expanded(
            child: Center(
                child: PageView.builder(
                    onPageChanged: (page) {
                      if (page == yesterday) {
                        dispatch(MoveToPrevDay(model.date));
                      } else if (page == tomorrow) {
                        dispatch(MoveToNextDay(model.date));
                      }
                    },
                    scrollDirection: Axis.horizontal,
                    controller: controller,
                    itemBuilder: (context, index) {
                      if (index == today) {
                        if (model.win.text == "") {
                          return const Padding(
                              padding: EdgeInsets.all(TEXT_PADDING),
                              child: Center(
                                  child: Text("No win recorded",
                                      style: TextStyle(
                                          fontSize: TEXT_FONT_SIZE,
                                          color: Colors.grey))));
                        }
                        return Padding(
                            padding: const EdgeInsets.all(TEXT_PADDING),
                            child: Text(model.win.text,
                                style:
                                    const TextStyle(fontSize: TEXT_FONT_SIZE)));
                      } else {
                        return const Padding(
                            padding: EdgeInsets.all(TEXT_PADDING),
                            child: Text("",
                                style: TextStyle(fontSize: TEXT_FONT_SIZE)));
                      }
                    })))
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          dispatch(EditWinRequested(model.date, model.win));
        },
        child: const Icon(Icons.edit),
        backgroundColor: denimBlue,
      ));
}

Widget calendarStripe(DateTime date, void Function(Message) dispatch) {
  return Container(
      decoration: const BoxDecoration(color: THEME_COLOR),
      child: Material(
          type: MaterialType.transparency,
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(
                    top: TEXT_PADDING, bottom: TEXT_PADDING * 2),
                child: Row(children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_left),
                      color: Colors.white,
                      tooltip: 'Prev',
                      onPressed: () {
                        dispatch(MoveToPrevDay(date));
                      }),
                  Expanded(
                      child: Center(
                          child: Padding(
                              padding: const EdgeInsets.all(8.0),
                              child: Column(children: [
                                Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(date.year.toString(),
                                        style: GoogleFonts.yesevaOne(
                                            textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 16.0)))),
                                Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Text(getDayString(date),
                                        style: GoogleFonts.yesevaOne(
                                            textStyle: const TextStyle(
                                                color: Colors.white,
                                                fontSize: 24.0))))
                              ])))),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    color: Colors.white,
                    tooltip: 'Next',
                    onPressed: () {
                      dispatch(MoveToNextDay(date));
                    },
                  )
                ]))
          ])));
}

List<Widget> contextMenu(void Function(Message) dispatch) {
  return <Widget>[
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
  ];
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
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(TEXT_PADDING),
                  child: TextField(
                    controller: controller,
                    style: const TextStyle(fontSize: TEXT_FONT_SIZE),
                    maxLines: null,
                    keyboardType: TextInputType.multiline,
                    decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Write down you win here'),
                  )))
        ])),
  );
}

Widget winEditorSaving(WinEditorSavingModel model) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Saving'),
    ),
    body: Center(child: spinner()),
  );
}

Widget spinner() {
  return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: const [CircularProgressIndicator(value: null)]);
}

Widget winEditorFailedToSave(
    WinEditorFailedToSaveModel model, void Function(Message) dispatch) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Failed to save'),
    ),
    body: Center(
        child: Column(children: [
      // TODO: maybe think about nicer way to show errors
      Padding(
          padding: const EdgeInsets.all(TEXT_PADDING),
          child: Text("Failed to contact the server: " + model.reason,
              style: const TextStyle(
                  fontSize: TEXT_FONT_SIZE, color: Colors.red))),
      Expanded(
          child: GestureDetector(
              onTap: () {
                dispatch(WinSaveRequested(model.date, model.win));
              },
              child: const Center(
                  child: Text("Click to re-try",
                      style: TextStyle(
                          fontSize: TEXT_FONT_SIZE, color: Colors.grey)))))
    ])),
  );
}
