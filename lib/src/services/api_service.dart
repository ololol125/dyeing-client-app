// lib/src/services/api_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/payment_session.dart';
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
        await AuthService.expireSession();
        throw Exception('인증 토큰이 유효하지 않습니다. 다시 로그인해 주세요.');
      } else {
        throw Exception('서버 오류가 발생했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('예약 내역 동기화 실패: $e');
    }
  }

  // 2. 결제 준비 (POST): 서버가 금액을 계산해 포트원에 사전 등록하고 결제창 호출 정보를 반환
  static Future<PaymentSession> preparePayment({
    required int shopId,
    required int designerId,
    required DateTime reservationTime,
    required String menuType, // 'ROOT_DYE' or 'FULL_DYE'
    required String payMethod, // 'CARD' or 'KAKAOPAY'
    String? notes,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/v1/payments/prepare');

    final Map<String, dynamic> requestBody = {
      'shopId': shopId,
      'designerId': designerId,
      // 시간대가 포함된 UTC 시각으로 전송 (서버는 UTC로 동작)
      'reservationTime': reservationTime.toUtc().toIso8601String(),
      'menuType': menuType,
      'payMethod': payMethod,
      'notes': notes,
    };

    final http.Response response;
    try {
      response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode(requestBody),
      );
    } on http.ClientException catch (e) {
      throw Exception('결제 준비 중 네트워크 오류가 발생했습니다: $e');
    }

    if (response.statusCode == 401) {
      await AuthService.expireSession();
      throw Exception('로그인이 만료되었습니다. 다시 로그인해 주세요.');
    }

    final Map<String, dynamic> decoded = json.decode(
      utf8.decode(response.bodyBytes),
    );
    if (response.statusCode == 201 && decoded['success'] == true) {
      return PaymentSession.fromJson(decoded['data']);
    }
    throw Exception(decoded['error'] ?? '결제를 준비하지 못했습니다.');
  }

  // 3. 결제 완료 처리 (POST): 서버가 포트원에서 결제를 검증한 뒤 예약을 확정
  static Future<void> completePayment(String paymentId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/v1/payments/complete');

    final http.Response response;
    try {
      response = await http.post(
        url,
        headers: await _getHeaders(),
        body: json.encode({'paymentId': paymentId}),
      );
    } on http.ClientException catch (e) {
      throw Exception('결제 확인 중 네트워크 오류가 발생했습니다: $e');
    }

    if (response.statusCode == 401) {
      await AuthService.expireSession();
      throw Exception('로그인이 만료되었습니다. 다시 로그인해 주세요.');
    }

    final Map<String, dynamic> decoded = json.decode(
      utf8.decode(response.bodyBytes),
    );
    if (response.statusCode == 200 && decoded['success'] == true) {
      return;
    }
    throw Exception(decoded['error'] ?? '결제를 확인하지 못했습니다.');
  }
}
