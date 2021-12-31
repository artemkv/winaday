import 'dart:math';

import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:winaday/domain.dart';
import 'custom_components.dart';
import 'model.dart';
import 'messages.dart';
import 'domain.dart';
import 'theme.dart';
import 'dateutil.dart';

// These should be all stateless! No side effects allowed!

const TEXT_PADDING = 12.0;
const TEXT_FONT_SIZE = 16.0;
const THEME_COLOR = brownsOrange;

Widget home(
    BuildContext context, Model model, void Function(Message) dispatch) {
  if (model is ApplicationNotInitializedModel) {
    return applicationNotInitialized(dispatch);
  }
  if (model is ApplicationFailedToInitializeModel) {
    return applicationFailedToInitialize(model, dispatch);
  }

  if (model is UserNotSignedInModel) {
    return userNotSignedIn(model, dispatch);
  }
  if (model is SignInInProgressModel) {
    return signInInProgress();
  }
  if (model is UserFailedToSignInModel) {
    return userFailedToSignIn(model, dispatch);
  }
  if (model is SignOutInProgressModel) {
    return signOutInProgress();
  }

  if (model is DailyWinLoadingModel) {
    return dailyWinLoading(context, model, dispatch);
  }
  if (model is DailyWinFailedToLoadModel) {
    return dailyWinFailedToLoad(context, model, dispatch);
  }
  if (model is DailyWinModel) {
    return dailyWin(context, model, dispatch);
  }
  if (model is WinEditorModel) {
    return WinEditor(model: model, dispatch: dispatch);
  }
  if (model is WinEditorSavingModel) {
    return winEditorSaving(model);
  }
  if (model is WinEditorFailedToSaveModel) {
    return winEditorFailedToSave(model, dispatch);
  }

  if (model is PrioritiesLoadingModel) {
    return prioritiesLoading(model, dispatch);
  }
  if (model is PrioritiesFailedToLoadModel) {
    return prioritiesFailedToLoad(context, model, dispatch);
  }
  if (model is PrioritiesModel) {
    return priorities(model, dispatch);
  }
  if (model is EditPrioritiesModel) {
    return editPriorities(model, dispatch);
  }
  if (model is CreatingNewPriorityModel) {
    return creatingNewPriority(model, dispatch);
  }
  if (model is PriorityEditorModel) {
    return PriorityEditor(model: model, dispatch: dispatch);
  }
  if (model is PrioritiesSavingModel) {
    return prioritiesSaving(model);
  }
  if (model is PriorityEditorFailedToSaveModel) {
    return priorityEditorFailedToSave(model, dispatch);
  }

  return unknownModel(model);
}

Widget unknownModel(Model model) {
  return Text("Unknown model: " + model.runtimeType.toString());
}

Widget applicationNotInitialized(void Function(Message) dispatch) {
  return Material(
    type: MaterialType.transparency,
    child: Container(
        decoration: const BoxDecoration(color: THEME_COLOR),
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              Expanded(child: Row()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [mottoLine1(), mottoLine2()]))
                ],
              ),
              Expanded(child: Row()),
            ]))),
  );
}

Widget applicationFailedToInitialize(
    ApplicationFailedToInitializeModel model, void Function(Message) dispatch) {
  return Material(
      type: MaterialType.transparency,
      child: Container(
          decoration: const BoxDecoration(color: THEME_COLOR),
          child: Column(children: [
            const Padding(
                padding: EdgeInsets.only(top: 64, left: 12, right: 12),
                child: Text("Failed to start the application",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold))),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Text("Failed to initialize: " + model.reason,
                    style: const TextStyle(color: Colors.white, fontSize: 16))),
            Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10)),
                  onPressed: () {
                    dispatch(ReInitializationRequested());
                  },
                  child: const Text("Try again",
                      style: TextStyle(
                          color: THEME_COLOR,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ))
          ])));
}

Widget userNotSignedIn(
    UserNotSignedInModel model, void Function(Message) dispatch) {
  return Material(
    type: MaterialType.transparency,
    child: Container(
        decoration: const BoxDecoration(color: THEME_COLOR),
        child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(children: [
              Expanded(child: Row()),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Expanded(
                      child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [mottoLine1(), mottoLine2()]))
                ],
              ),
              Expanded(
                  child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                    Expanded(
                        child: Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                          signInButton(model, dispatch),
                          userConsent(model, dispatch)
                        ]))
                  ])),
            ]))),
  );
}

Widget userFailedToSignIn(
    UserFailedToSignInModel model, void Function(Message) dispatch) {
  return Material(
      type: MaterialType.transparency,
      child: Container(
          decoration: const BoxDecoration(color: THEME_COLOR),
          child: Column(children: [
            const Padding(
                padding: EdgeInsets.only(top: 64, left: 12, right: 12),
                child: Text("Sign in failed or cancelled",
                    style: TextStyle(
                        color: Colors.white,
                        fontSize: 32,
                        fontWeight: FontWeight.bold))),
            Padding(
                padding: const EdgeInsets.all(12),
                child: Text("Failed to sign in: " + model.reason,
                    style: const TextStyle(color: Colors.white, fontSize: 16))),
            Padding(
                padding: const EdgeInsets.all(12),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                      primary: Colors.white,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10)),
                  onPressed: () {
                    dispatch(AppInitializedNotSignedIn());
                  },
                  child: const Text("Try again",
                      style: TextStyle(
                          color: THEME_COLOR,
                          fontSize: 24,
                          fontWeight: FontWeight.bold)),
                ))
          ])));
}

Widget mottoLine1() {
  return Text(
    "All you need is",
    style: GoogleFonts.yesevaOne(
        textStyle: const TextStyle(
            color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
  );
}

Widget mottoLine2() {
  return Text(
    "one win a day",
    style: GoogleFonts.yesevaOne(
        textStyle: const TextStyle(
            color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
  );
}

Widget signInButton(
    UserNotSignedInModel model, void Function(Message) dispatch) {
  var consentGiven =
      (model.privacyPolicyAccepted && model.personalDataProcessingAccepted);

  return Padding(
      padding: const EdgeInsets.all(12.0),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
            primary: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10)),
        onPressed: consentGiven
            ? () {
                dispatch(SignInRequested());
              }
            : null,
        child: const Text("Sign in",
            style: TextStyle(
                color: THEME_COLOR, fontSize: 24, fontWeight: FontWeight.bold)),
      ));
}

Widget userConsent(
    UserNotSignedInModel model, void Function(Message) dispatch) {
  return Column(children: [
    Row(children: [
      Checkbox(
        value: model.privacyPolicyAccepted,
        checkColor: brownsOrange,
        fillColor: MaterialStateProperty.resolveWith((states) => Colors.white),
        onChanged: (bool? accepted) {
          dispatch(UserConsentUpdated(
              accepted == true, model.personalDataProcessingAccepted));
        },
      ),
      Flexible(
        child: Wrap(children: [
          const Text("I agree to ",
              style: TextStyle(color: Colors.white, fontSize: TEXT_FONT_SIZE)),
          InkWell(
              onTap: () =>
                  launch('https://winaday-web.artemkv.net/privacy-policy.html'),
              child: const Text("Privacy Policy",
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontSize: TEXT_FONT_SIZE))),
          const Text(" and ",
              style: TextStyle(color: Colors.white, fontSize: TEXT_FONT_SIZE)),
          InkWell(
              onTap: () =>
                  launch('https://winaday-web.artemkv.net/terms-of-use.html'),
              child: const Text("Terms of Use",
                  style: TextStyle(
                      color: Colors.white,
                      decoration: TextDecoration.underline,
                      fontSize: TEXT_FONT_SIZE))),
          const Text(".",
              style: TextStyle(color: Colors.white, fontSize: TEXT_FONT_SIZE)),
        ]),
      )
    ]),
    Row(children: [
      Checkbox(
        value: model.personalDataProcessingAccepted,
        checkColor: brownsOrange,
        fillColor: MaterialStateProperty.resolveWith((states) => Colors.white),
        onChanged: (bool? accepted) {
          dispatch(UserConsentUpdated(
              model.privacyPolicyAccepted, accepted == true));
        },
      ),
      Flexible(
          child: Wrap(children: [
        const Text(
            "I agree to processing of my personal data for providing me app functions. See more in ",
            style: TextStyle(color: Colors.white, fontSize: TEXT_FONT_SIZE)),
        InkWell(
            onTap: () =>
                launch('https://winaday-web.artemkv.net/privacy-policy.html'),
            child: const Text("Privacy Policy",
                style: TextStyle(
                    color: Colors.white,
                    decoration: TextDecoration.underline,
                    fontSize: TEXT_FONT_SIZE))),
        const Text(".",
            style: TextStyle(color: Colors.white, fontSize: TEXT_FONT_SIZE)),
      ]))
    ])
  ]);
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

Widget dailyWinLoading(BuildContext context, DailyWinLoadingModel model,
    void Function(Message) dispatch) {
  return Scaffold(
      appBar: AppBar(title: const Text('One win a day'), elevation: 0.0),
      drawer: drawer(context, model.date, model.today, dispatch),
      body: Center(
          child: Column(children: [
        calendarStripe(context, model.date, model.today, dispatch),
        Expanded(child: spinner())
      ])));
}

Widget dailyWinFailedToLoad(BuildContext context,
    DailyWinFailedToLoadModel model, void Function(Message) dispatch) {
  return Scaffold(
      appBar: AppBar(title: const Text('One win a day'), elevation: 0.0),
      drawer: drawer(context, model.date, model.today, dispatch),
      body: Center(
          child: Column(children: [
        calendarStripe(context, model.date, model.today, dispatch),
        // TODO: maybe think about nicer way to show errors
        Padding(
            padding: const EdgeInsets.all(TEXT_PADDING),
            child: Text("Failed to contact the server: " + model.reason,
                style: const TextStyle(
                    fontSize: TEXT_FONT_SIZE, color: Colors.red))),
        Expanded(
            child: GestureDetector(
                onTap: () {
                  dispatch(
                      DailyWinViewReloadRequested(model.date, model.today));
                },
                child: Center(
                    child: Text("Click to reload",
                        style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                                fontSize: TEXT_FONT_SIZE,
                                color: Colors.grey))))))
      ])));
}

Widget dailyWin(BuildContext context, DailyWinModel model,
    void Function(Message) dispatch) {
  const yesterday = 1;
  const today = 2;
  const tomorrow = 3;

  final PageController controller = PageController(initialPage: today);

  return Scaffold(
      appBar: AppBar(title: const Text('One win a day'), elevation: 0.0),
      drawer: drawer(context, model.date, model.today, dispatch),
      body: Column(children: [
        calendarStripe(context, model.date, model.today, dispatch),
        Expanded(
            child: Center(
                child: PageView.builder(
                    onPageChanged: (page) {
                      if (page == yesterday) {
                        dispatch(MoveToPrevDay(model.date, model.today));
                      } else if (page == tomorrow) {
                        dispatch(MoveToNextDay(model.date, model.today));
                      }
                    },
                    scrollDirection: Axis.horizontal,
                    controller: controller,
                    itemBuilder: (context, index) {
                      if (index == today) {
                        if (model.win.text == "") {
                          return Padding(
                              padding: const EdgeInsets.all(TEXT_PADDING),
                              child: Center(
                                  child: Text("No win recorded",
                                      style: GoogleFonts.openSans(
                                          textStyle: const TextStyle(
                                              fontSize: TEXT_FONT_SIZE,
                                              color: Colors.grey)))));
                        }
                        return Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Center(
                                  child: Padding(
                                      padding: const EdgeInsets.only(
                                          top: 16.0, bottom: 12.0),
                                      child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Padding(
                                                padding: const EdgeInsets.only(
                                                    right: TEXT_PADDING / 2),
                                                child: Text(
                                                    overallDayResultText(
                                                      model.win.overallResult,
                                                    ),
                                                    style: GoogleFonts.openSans(
                                                        textStyle: const TextStyle(
                                                            fontSize:
                                                                TEXT_FONT_SIZE)))),
                                            Text(
                                                overallDayResultEmoji(
                                                    model.win.overallResult),
                                                style: const TextStyle(
                                                    fontSize: TEXT_FONT_SIZE))
                                          ]))),
                              const Divider(
                                height: 12,
                                thickness: 1,
                                indent: 64,
                                endIndent: 64,
                              ),
                              Expanded(
                                  child: Padding(
                                      padding: const EdgeInsets.all(
                                          TEXT_PADDING * 1.6),
                                      child: Text(model.win.text,
                                          style: GoogleFonts.openSans(
                                              textStyle: const TextStyle(
                                                  fontSize:
                                                      TEXT_FONT_SIZE * 1.4)))))
                            ]);
                      } else {
                        return const Padding(
                            padding: EdgeInsets.all(TEXT_PADDING),
                            child: Text("",
                                style: TextStyle(fontSize: TEXT_FONT_SIZE)));
                      }
                    })))
      ]),
      floatingActionButton: (model.editable
          ? FloatingActionButton(
              onPressed: () {
                dispatch(EditWinRequested(model.date, model.today, model.win));
              },
              child: const Icon(Icons.edit),
              backgroundColor: denimBlue,
            )
          : null));
}

Widget drawer(BuildContext context, DateTime date, DateTime today,
    void Function(Message) dispatch) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        DrawerHeader(
          decoration: const BoxDecoration(
            color: denimBlue,
          ),
          child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: const [
                Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Text("One Win a Day",
                        style: TextStyle(
                          fontSize: TEXT_FONT_SIZE,
                          color: Colors.white,
                        ))),
                Padding(
                    padding: EdgeInsets.all(2.0),
                    child: Text("Track you wins every day",
                        style: TextStyle(
                          fontSize: TEXT_FONT_SIZE * 0.8,
                          color: Colors.white,
                        )))
              ]),
        ),
        ListTile(
          title: Row(children: const [
            Padding(
                padding: EdgeInsets.only(left: 4.0, right: 32.0),
                child: Icon(Icons.stars)),
            Text('Your Priorities')
          ]),
          onTap: () {
            Navigator.pop(context);
            dispatch(NavigateToPrioritiesRequested(date, today));
          },
        ),
        const Divider(
          height: 12,
          thickness: 1,
          indent: 0,
          endIndent: 0,
        ),
        /* TODO: consider adding credits page
        ListTile(
              title: Row(children: const [
                Padding(
                    padding: EdgeInsets.only(left: 4.0, right: 32.0),
                    child: Icon(Icons.info_outline)),
                Text('Credits')
              ]),
              onTap: () {
                // Update the state of the app.
                // ...
              },
            ),*/
        ListTile(
          title: Row(children: const [
            Padding(
                padding: EdgeInsets.only(left: 4.0, right: 32.0),
                child: Icon(Icons.logout)),
            Text('Sign out')
          ]),
          onTap: () {
            dispatch(SignOutRequested());
          },
        ),
      ],
    ),
  );
}

Widget calendarStripe(BuildContext context, DateTime date, DateTime today,
    void Function(Message) dispatch) {
  var week = getCurrentWeek(context, date, today);

  return Container(
      decoration: const BoxDecoration(color: THEME_COLOR),
      child: Material(
          type: MaterialType.transparency,
          child: Column(children: [
            Padding(
                padding: const EdgeInsets.only(bottom: 4.0),
                child: Row(children: [
                  IconButton(
                      icon: const Icon(Icons.arrow_left),
                      color: Colors.white,
                      tooltip: 'Prev',
                      onPressed: () {
                        dispatch(MoveToPrevWeek(date, today));
                      }),
                  Expanded(
                      child: Center(
                          child: GestureDetector(
                              onTap: () {
                                dispatch(MoveToDay(today, today));
                              },
                              child: Padding(
                                  padding: const EdgeInsets.all(4.0),
                                  child: Text(getDayString(date),
                                      style: GoogleFonts.openSans(
                                          textStyle: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 16.0))))))),
                  IconButton(
                    icon: const Icon(Icons.arrow_right),
                    color: Colors.white,
                    tooltip: 'Next',
                    onPressed: () {
                      dispatch(MoveToNextWeek(date, today));
                    },
                  )
                ])),
            Row(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // TODO: not localized
                  GestureDetector(
                      onTap: () {
                        dispatch(MoveToDay(week[0], today));
                      },
                      child: day(
                          context,
                          DateFormat(DateFormat.ABBR_WEEKDAY).format(week[0]),
                          week[0].day.toString(),
                          week[0].isSameDate(date),
                          week[0].isSameDate(today),
                          week[0].isSameDate(today) ||
                              week[0].isBefore(today))),
                  GestureDetector(
                      onTap: () {
                        dispatch(MoveToDay(week[1], today));
                      },
                      child: day(
                          context,
                          DateFormat(DateFormat.ABBR_WEEKDAY).format(week[1]),
                          week[1].day.toString(),
                          week[1].isSameDate(date),
                          week[1].isSameDate(today),
                          week[1].isSameDate(today) ||
                              week[1].isBefore(today))),
                  GestureDetector(
                      onTap: () {
                        dispatch(MoveToDay(week[2], today));
                      },
                      child: day(
                          context,
                          DateFormat(DateFormat.ABBR_WEEKDAY).format(week[2]),
                          week[2].day.toString(),
                          week[2].isSameDate(date),
                          week[2].isSameDate(today),
                          week[2].isSameDate(today) ||
                              week[2].isBefore(today))),
                  GestureDetector(
                      onTap: () {
                        dispatch(MoveToDay(week[3], today));
                      },
                      child: day(
                          context,
                          DateFormat(DateFormat.ABBR_WEEKDAY).format(week[3]),
                          week[3].day.toString(),
                          week[3].isSameDate(date),
                          week[3].isSameDate(today),
                          week[3].isSameDate(today) ||
                              week[3].isBefore(today))),
                  GestureDetector(
                      onTap: () {
                        dispatch(MoveToDay(week[4], today));
                      },
                      child: day(
                          context,
                          DateFormat(DateFormat.ABBR_WEEKDAY).format(week[4]),
                          week[4].day.toString(),
                          week[4].isSameDate(date),
                          week[4].isSameDate(today),
                          week[4].isSameDate(today) ||
                              week[4].isBefore(today))),
                  GestureDetector(
                      onTap: () {
                        dispatch(MoveToDay(week[5], today));
                      },
                      child: day(
                          context,
                          DateFormat(DateFormat.ABBR_WEEKDAY).format(week[5]),
                          week[5].day.toString(),
                          week[5].isSameDate(date),
                          week[5].isSameDate(today),
                          week[5].isSameDate(today) ||
                              week[5].isBefore(today))),
                  GestureDetector(
                      onTap: () {
                        dispatch(MoveToDay(week[6], today));
                      },
                      child: day(
                          context,
                          DateFormat(DateFormat.ABBR_WEEKDAY).format(week[6]),
                          week[6].day.toString(),
                          week[6].isSameDate(date),
                          week[6].isSameDate(today),
                          week[6].isSameDate(today) ||
                              week[6].isBefore(today))),
                ]),
          ])));
}

Widget day(BuildContext context, String abbreviation, String numericValue,
    bool isSelected, bool isToday, bool editable) {
  double screenWidth = MediaQuery.of(context).size.width;
  double circleRadius = min(screenWidth * 0.105, 40);
  double fontSize = min(screenWidth * 0.04, 16.0);
  double biggerFontSize = min(screenWidth * 0.055, 20.0);

  return Padding(
      padding: const EdgeInsets.only(left: 2.0, right: 2.0, bottom: 8.0),
      child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
        Text(abbreviation,
            style: GoogleFonts.openSans(
                textStyle: TextStyle(color: Colors.white, fontSize: fontSize))),
        Container(
            alignment: Alignment.center,
            width: circleRadius,
            height: circleRadius,
            margin: const EdgeInsets.all(4.0),
            decoration: BoxDecoration(
                color: isSelected ? Colors.white : THEME_COLOR,
                shape: BoxShape.circle,
                border: Border.all(
                    color: editable ? Colors.white : Colors.white30,
                    width: 2.0)),
            child: Text(numericValue,
                style: GoogleFonts.openSans(
                    textStyle: TextStyle(
                        fontWeight:
                            (isToday ? FontWeight.w900 : FontWeight.normal),
                        color: (isSelected ? THEME_COLOR : Colors.white),
                        fontSize: (isToday ? biggerFontSize : fontSize)))))
      ]));
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

Widget priorityEditorFailedToSave(
    PriorityEditorFailedToSaveModel model, void Function(Message) dispatch) {
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
                dispatch(SaveChangesInPrioritiesRequested(
                    model.date, model.priorityList));
              },
              child: const Center(
                  child: Text("Click to re-try",
                      style: TextStyle(
                          fontSize: TEXT_FONT_SIZE, color: Colors.grey)))))
    ])),
  );
}

Widget dayOverallResult(TextEditingController controller, WinEditorModel model,
    void Function(Message) dispatch) {
  return Padding(
      padding: const EdgeInsets.only(
          top: TEXT_PADDING,
          left: TEXT_PADDING * 2,
          right: TEXT_PADDING * 2,
          bottom: TEXT_PADDING),
      child: Row(children: [
        const Padding(
            padding: EdgeInsets.only(right: TEXT_PADDING * 2),
            child: Text("How was it?",
                style: TextStyle(fontSize: TEXT_FONT_SIZE))),
        DropdownButton<int>(
          value: model.win.overallResult,
          onChanged: (int? newValue) {
            if (newValue != null) {
              var updatedWin = WinData(controller.text, newValue);
              dispatch(EditWinRequested(model.date, model.today, updatedWin));
            }
          },
          items: <int>[
            OverallDayResult.gotMyWin,
            OverallDayResult.awesomeAchievement,
            OverallDayResult.couldNotGetWin
          ].map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Row(children: [
                Padding(
                    padding: const EdgeInsets.only(right: TEXT_PADDING / 2),
                    child: Text(overallDayResultText(value))),
                Text(overallDayResultEmoji(value))
              ]),
            );
          }).toList(),
        )
      ]));
}

String overallDayResultText(int index) {
  switch (index) {
    case OverallDayResult.noWinYet:
      return "No win yet";
    case OverallDayResult.gotMyWin:
      return "Got my win";
    case OverallDayResult.couldNotGetWin:
      return "Could not get my win";
    case OverallDayResult.grind:
      return "Prepared tomorrow's win";
    case OverallDayResult.awesomeAchievement:
      return "Awesome achievement";
  }
  throw "Unknown value of overall result: $index";
}

String overallDayResultEmoji(int index) {
  switch (index) {
    case OverallDayResult.noWinYet:
      return "🙄";
    case OverallDayResult.gotMyWin:
      return "😊";
    case OverallDayResult.couldNotGetWin:
      return "😕";
    case OverallDayResult.grind:
      return "😅";
    case OverallDayResult.awesomeAchievement:
      return "🤩";
  }
  throw "Unknown value of overall result: $index";
}

Widget prioritiesLoading(
    PrioritiesLoadingModel model, void Function(Message) dispatch) {
  return Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('Your Priorities'),
    ),
    body: WillPopScope(
        onWillPop: () async {
          dispatch(ExitPrioritiesRequested(model.date, model.today));
          return false;
        },
        child: Center(child: Column(children: [Expanded(child: spinner())]))),
  );
}

Widget prioritiesFailedToLoad(BuildContext context,
    PrioritiesFailedToLoadModel model, void Function(Message) dispatch) {
  return Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('Your Priorities'),
    ),
    body: WillPopScope(
        onWillPop: () async {
          dispatch(ExitPrioritiesRequested(model.date, model.today));
          return false;
        },
        child: Center(
            child: Column(children: [
          Padding(
              padding: const EdgeInsets.all(TEXT_PADDING),
              child: Text("Failed to contact the server: " + model.reason,
                  style: const TextStyle(
                      fontSize: TEXT_FONT_SIZE, color: Colors.red))),
          Expanded(
              child: GestureDetector(
                  onTap: () {
                    dispatch(
                        PrioritiesReloadRequested(model.date, model.today));
                  },
                  child: Center(
                      child: Text("Click to reload",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  fontSize: TEXT_FONT_SIZE,
                                  color: Colors.grey))))))
        ]))),
  );
}

Widget priorities(PrioritiesModel model, void Function(Message) dispatch) {
  List<Widget> placeholder = model.canAddMore
      ? [priorityBoxPlaceholder(model, dispatch)]
      : List.empty();

  List<Widget> boxes = List.from(model.priorityList.items
      .where((element) => !element.deleted)
      .map((e) => priorityBoxTappable(model, e, dispatch)))
    ..addAll(placeholder);

  return Scaffold(
      appBar: AppBar(
        leading: const BackButton(),
        title: const Text('Your Priorities'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            tooltip: 'Edit',
            onPressed: () {
              dispatch(EditPrioritiesRequested(
                  model.date, model.today, model.priorityList));
            },
          )
        ],
      ),
      body: WillPopScope(
          onWillPop: () async {
            dispatch(ExitPrioritiesRequested(model.date, model.today));
            return false;
          },
          child: Center(
              child: GridView.count(
                  crossAxisCount: 3,
                  padding: const EdgeInsets.all(16.0),
                  mainAxisSpacing: 12.0,
                  crossAxisSpacing: 12.0,
                  children: boxes))));
}

Widget creatingNewPriority(
    CreatingNewPriorityModel model, void Function(Message) dispatch) {
  return Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('Your Priorities'),
    ),
    body: WillPopScope(
        onWillPop: () async {
          dispatch(ExitPrioritiesRequested(model.date, model.today));
          return false;
        },
        child: Center(child: Column(children: [Expanded(child: spinner())]))),
  );
}

Widget priorityBoxTappable(PrioritiesModel model, PriorityData priority,
    void Function(Message) dispatch) {
  return GestureDetector(
      onTap: () {
        dispatch(EditExistingPriorityRequested(
            model.date, model.today, model.priorityList, priority));
      },
      child: priorityBox(priority));
}

Widget priorityBox(PriorityData priority) {
  return Container(
      child: Center(
          child: Padding(
              padding: const EdgeInsets.all(12.0),
              child: Text(
                priority.text,
                style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        color: Colors.white, fontSize: TEXT_FONT_SIZE)),
              ))),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(4.0),
        color: getPriorityBoxColor(priority.color),
      ));
}

Widget priorityBoxPlaceholder(
    PrioritiesModel model, void Function(Message) dispatch) {
  return GestureDetector(
      onTap: () {
        dispatch(EditNewPriorityRequested(
            model.date, model.today, model.priorityList));
      },
      child: DottedBorder(
          color: Colors.grey,
          borderType: BorderType.RRect,
          radius: const Radius.circular(4.0),
          dashPattern: const [4, 3],
          strokeWidth: 1,
          child: const Center(
              child: Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Icon(
                    Icons.add_circle_outline,
                    color: Colors.grey,
                  )))));
}

Widget editPriorities(
    EditPrioritiesModel model, void Function(Message) dispatch) {
  return Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('Your Priorities'),
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Save',
          onPressed: () {
            dispatch(SaveChangesInPrioritiesRequested(
                model.date, model.priorityList));
          },
        )
      ],
    ),
    body: WillPopScope(
        onWillPop: () async {
          dispatch(ExitPrioritiesRequested(model.date, model.today));
          return false;
        },
        child: Stack(children: [
          Center(
              child: DraggablePriorityGrid(model: model, dispatch: dispatch)),
          Align(
              alignment: Alignment.bottomCenter,
              child: trashbin(model, dispatch))
        ])),
  );
}

Widget draggablePriorityBox(
    EditPrioritiesModel model,
    PriorityData priority,
    PriorityData? exchangeWith,
    void Function(Message) dispatch,
    void Function(PriorityData?) onWillAccept) {
  return Draggable<PriorityData>(
      data: priority,
      dragAnchorStrategy: childDragAnchorStrategy,
      feedback: Container(
          height: 130,
          width: 130,
          child: Center(
              child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    priority.text,
                    style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                            decoration: TextDecoration.none,
                            color: Colors.white,
                            fontSize: TEXT_FONT_SIZE)),
                  ))),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(4.0),
            color: priorityColors[priority.color],
          )), // TODO: make sure colors do not go out of range
      childWhenDragging: exchangeWith != null
          ? priorityBox(exchangeWith)
          : priorityBox(priority),
      child: DragTarget<PriorityData>(
        builder: (context, candidateItems, rejectedItems) {
          return Container(
              child: Center(
                  child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text(
                        priority.text,
                        style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                                color: Colors.white, fontSize: TEXT_FONT_SIZE)),
                      ))),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4.0),
                color: candidateItems.isNotEmpty
                    ? Colors.white
                    : getPriorityBoxColor(priority.color),
              ));
        },
        onWillAccept: (_) {
          onWillAccept(priority);
          return true;
        },
        onLeave: (data) {
          onWillAccept(null);
        },
        onAccept: (exchangeWith) {
          dispatch(PrioritiesReorderRequested(model.date, model.today,
              model.priorityList, priority, exchangeWith));
        },
      ));
}

Widget trashbin(EditPrioritiesModel model, void Function(Message) dispatch) {
  return Padding(
      padding: const EdgeInsets.all(24.0),
      child: DragTarget<PriorityData>(
          builder: (context, candidateItems, rejectedItems) {
        return Container(
            height: 140,
            width: 140,
            child: const Center(
                child: Padding(
                    padding: EdgeInsets.all(12.0),
                    child: Icon(
                      Icons.delete_outline,
                      color: Colors.grey,
                    ))),
            decoration: BoxDecoration(
                color: candidateItems.isNotEmpty
                    ? Colors.grey.shade200
                    : Colors.white,
                shape: BoxShape.circle,
                border: Border.all(
                    color:
                        candidateItems.isNotEmpty ? Colors.grey : Colors.grey,
                    width: 2.0)));
      }, onAccept: (priority) {
        dispatch(DeletePriorityRequested(
            model.date, model.today, model.priorityList, priority));
      }));
}

Color getPriorityBoxColor(int color) {
  return priorityColors[color % priorityColors.length];
}

Widget priorityBoxColorPicker(TextEditingController controller,
    PriorityEditorModel model, void Function(Message) dispatch) {
  return Padding(
      padding: const EdgeInsets.only(
          // TODO: single-source
          top: TEXT_PADDING,
          left: TEXT_PADDING * 2,
          right: TEXT_PADDING * 2,
          bottom: TEXT_PADDING),
      child: Row(children: [
        const Padding(
            padding: EdgeInsets.only(right: TEXT_PADDING * 2),
            child: Text("Pick a color:",
                style: TextStyle(fontSize: TEXT_FONT_SIZE))),
        DropdownButton<int>(
          value: model.priority.color,
          onChanged: (int? newValue) {
            if (newValue != null) {
              var updatedPriority = PriorityData(model.priority.id,
                  controller.text, newValue, model.priority.deleted);
              dispatch(EditExistingPriorityRequested(model.date, model.today,
                  model.priorityList, updatedPriority));
            }
          },
          items: List.generate(priorityColors.length, (index) => index)
              .map<DropdownMenuItem<int>>((int value) {
            return DropdownMenuItem<int>(
              value: value,
              child: Container(
                  width: 48,
                  height: 24,
                  decoration: BoxDecoration(color: getPriorityBoxColor(value))),
            );
          }).toList(),
        )
      ]));
}

Widget prioritiesSaving(PrioritiesSavingModel model) {
  return Scaffold(
    appBar: AppBar(
      title: const Text('Saving'),
    ),
    body: Center(child: spinner()),
  );
}
