import 'dart:convert';
import 'package:http/http.dart' as http;

class SentimentApi {
  static const String _baseUrl = "http://10.0.2.2:5000";
  // gerçek telefon için:
  // static const String _baseUrl = "http://192.168.180.1:5000";

  static Future<Map<String, dynamic>> analyze(String text) async {
    final url = Uri.parse("$_baseUrl/api/sentiment");

    final response = await http.post(
      url,
      headers: {
        "Content-Type": "application/json; charset=utf-8",
        "Accept": "application/json",
      },
      body: jsonEncode({"text": text}),
    );

    if (response.statusCode == 200) {
      return jsonDecode(utf8.decode(response.bodyBytes));
    } else {
      throw Exception("API error: ${response.statusCode}");
    }
  }
}
