import 'package:winaday/services/rest_api.dart' as rest;

String idToken = "";
String session = "";

void setIdToken(String value) {
  idToken = value;
}

void cleanIdToken() {
  idToken = "";
  session = "";
}

bool hasIdToken() {
  return idToken != "";
}

bool hasSession() {
  return session != "";
}

Future<void> signIn(String idToken) async {
  try {
    var json = await rest.signIn(idToken);
    session = json['session'];
  } catch (e) {
    session = "";
  }
}

Future<dynamic> callApi(Future<dynamic> Function() f) async {
  if (!hasIdToken()) {
    throw "Id token not found";
  }
  if (!hasSession()) {
    // print(">> No session, first need to sign in");
    await signIn(idToken);
    return f();
  }
  try {
    // print(">> Has session, go to the api directly");
    return await f();
  } on rest.ApiException catch (e) {
    if (e.statusCode == 401) {
      // print(">> Oops, expired, will sign in again and retry");
      await signIn(idToken);
      return f();
    }
    rethrow;
  }
}

Future<dynamic> getWin() {
  return callApi(() => rest.getWin(session));
}

Future<dynamic> postWin(Object data) {
  return callApi(() => rest.postWin(data, session));
}
