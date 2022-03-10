import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'domain.dart';

const stateFileName = 'journey.state.json';
const sessionFileName = 'journey.session.json';

Future<JourneyState> restoreState() async {
  final path = await getApplicationSupportDirectory();
  final file = File('${path.path}/$stateFileName');
  if (!await file.exists()) {
    return JourneyState();
  }

  final jsonString = await file.readAsString();
  final json = jsonDecode(jsonString);
  final state = JourneyState.fromJson(json);
  return state;
}

Future<void> persistState(JourneyState state) async {
  final path = await getApplicationSupportDirectory();
  final file = File('${path.path}/$stateFileName');
  final json = state.toJson();
  final jsonString = jsonEncode(json);
  await file.writeAsString(jsonString);
}

Future<Session?> loadLastSession() async {
  final path = await getApplicationSupportDirectory();
  final file = File('${path.path}/$sessionFileName');
  if (!await file.exists()) {
    return null;
  }

  final jsonString = await file.readAsString();
  final json = jsonDecode(jsonString);
  final session = Session.fromJson(json);
  return session;
}

Future<void> saveSession(Session session) async {
  final path = await getApplicationSupportDirectory();
  final file = File('${path.path}/$sessionFileName');
  final json = session.toJson();
  final jsonString = jsonEncode(json);
  await file.writeAsString(jsonString);
}
