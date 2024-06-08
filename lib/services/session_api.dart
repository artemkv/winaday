import 'package:winaday/services/rest_api.dart' as rest;

String session = "";

bool hasSession() {
  return session != "";
}

void killSession() {
  session = "";
}

Future<void> signIn(String idToken) async {
  try {
    var json = await rest.signIn(idToken);
    session = json['session'];
  } catch (e) {
    session = "";
  }
}

Future<dynamic> callApi(
    Future<dynamic> Function() f, Future<String> Function() getIdToken) async {
  if (!hasSession()) {
    // print(">> No session, first need to sign in");
    var idToken = await getIdToken();
    await signIn(idToken);
    return f();
  }
  try {
    // print(">> Has session, go to the api directly");
    return await f();
  } on rest.ApiException catch (e) {
    if (e.statusCode == 401) {
      // print(">> Oops, expired, will sign in again and retry");
      var idToken = await getIdToken();
      await signIn(idToken);
      return f();
    }
    rethrow;
  }
}

Future<dynamic> getWin(String date, Future<String> Function() getIdToken) {
  return callApi(() => rest.getWin(date, session), getIdToken);
}

Future<dynamic> postWin(
    String date, Object data, Future<String> Function() getIdToken) {
  return callApi(() => rest.postWin(date, data, session), getIdToken);
}

Future<dynamic> getPriorities(Future<String> Function() getIdToken) {
  return callApi(() => rest.getPriorities(session), getIdToken);
}

Future<dynamic> postPriorities(
    Object data, Future<String> Function() getIdToken) {
  return callApi(() => rest.postPriorities(data, session), getIdToken);
}

Future<dynamic> getWins(
    String from, String to, Future<String> Function() getIdToken) {
  return callApi(() => rest.getWins(from, to, session), getIdToken);
}

Future<dynamic> getWinDays(
    String from, String to, Future<String> Function() getIdToken) {
  return callApi(() => rest.getWinDays(from, to, session), getIdToken);
}

Future<dynamic> getStats(
    String from, String to, Future<String> Function() getIdToken) {
  return callApi(() => rest.getStats(from, to, session), getIdToken);
}

Future<dynamic> postDeleteAllUserData(Future<String> Function() getIdToken) {
  return callApi(() => rest.postDeleteAllUserData({}, session), getIdToken);
}
