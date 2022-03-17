import 'dart:convert';
import 'dart:io';

import 'package:path_provider/path_provider.dart';

import 'domain.dart';

const sessionFileName = 'journey.session.json';

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
