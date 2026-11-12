// lib/src/services/auth_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants.dart';
import '../models/user.dart';

class AuthService {
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'auth_user';

  // 저장된 토큰이 만료/무효화됐을 때 호출 (main.dart에서 로그인 화면 이동을 등록)
  static void Function()? onSessionExpired;

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

  // 토큰이 있고 만료되지 않았을 때만 로그인 상태로 본다 (만료된 토큰은 정리)
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    if (token == null) return false;
    if (_isExpired(token)) {
      await logout();
      return false;
    }
    return true;
  }

  // 서버가 401을 돌려준 경우: 저장된 로그인 정보를 지우고 로그인 화면으로 보낸다
  static Future<void> expireSession() async {
    if (await getToken() == null) return; // 이미 처리됨 (동시 요청 대비)
    await logout();
    onSessionExpired?.call();
  }

  // JWT payload의 exp(초 단위)를 확인. 디코딩할 수 없는 토큰은 만료로 취급
  static bool _isExpired(String token) {
    try {
      final parts = token.split('.');
      if (parts.length != 3) return true;
      final payload = json.decode(
        utf8.decode(base64Url.decode(base64Url.normalize(parts[1]))),
      );
      final exp = payload['exp'];
      if (exp is! int) return false;
      final expiresAt = DateTime.fromMillisecondsSinceEpoch(exp * 1000);
      return DateTime.now().isAfter(expiresAt);
    } catch (_) {
      return true;
    }
  }

  // 5. 회원 탈퇴 (DELETE /v1/users/me): 성공하면 기기에 저장된 로그인 정보도 지운다
  static Future<void> deleteAccount() async {
    final token = await getToken();
    final url = Uri.parse('${AppConstants.baseUrl}/v1/users/me');

    final http.Response response;
    try {
      response = await http.delete(
        url,
        headers: {
          'Accept': 'application/json',
          if (token != null) 'Authorization': 'Bearer $token',
        },
      );
    } on http.ClientException catch (e) {
      throw Exception('탈퇴 처리 중 네트워크 오류가 발생했습니다: $e');
    }

    if (response.statusCode == 401) {
      await expireSession();
      throw Exception('로그인이 만료되었습니다. 다시 로그인한 뒤 탈퇴해 주세요.');
    }

    final Map<String, dynamic> decoded = json.decode(utf8.decode(response.bodyBytes));
    if (response.statusCode == 200 && decoded['success'] == true) {
      await logout();
      return;
    }
    throw Exception(decoded['error'] ?? '탈퇴를 처리하지 못했습니다.');
  }

  // 6. 로그아웃
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
  }
}
