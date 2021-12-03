import 'package:http/http.dart' as http;
import 'dart:convert';

import 'package:winaday/domain.dart';

// Android emulator:
// http://10.0.2.2:8700/
// Real device:
// http://192.168.0.16:8700/
const BASE_URL = 'http://192.168.0.16:8700';

class ApiException implements Exception {
  int statusCode;
  String message;

  ApiException(this.statusCode, this.message);
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

Future<dynamic> getWin(String session) async {
  return await getJson('/win', session);
}

Future<dynamic> postWin(Object data, String session) async {
  return await postJson('/win', data, session: session);
}