import 'package:http/http.dart' as http;
import 'dart:convert';

// Android emulator:
// http://10.0.2.2:8700/
// Real device:
// http://192.168.0.16:8700/

Future<void> signInWithBackend(String idToken) async {
  var client = http.Client();
  var url = Uri.parse('http://192.168.0.16:8700/signin');

  try {
    var response =
        await client.post(url, body: jsonEncode({'id_token': idToken}));
    print('Response status: ${response.statusCode}');
    print('Response body: ${response.body}');
  } finally {
    client.close();
  }
}
