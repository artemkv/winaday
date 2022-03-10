import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:developer';

import 'domain.dart';

//const journeyUrl = 'http://192.168.0.16:8060/session';
const journeyUrl = 'https://journey3-ingest.artemkv.net:8060/session';
const postSessionTimeout = Duration(seconds: 30);

Future<void> postSession(Session session) async {
  final client = http.Client();
  try {
    final url = Uri.parse(journeyUrl);
    final bodyText = jsonEncode(session);
    // log('Session: $bodyText'); // TODO: this is debug code
    final response =
        await client.post(url, body: bodyText).timeout(postSessionTimeout);
    if (response.statusCode >= 400) {
      ApiResponseError errorResponse =
          ApiResponseError.fromJson(jsonDecode(response.body));
      throw Exception(
          'Error sending session to Journey: POST returned ${response.statusCode} ${response.reasonPhrase}: ${errorResponse.error}');
    }
  } catch (err) {
    throw Exception('Error sending session to Journey: ${err.toString()}');
  } finally {
    client.close();
  }
}
