import 'dart:convert';
import 'package:http/http.dart' as http;
import 'api_config.dart';

class SentimentApi {
  static Future<Map<String, dynamic>> hybridChat({
    required String message,
    String? userId,
    bool useAi = false,
  }) async {
    final url = Uri.parse("${ApiConfig.baseUrl}/api/hybrid/chat");

    final res = await http
        .post(
          url,
          headers: const {
            "Content-Type": "application/json; charset=utf-8",
            "Accept": "application/json",
          },
          body: jsonEncode({
            "message": message,
            "use_ai": useAi,
            if (userId != null) "user_id": userId,
          }),
        )
        .timeout(const Duration(seconds: 30));

    final body = utf8.decode(res.bodyBytes);

    // DEBUG: Backend ne dönüyor gör
    // ignore: avoid_print
    print("HYBRID CHAT STATUS: ${res.statusCode}");
    // ignore: avoid_print
    print("HYBRID CHAT BODY: $body");

    if (res.statusCode != 200) {
      throw Exception("HTTP ${res.statusCode}: $body");
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) return decoded;

    if (decoded is Map) return Map<String, dynamic>.from(decoded);

    throw Exception("Beklenmeyen response tipi: ${decoded.runtimeType}");
  }
}
