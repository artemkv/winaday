import 'package:http/http.dart' as http;
import 'dart:convert';

// Android emulator:
// http://10.0.2.2:8700
// Real device:
//const BASE_URL = 'http://192.168.0.16:8700';
// Cloud service:
const BASE_URL = 'https://winaday.artemkv.net:8700';

class ApiException implements Exception {
  int statusCode;
  String message;

  ApiException(this.statusCode, this.message);

  @override
  String toString() {
    return message;
  }
}

class ApiResponseData {
  final dynamic data;

  ApiResponseData(this.data);

  ApiResponseData.fromJson(Map<String, dynamic> json) : data = json['data'];

  @override
  String toString() {
    return 'Data: ${data.toString()}';
  }
}

class ApiResponseError {
  final String error;

  ApiResponseError(this.error);

  ApiResponseError.fromJson(Map<String, dynamic> json) : error = json['err'];

  @override
  String toString() {
    return 'Error: $error';
  }
}

void handleErrors(http.Response response) {
  if (response.statusCode >= 400) {
    ApiResponseError errorResponse =
        ApiResponseError.fromJson(jsonDecode(response.body));
    throw ApiException(response.statusCode, errorResponse.error);
  }
}

dynamic getData(http.Response response) {
  ApiResponseData dataResponse =
      ApiResponseData.fromJson(jsonDecode(response.body));
  return dataResponse.data;
}

Future<dynamic> getJson(String endpoint, String session) async {
  var client = http.Client(); // TODO: re-use client if possible
  var url = Uri.parse('$BASE_URL$endpoint');
  var headers = {'x-session': session};

  try {
    var response = await client.get(url, headers: headers);
    handleErrors(response);
    return getData(response);
  } finally {
    client.close();
  }
}

Future<dynamic> postJson(String endpoint, Object data,
    {String? session}) async {
  var client = http.Client();
  var url = Uri.parse('$BASE_URL$endpoint');
  var headers = <String, String>{};
  if (session != null) {
    headers['x-session'] = session;
  }

  // print("JSON to POST: " + jsonEncode(data));

  try {
    var response =
        await client.post(url, body: jsonEncode(data), headers: headers);
    handleErrors(response);
    return getData(response);
  } finally {
    client.close();
  }
}

Future<dynamic> signIn(String idToken) async {
  return await postJson('/signin', {'id_token': idToken});
}

Future<dynamic> getWin(String date, String session) async {
  return await getJson('/win/$date', session);
}

Future<dynamic> postWin(String date, Object data, String session) async {
  return await postJson('/win/$date', data, session: session);
}

Future<dynamic> getPriorities(String session) async {
  return await getJson('/priorities', session);
}

Future<dynamic> postPriorities(Object data, String session) async {
  return await postJson('/priorities', data, session: session);
}

Future<dynamic> getWins(String from, String to, String session) async {
  return await getJson('/wins/$from/$to', session);
}

Future<dynamic> getWinDays(String from, String to, String session) async {
  return await getJson('/windays/$from/$to', session);
}

Future<dynamic> getStats(String from, String to, String session) async {
  return await getJson('/winstats/$from/$to', session);
}
