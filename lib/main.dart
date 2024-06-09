import 'dart:io';
import 'dart:developer' as developer;
import 'package:journey3_connector/journey3_connector.dart';
import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

import 'services/notifications.dart';
import 'app.dart';

Future<void> main() async {
  // TODO: move to initialization command
  WidgetsFlutterBinding.ensureInitialized();
  await NotificationService().init();

  Logger.root.onRecord.listen((record) {
    developer.log(record.message, level: record.level.value);
  });

  FlutterError.onError = (FlutterErrorDetails details) async {
    await Journey.instance().reportEvent('crash', isCrash: true);
    exit(0);
    //FlutterError.presentError(details);
  };

  // The rest of the code is moved away to stay null safe
  runApp(const MyApp());
}
