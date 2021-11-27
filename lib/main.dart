// @dart=2.9
// The directive above disables sound null safety.
// This is required because Google didn't update their sign-in package to null safery.
import 'app.dart';
import 'package:flutter/material.dart';

void main() {
  // The rest of the code is moved away to stay null safe
  runApp(const MyApp());
}
