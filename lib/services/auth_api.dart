import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'api_config.dart';

/// API yanıt modeli
class ApiResponse {
  final bool ok;
  final int? statusCode;
  final String message;
  final Map<String, dynamic>? data;

  ApiResponse({
    required this.ok,
    this.statusCode,
    this.message = "",
    this.data,
  });
}

class AuthApi {
  static String? token;

  // ============ TOKEN YÖNETİMİ ============
  static Future<void> saveToken(String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString("auth_token", value);
    token = value;
  }

  static Future<void> loadToken() async {
    final prefs = await SharedPreferences.getInstance();
    token = prefs.getString("auth_token");
  }

  static Future<void> clearToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove("auth_token");
    token = null;
  }

  // ============ AUTH ENDPOINTS ============

  /// Kayıt ol - ApiResponse döndürür
  static Future<ApiResponse> register({
    required String email,
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/api/auth/register"),
            headers: {
              "Content-Type": "application/json",
              "Accept": "application/json",
            },
            body: jsonEncode({
              "email": email,
              "username": username,
              "password": password,
            }),
          )
          .timeout(const Duration(seconds: 15));

      final body = utf8.decode(response.bodyBytes);
      Map<String, dynamic>? jsonData;

      try {
        jsonData = jsonDecode(body);
      } catch (_) {}

      if (response.statusCode == 200 || response.statusCode == 201) {
        return ApiResponse(
          ok: true,
          statusCode: response.statusCode,
          message: jsonData?["message"] ?? "Kayıt başarılı",
          data: jsonData,
        );
      } else {
        return ApiResponse(
          ok: false,
          statusCode: response.statusCode,
          message:
              jsonData?["detail"] ?? jsonData?["message"] ?? "Kayıt başarısız",
        );
      }
    } catch (e) {
      return ApiResponse(
        ok: false,
        statusCode: null,
        message: "Bağlantı hatası: $e",
      );
    }
  }

  /// Giriş yap - ApiResponse döndürür
  static Future<ApiResponse> login({
    required String username,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("${ApiConfig.baseUrl}/api/auth/login"),
            headers: {
              "Content-Type": "application/x-www-form-urlencoded",
              "Accept": "application/json",
            },
            body: {
              "username": username,
              "password": password,
              "grant_type": "password",
            },
          )
          .timeout(const Duration(seconds: 15));

      final body = utf8.decode(response.bodyBytes);
      Map<String, dynamic>? jsonData;

      try {
        jsonData = jsonDecode(body);
      } catch (_) {}

      if (response.statusCode == 200) {
        final accessToken = jsonData?["access_token"];

        if (accessToken is String && accessToken.isNotEmpty) {
          await saveToken(accessToken);
          return ApiResponse(
            ok: true,
            statusCode: response.statusCode,
            message: "Giriş başarılı",
            data: jsonData,
          );
        } else {
          return ApiResponse(
            ok: false,
            statusCode: response.statusCode,
            message: "Token alınamadı",
          );
        }
      } else {
        return ApiResponse(
          ok: false,
          statusCode: response.statusCode,
          message:
              jsonData?["detail"] ??
              jsonData?["message"] ??
              "Kullanıcı adı veya şifre hatalı",
        );
      }
    } catch (e) {
      return ApiResponse(
        ok: false,
        statusCode: null,
        message: "Bağlantı hatası: $e",
      );
    }
  }

  /// Kullanıcı bilgisi getir
  static Future<Map<String, dynamic>?> getMe() async {
    await loadToken();
    if (token == null) return null;

    try {
      final response = await http
          .get(
            Uri.parse("${ApiConfig.baseUrl}/api/auth/me"),
            headers: {
              "Authorization": "Bearer $token",
              "Accept": "application/json",
            },
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(utf8.decode(response.bodyBytes));
      }

      if (response.statusCode == 401) {
        await clearToken();
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  /// Çıkış yap
  static Future<void> logout() async => clearToken();
}
