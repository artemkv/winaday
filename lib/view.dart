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
    return DailyWinView(model: model, dispatch: dispatch);
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

  if (model is EditWinPrioritiesModel) {
    return editWinPriorities(model, dispatch);
  }

  if (model is WinListLoadingModel) {
    return winListLoading(model, dispatch);
  }
  if (model is WinListModel) {
    return WinList(model: model, dispatch: dispatch);
  }
  if (model is WinListFailedToLoadModel) {
    return winListFailedToLoad(model, dispatch);
  }

  if (model is CalendarViewModel) {
    return CalendarView(model: model, dispatch: dispatch);
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
      appBar: AppBar(
        title: const Text('One win a day'),
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'List',
            onPressed: () {
              dispatch(NavigateToWinListRequested(model.date, model.today));
            },
          )
        ],
      ),
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
      appBar: AppBar(
        title: const Text('One win a day'),
        elevation: 0.0,
        actions: [
          IconButton(
            icon: const Icon(Icons.list),
            tooltip: 'List',
            onPressed: () {
              dispatch(NavigateToWinListRequested(model.date, model.today));
            },
          )
        ],
      ),
      drawer: drawer(context, model.date, model.today, dispatch),
      body: Center(
          child: Column(children: [
        calendarStripe(context, model.date, model.today, dispatch),
        Padding(
            padding: const EdgeInsets.all(TEXT_PADDING),
            child: Text("Failed to contact the server: " + model.reason,
                style: const TextStyle(
                    fontSize: TEXT_FONT_SIZE, color: Colors.red))),
        Expanded(
            child: GestureDetector(
                behavior: HitTestBehavior.translucent,
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

Widget dailyWinPage(DailyWinModel model, int index, int todayIndex,
    void Function(Message) dispatch) {
  if (index == todayIndex) {
    if (model.win.text == "") {
      return Padding(
          padding: const EdgeInsets.all(TEXT_PADDING),
          child: Center(
              child: Text("No win recorded",
                  style: GoogleFonts.openSans(
                      textStyle: const TextStyle(
                          fontSize: TEXT_FONT_SIZE, color: Colors.grey)))));
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Center(
          child: Padding(
              padding: const EdgeInsets.only(top: 16.0, bottom: 12.0),
              child:
                  Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                Padding(
                    padding: const EdgeInsets.only(right: TEXT_PADDING / 2),
                    child: Text(
                        overallDayResultText(
                          model.win.overallResult,
                        ),
                        style: GoogleFonts.openSans(
                            textStyle:
                                const TextStyle(fontSize: TEXT_FONT_SIZE)))),
                Text(overallDayResultEmoji(model.win.overallResult),
                    style: const TextStyle(fontSize: TEXT_FONT_SIZE))
              ]))),
      const Divider(
        height: 12,
        thickness: 1,
        indent: 64,
        endIndent: 64,
      ),
      Expanded(
          child: SingleChildScrollView(
              child: Column(children: [
        Row(children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.all(TEXT_PADDING * 1.6),
                  child: Text(model.win.text,
                      style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              fontSize: TEXT_FONT_SIZE * 1.4)))))
        ]),
        Row(children: [
          Expanded(
              child: Padding(
                  padding: const EdgeInsets.only(
                      left: TEXT_PADDING * 1.6,
                      right: TEXT_PADDING * 1.6,
                      bottom: TEXT_PADDING * 1.6),
                  child: dailyWinPriorityMap(model, dispatch)))
        ])
      ])))
    ]);
  } else {
    return const Padding(
        padding: EdgeInsets.all(TEXT_PADDING),
        child: Text("", style: TextStyle(fontSize: TEXT_FONT_SIZE)));
  }
}

Widget dailyWinPriorityMap(
    DailyWinModel model, void Function(Message) dispatch) {
  var rows = model.priorityList.items
      .where((x) => model.win.priorities.contains(x.id))
      .map((x) => Padding(
          padding: const EdgeInsets.all(4.0),
          child: Row(children: [
            Container(
                height: 32.0,
                width: 32.0,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(4.0),
                    color: getPriorityBoxColor(x.color))),
            Flexible(
                child: Wrap(children: [
              Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Text(x.text,
                      style: GoogleFonts.openSans(
                          textStyle:
                              const TextStyle(fontSize: TEXT_FONT_SIZE))))
            ]))
          ])))
      .toList();

  // TODO: consider adding activeItems property on PriorityListData object
  if (model.priorityList.items.where((x) => !x.deleted).isNotEmpty) {
    bool editMode = false;
    if (rows.isNotEmpty) {
      editMode = true;
    }

    rows.add(Padding(
        padding: const EdgeInsets.all(4.0),
        child: GestureDetector(
            onTap: () {
              dispatch(LinkWinToPriorities(
                  model.date, model.today, model.win, model.priorityList));
            },
            child: Row(children: [
              editMode ? const Icon(Icons.edit) : const Icon(Icons.link),
              Padding(
                  padding: const EdgeInsets.only(left: 8.0, right: 8.0),
                  child: Text(editMode ? "modify" : "link to your priorities",
                      style: GoogleFonts.openSans(
                          textStyle: const TextStyle(
                              color: denimBlue,
                              decoration: TextDecoration.underline,
                              fontSize: TEXT_FONT_SIZE)))),
            ]))));
  }

  return Column(children: rows);
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
  var week = getCurrentWeek(context, date);

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
                              behavior: HitTestBehavior.translucent,
                              onTap: () {
                                dispatch(
                                    NavigateToCalendarRequested(date, today));
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
                children: week
                    .map((d) => GestureDetector(
                        onTap: () {
                          dispatch(MoveToDay(d, today));
                        },
                        child: day(
                            context,
                            DateFormat(DateFormat.ABBR_WEEKDAY).format(d),
                            d.day.toString(),
                            d.isSameDate(date),
                            d.isSameDate(today),
                            d.isSameDate(today) || d.isBefore(today))))
                    .toList()),
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
      Padding(
          padding: const EdgeInsets.all(TEXT_PADDING),
          child: Text("Failed to contact the server: " + model.reason,
              style: const TextStyle(
                  fontSize: TEXT_FONT_SIZE, color: Colors.red))),
      Expanded(
          child: GestureDetector(
              behavior: HitTestBehavior.translucent,
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
      Padding(
          padding: const EdgeInsets.all(TEXT_PADDING),
          child: Text("Failed to contact the server: " + model.reason,
              style: const TextStyle(
                  fontSize: TEXT_FONT_SIZE, color: Colors.red))),
      Expanded(
          child: GestureDetector(
              behavior: HitTestBehavior.translucent,
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
              // TODO: Maybe move this to the reducer and simply dispatch update message (same with update priority)
              var updatedWin =
                  WinData(controller.text, newValue, model.win.priorities);
              dispatch(EditWinRequested(
                  model.date, model.today, model.priorityList, updatedWin));
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
                  behavior: HitTestBehavior.translucent,
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
      .map((e) => priorityBoxEditable(model, e, dispatch)))
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

Widget priorityBoxEditable(PrioritiesModel model, PriorityData priority,
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
          dispatch(CancelEditingPrioritiesRequested(model.date, model.today));
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
          )),
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

Widget editWinPriorities(
    EditWinPrioritiesModel model, void Function(Message) dispatch) {
  List<Widget> boxes = List.from(model.priorityList.items
      .where((element) => !element.deleted)
      .map((e) => priorityBoxSelectable(model, e, dispatch)));

  return Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('Link to your priorities'),
      actions: [
        IconButton(
          icon: const Icon(Icons.check),
          tooltip: 'Save',
          onPressed: () {
            dispatch(WinSaveRequested(model.date, model.win));
          },
        )
      ],
    ),
    body: WillPopScope(
        onWillPop: () async {
          dispatch(CancelEditingWinRequested(model.date, model.today));
          return false;
        },
        child: Center(
            child: GridView.count(
                crossAxisCount: 3,
                padding: const EdgeInsets.all(16.0),
                mainAxisSpacing: 12.0,
                crossAxisSpacing: 12.0,
                children: boxes))),
  );
}

Widget priorityBoxSelectable(EditWinPrioritiesModel model,
    PriorityData priority, void Function(Message) dispatch) {
  bool isSelected = model.win.priorities.contains(priority.id);
  return GestureDetector(
      onTap: () {
        dispatch(ToggleWinPriority(
            model.date, model.today, model.win, model.priorityList, priority));
      },
      child: Stack(children: [
        priorityBox(priority),
        (isSelected
            ? Align(
                alignment: Alignment.topRight,
                child: Padding(
                    padding: const EdgeInsets.all(4.0),
                    child: Container(
                        child: const Icon(Icons.check_circle_outline),
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.white))))
            : Container())
      ]));
}

Widget winListLoading(
    WinListLoadingModel model, void Function(Message) dispatch) {
  return Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('One win a day'),
    ),
    body: WillPopScope(
        onWillPop: () async {
          dispatch(BackToDailyWinViewRequested(model.date, model.today));
          return false;
        },
        child: Center(child: Column(children: [Expanded(child: spinner())]))),
  );
}

Widget winListFailedToLoad(
    WinListFailedToLoadModel model, void Function(Message) dispatch) {
  return Scaffold(
    appBar: AppBar(
      leading: const BackButton(),
      title: const Text('One win a day'),
    ),
    body: WillPopScope(
        onWillPop: () async {
          dispatch(BackToDailyWinViewRequested(model.date, model.today));
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
                  behavior: HitTestBehavior.translucent,
                  onTap: () {
                    dispatch(WinListFirstPageReloadRequested(
                        model.date, model.today, model.from, model.to));
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

Widget winListItemYearSeparator(int year) {
  return Row(children: [
    Expanded(
        child: Align(
            alignment: Alignment.center,
            child: Text(year.toString(),
                style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        fontSize: 18, fontWeight: FontWeight.bold)))))
  ]);
}

Widget winListItemMonthSeparator(int month) {
  return Row(children: [
    Expanded(
        child: Align(
            alignment: Alignment.center,
            child: Text(monthNames[month - 1],
                style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)))))
  ]);
}

Widget winListItemLoadMore(
    WinListModel model, void Function(Message) dispatch) {
  return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        dispatch(LoadWinListNextPageRequested());
      },
      child: Row(children: [
        Expanded(
            child: Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("...",
                        style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)))))),
      ]));
}

Widget winListItemLoadingMore() {
  return Row(children: [
    Expanded(
        child: Align(
            alignment: Alignment.center,
            child:
                Padding(padding: const EdgeInsets.all(12.0), child: spinner())))
  ]);
}

Widget winListItemRetryLoadMore(
    WinListModel model, String reason, void Function(Message) dispatch) {
  return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        dispatch(LoadWinListNextPageRequested());
      },
      child: Column(children: [
        Padding(
            padding: const EdgeInsets.all(TEXT_PADDING),
            child: Text("Failed to contact the server: " + reason,
                style: const TextStyle(
                    fontSize: TEXT_FONT_SIZE, color: Colors.red))),
        Row(children: [
          Expanded(
              child: Align(
                  alignment: Alignment.center,
                  child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Text("Click to re-try",
                          style: GoogleFonts.openSans(
                              textStyle: const TextStyle(
                                  fontSize: TEXT_FONT_SIZE,
                                  color: Colors.grey)))))),
        ])
      ]));
}

Widget winListItem(PriorityListData priorityList, DateTime date, DateTime today,
    WinData win, void Function(Message) dispatch) {
  List<Widget> summary = [Text(overallDayResultEmoji(win.overallResult))];
  summary.addAll(getPriorityTags(priorityList, win));

  return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        dispatch(MoveToDay(date, today));
      },
      child: Row(children: [
        Padding(
            padding: const EdgeInsets.all(TEXT_PADDING),
            child: Text(date.day.toString().padLeft(2, '0'),
                style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)))),
        Expanded(
            child: Padding(
                padding: const EdgeInsets.all(TEXT_PADDING),
                child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Flex(direction: Axis.horizontal, children: [
                            Flexible(
                                child: Wrap(children: [
                              Text(win.text,
                                  style: GoogleFonts.openSans(
                                      textStyle: const TextStyle(
                                          fontSize: TEXT_FONT_SIZE)))
                            ]))
                          ])),
                      Padding(
                          padding: const EdgeInsets.only(top: 4.0),
                          child: Flex(direction: Axis.horizontal, children: [
                            Flexible(child: Wrap(children: summary))
                          ]))
                    ]))),
      ]));
}

Widget noWinListItem(
    DateTime date, DateTime today, void Function(Message) dispatch) {
  return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        dispatch(MoveToDay(date, today));
      },
      child: Row(children: [
        Padding(
            padding: const EdgeInsets.all(TEXT_PADDING),
            child: Text(date.day.toString().padLeft(2, '0'),
                style: GoogleFonts.openSans(
                    textStyle: const TextStyle(
                        fontSize: 24, fontWeight: FontWeight.bold)))),
        Expanded(child: Container()),
      ]));
}

Iterable<Widget> getPriorityTags(PriorityListData priorityList, WinData win) {
  return priorityList.items
      .where((x) => win.priorities.contains(x.id))
      .expand((x) => [
            Padding(
                padding: const EdgeInsets.only(left: 4.0, bottom: 4.0),
                child: Container(
                    height: 20.0,
                    child: Padding(
                        padding: const EdgeInsets.only(left: 4.0, right: 4.0),
                        child: Text(getFirstWord(x.text),
                            style: GoogleFonts.openSans(
                                textStyle: const TextStyle(
                                    color: Colors.white, fontSize: 10)))),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2.0),
                        border: Border.all(color: getPriorityBoxColor(x.color)),
                        color: getPriorityBoxColor(x.color))))
          ]);
}

String getFirstWord(String text) {
  List<String> wordList = text.split(" ");
  if (wordList.isNotEmpty) {
    if (wordList.length > 1) {
      return wordList[0] + "...";
    }
    return wordList[0];
  } else {
    return '';
  }
}

Widget calendarListItemYearSeparator(int year) {
  return Padding(
      padding: const EdgeInsets.only(
          top: TEXT_PADDING * 4,
          right: TEXT_PADDING,
          bottom: TEXT_PADDING,
          left: TEXT_PADDING),
      child: Row(children: [
        Expanded(
            child: Align(
                alignment: Alignment.center,
                child: Text(year.toString(),
                    style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold)))))
      ]));
}

Widget calendarListItemNextPageTrigger(void Function(Message) dispatch) {
  return GestureDetector(
      behavior: HitTestBehavior.translucent,
      onTap: () {
        dispatch(CalendarViewNextPageRequested());
      },
      child: Row(children: [
        Expanded(
            child: Align(
                alignment: Alignment.center,
                child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Text("...",
                        style: GoogleFonts.openSans(
                            textStyle: const TextStyle(
                                fontSize: 24, fontWeight: FontWeight.bold)))))),
      ]));
}

Widget calendarMonth(BuildContext context, DateTime today, DateTime month,
    WinDaysData winDays, void Function(Message) dispatch) {
  var firstOfMonth = getFirstDayOfMonth(month);
  var week = getCurrentWeek(context, firstOfMonth);

  bool isHeader = true;
  var rows = <Widget>[calendarMonthHeader(month.month)];
  while (week[0].isSameMonth(month) || week[6].isSameMonth(month)) {
    rows.add(
        calendarWeek(context, month, week, today, isHeader, winDays, dispatch));
    isHeader = false;
    week = getCurrentWeek(context, week[0].add(const Duration(days: 7)));
  }

  return Padding(
      padding: const EdgeInsets.all(TEXT_PADDING),
      child: Column(children: rows));
}

Widget calendarMonthHeader(int month) {
  return Padding(
      padding: const EdgeInsets.all(TEXT_PADDING * 2),
      child: Row(children: [
        Expanded(
            child: Align(
                alignment: Alignment.center,
                child: Text(monthNames[month - 1],
                    style: GoogleFonts.openSans(
                        textStyle: const TextStyle(
                            fontSize: 24, fontWeight: FontWeight.bold)))))
      ]));
}

Widget calendarWeek(
    BuildContext context,
    DateTime month,
    List<DateTime> week,
    DateTime today,
    bool useHeader,
    WinDaysData winDays,
    void Function(Message) dispatch) {
  return Row(
      mainAxisSize: MainAxisSize.max,
      mainAxisAlignment: MainAxisAlignment.center,
      children: week
          .map((d) => GestureDetector(
              onTap: () {
                dispatch(MoveToDay(d, today));
              },
              child: calendarDay(
                  context,
                  DateFormat(DateFormat.ABBR_WEEKDAY).format(d),
                  useHeader,
                  d.day.toString(),
                  d.isSameMonth(month),
                  d.isSameDate(today),
                  !d.isSameDate(today) && !d.isBefore(today),
                  winDays.items.contains(d.toCompact()))))
          .toList());
}

Widget calendarDay(
    BuildContext context,
    String abbreviation,
    bool isHeader,
    String numericValue,
    bool isCurrentMonth,
    bool isToday,
    bool isInFuture,
    bool isWinDay) {
  double screenWidth = MediaQuery.of(context).size.width;
  double circleRadius = min(screenWidth * 0.105, 40);
  double fontSize = min(screenWidth * 0.04, 16.0);
  double biggerFontSize = min(screenWidth * 0.045, 20.0);

  return Column(mainAxisAlignment: MainAxisAlignment.center, children: [
    isHeader
        ? Text(abbreviation,
            style: GoogleFonts.openSans(
                textStyle: TextStyle(color: Colors.black, fontSize: fontSize)))
        : Container(),
    Container(
        alignment: Alignment.center,
        width: circleRadius,
        height: circleRadius,
        margin: const EdgeInsets.all(4.0),
        decoration: BoxDecoration(
            color: isCurrentMonth ? Colors.white : Colors.transparent,
            shape: BoxShape.circle,
            border: Border.all(
                color:
                    getCalendarDayColor(isCurrentMonth, isInFuture, isWinDay),
                width: isWinDay ? 2.0 : 1.0)),
        child: Text(numericValue,
            style: GoogleFonts.openSans(
                textStyle: TextStyle(
                    fontWeight: (isToday ? FontWeight.w700 : FontWeight.normal),
                    color: isCurrentMonth ? Colors.black : Colors.transparent,
                    fontSize: (isToday ? biggerFontSize : fontSize)))))
  ]);
}

Color getCalendarDayColor(bool isCurrentMonth, bool isInFuture, bool isWinDay) {
  if (isWinDay) return brownsOrange;
  if (!isCurrentMonth) return Colors.transparent;
  if (isInFuture) return Colors.grey.shade200;
  return Colors.grey.shade500;
}
