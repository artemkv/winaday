import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import 'domain.dart';

const journeyBaseUrl = 'http://192.168.0.16:8060';
//const journeyUrl = 'https://journey3-ingest.artemkv.net:8060';
const postSessionTimeout = Duration(seconds: 30);

Future<void> postSessionHeader(SessionHeader header) async {
  final client = http.Client();
  try {
    final url = Uri.parse('$journeyBaseUrl/session_head');
    final bodyText = jsonEncode(header);
    log('Session: $bodyText'); // TODO: this is debug code
    final response =
        await client.post(url, body: bodyText).timeout(postSessionTimeout);
    if (response.statusCode >= 400) {
      ApiResponseError errorResponse =
          ApiResponseError.fromJson(jsonDecode(response.body));
      throw Exception(
          'POST returned ${response.statusCode} ${response.reasonPhrase}: ${errorResponse.error}');
    }
  } catch (err) {
    throw Exception(
        'Error sending session header to Journey: ${err.toString()}');
  } finally {
    client.close();
  }
}

Future<void> postSession(Session session) async {
  final client = http.Client();
  try {
    final url = Uri.parse('$journeyBaseUrl/session_tail');
    final bodyText = jsonEncode(session);
    log('Session: $bodyText'); // TODO: this is debug code
    final response =
        await client.post(url, body: bodyText).timeout(postSessionTimeout);
    if (response.statusCode >= 400) {
      ApiResponseError errorResponse =
          ApiResponseError.fromJson(jsonDecode(response.body));
      throw Exception(
          'POST returned ${response.statusCode} ${response.reasonPhrase}: ${errorResponse.error}');
    }
  } catch (err) {
    throw Exception('Error sending session to Journey: ${err.toString()}');
  } finally {
    client.close();
  }
}
