// lib/src/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/reservation.dart';
import 'auth_service.dart';

class ApiService {
  // 공통 헤더 정의 (로그인 시 저장된 JWT 토큰을 실어 보냄)
  static Future<Map<String, String>> _getHeaders() async {
    final token = await AuthService.getToken();
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      if (token != null)
        'Authorization': 'Bearer $token', // Next.js 백엔드의 verifyAuth(req) 통과용
    };
  }

  // 1. 소비자의 예약 내역 목록 조회 (GET 연동)
  static Future<List<Reservation>> getMyReservations() async {
    // Next.js API 라우트 경로 세팅
    final url = Uri.parse('${AppConstants.baseUrl}/v1/reservations/client');

    try {
      final response = await http.get(url, headers: await _getHeaders());

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedRoot = json.decode(
          utf8.decode(response.bodyBytes),
        );

        if (decodedRoot['success'] == true) {
          final List<dynamic> reservationsJson = decodedRoot['data'] ?? [];
          return reservationsJson
              .map((item) => Reservation.fromJson(item))
              .toList();
        } else {
          throw Exception(decodedRoot['error'] ?? '데이터 구조 로드 실패');
        }
      } else if (response.statusCode == 401) {
        throw Exception('인증 토큰이 유효하지 않습니다. 다시 로그인해 주세요.');
      } else {
        throw Exception('서버 오류가 발생했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('예약 내역 동기화 실패: $e');
    }
  }

  // 2. 소비자의 새로운 미용실 예약 신청 (POST 연동)
  static Future<bool> createReservation({
    required int shopId,
    required int designerId,
    required DateTime reservationTime,
    required String menuType, // 'ROOT_DYE' or 'FULL_DYE'
    required int totalAmount,
    String? notes,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/v1/reservations/client');

    // 백엔드 POST의 const { shopId, ... } = body; 명세와 정확히 일치하는 페이로드 구성
    final Map<String, dynamic> requestBody = {
      'shopId': shopId,
      'designerId': designerId,
      'reservationTime': reservationTime.toIso8601String(),
      'menuType': menuType,
      'totalAmount': totalAmount,
      'notes': notes,
    };

    try {
      final response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final Map<String, dynamic> decodedResponse = json.decode(response.body);
        return decodedResponse['success'] == true;
      } else {
        final Map<String, dynamic> errorResponse = json.decode(response.body);
        print('🚨 예약 생성 실패 사유: ${errorResponse['error']}');
        return false;
      }
    } catch (e) {
      print('🚨 예약 생성 네트워크 에러: $e');
      return false;
    }
  }
}
