import 'package:winaday/services/api.dart';

String idToken = "";

void setIdToken(String value) {
  idToken = value;
}

void cleanIdToken() {
  idToken = "";
}

void someApiRequest() {
  signInWithBackend(idToken);
}
