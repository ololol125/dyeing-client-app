// lib/src/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/reservation.dart';

class ApiService {
  // 🔑 인증용 가짜 토큰 (로그인 기능 연동 전 임시 사용)
  // 실제 연동 시 로컬 스토리지에 저장된 사용자 JWT 토큰 값을 동적으로 넣어주어야 합니다.
  static const String _mockToken =
      'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJ1c2VySWQiOjcsImVtYWlsIjoieWVvbmdoeWVvbjA1QGdtYWlsLmNvbSIsInJvbGUiOiJDTElFTlQiLCJpYXQiOjE3ODMyNjczMTMsImV4cCI6MTc4Mzg3MjExM30.iNlvAQPrY3FQRm4GhHjgYYd-SM1Yo8StBgTHWGeTeYo';

  // 공통 헤더 정의
  static Map<String, String> _getHeaders() {
    return {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      'Authorization': 'Bearer $_mockToken', // Next.js 백엔드의 verifyAuth(req) 통과용
    };
  }

  // 1. 소비자의 예약 내역 목록 조회 (GET 연동)
  static Future<List<Reservation>> getMyReservations() async {
    // Next.js API 라우트 경로 세팅
    final url = Uri.parse('${AppConstants.baseUrl}/v1/reservations/client');

    try {
      final response = await http.get(url, headers: _getHeaders());

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
        headers: _getHeaders(),
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
