// lib/src/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // 1. 로그인 (POST /v1/users/login)
  static Future<AppUser> login({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/v1/users/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'password': password}),
      );

      final Map<String, dynamic> decoded = json.decode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 200 && decoded['success'] == true) {
        final String token = decoded['token'];
        final AppUser user = AppUser.fromJson(decoded['user']);

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_tokenKey, token);
        await prefs.setString(_userKey, json.encode(user.toJson()));

        return user;
      } else {
        throw Exception(decoded['error'] ?? '로그인에 실패했습니다.');
      }
    } on http.ClientException catch (e) {
      throw Exception('로그인 중 네트워크 오류가 발생했습니다: $e');
    }
  }

  // 2. 회원가입 (POST /v1/users/signup) - 소비자 앱이므로 role은 CLIENT로 고정
  static Future<void> signup({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/v1/users/signup');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
          'name': name,
          'phone': phone,
          'role': 'CLIENT',
        }),
      );

      final Map<String, dynamic> decoded = json.decode(
        utf8.decode(response.bodyBytes),
      );

      if (response.statusCode == 201 && decoded['success'] == true) {
        return;
      } else {
        throw Exception(decoded['error'] ?? '회원가입에 실패했습니다.');
      }
    } on http.ClientException catch (e) {
      throw Exception('회원가입 중 네트워크 오류가 발생했습니다: $e');
    }
  }

  // 3. 저장된 토큰 조회 (ApiService의 인증 헤더 구성에 사용)
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  // 4. 저장된 로그인 사용자 정보 조회
  static Future<AppUser?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson == null) return null;
    return AppUser.fromJson(json.decode(userJson));
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // 5. 로그아웃
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
