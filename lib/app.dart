import 'package:flutter/material.dart';
import 'package:winaday/commands.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'theme.dart';
import 'model.dart';
import 'reducer.dart';
import 'messages.dart';
import 'view.dart';

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Win a day',
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en', ''),
        Locale('ru', ''),
      ],
      theme: ThemeData(primarySwatch: brownsOrange),
      home: const RootWidget(),
    );
  }
}

class RootWidget extends StatefulWidget {
  const RootWidget({Key? key}) : super(key: key);

  @override
  AppState createState() => AppState();
}

class AppState extends State<RootWidget> {
  Model model = Model.getInitialModel();

  @override
  void initState() {
    super.initState();
    Command.getInitialCommand().execute(dispatch);
  }

  @override
  Widget build(BuildContext context) {
    return home(context, model, dispatch);
  }

  void dispatch(Message message) {
    setState(() {
      ModelAndCommand result = reduce(model, message);

      model = result.model;

      result.command.execute(dispatch);
    });
  }
}
