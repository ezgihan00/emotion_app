import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AuthApi {
  static const String baseUrl = "http://10.0.2.2:5000";
  // Emulator için localhost = 10.0.2.2

  static String? token;

  // 🔐 TOKEN KAYDET
  static Future<void> saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("token", value);
    token = value;
  }

  // 🔐 TOKEN OKU
  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("token");
  }

  // 🔐 TOKEN SİL (LOGOUT)
  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("token");
    token = null;
  }

  // 📝 REGISTER
  static Future<bool> register({
    required String email,
    required String username,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/register"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({
        "email": email,
        "username": username,
        "password": password,
      }),
    );

    return res.statusCode == 200 || res.statusCode == 201;
  }

  // 🔑 LOGIN
  static Future<bool> login({
    required String username,
    required String password,
  }) async {
    final res = await http.post(
      Uri.parse("$baseUrl/api/auth/login"),
      headers: {"Content-Type": "application/x-www-form-urlencoded"},
      body: {"username": username, "password": password},
    );

    if (res.statusCode == 200) {
      final data = jsonDecode(res.body);
      await saveToken(data["access_token"]);
      return true;
    }

    return false;
  }

  // 👤 ME (KULLANICI BİLGİSİ)
  static Future<Map<String, dynamic>?> getMe() async {
    await loadToken();
    if (token == null) return null;

    final res = await http.get(
      Uri.parse("$baseUrl/api/auth/me"),
      headers: {"Authorization": "Bearer $token"},
    );

    if (res.statusCode == 200) {
      return jsonDecode(res.body);
    }

    return null;
  }

  // 🚪 LOGOUT
  static Future<void> logout() async {
    await clearToken();
  }
}
