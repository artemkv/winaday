// @dart=2.9
// The directive above disables sound null safety.
// This is required because Google didn't update their sign-in package to null safery.
import 'dart:io';

import 'package:winaday/journey/journey.dart';
import 'package:winaday/services/notifications.dart';

import 'app.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  // TODO: move to initialization command
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  FlutterError.onError = (FlutterErrorDetails details) async {
    await Journey.instance().reportEvent('crash', isCrash: true);
    exit(0);
    //FlutterError.presentError(details);
  };

  // The rest of the code is moved away to stay null safe
  runApp(const MyApp());
}
