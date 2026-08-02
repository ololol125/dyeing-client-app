// lib/src/services/shop_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/designer.dart';
import '../models/shop.dart';

class ShopService {
  // 1. 소비자 앱에서 둘러볼 매장 목록 조회 (GET, 로그인 불필요)
  static Future<List<Shop>> getShops() async {
    final url = Uri.parse('${AppConstants.baseUrl}/v1/shops');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedRoot = json.decode(
          utf8.decode(response.bodyBytes),
        );

        if (decodedRoot['success'] == true) {
          final List<dynamic> shopsJson = decodedRoot['data'] ?? [];
          return shopsJson.map((item) => Shop.fromJson(item)).toList();
        } else {
          throw Exception(decodedRoot['error'] ?? '매장 목록을 불러오지 못했습니다.');
        }
      } else {
        throw Exception('서버 오류가 발생했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('매장 목록 조회 실패: $e');
    }
  }

  // 2. 특정 매장의 예약 가능한 디자이너 목록 조회 (GET, 로그인 불필요)
  static Future<List<Designer>> getDesigners(int shopId) async {
    final url = Uri.parse('${AppConstants.baseUrl}/v1/shops/$shopId/designers');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedRoot = json.decode(
          utf8.decode(response.bodyBytes),
        );

        if (decodedRoot['success'] == true) {
          final List<dynamic> designersJson = decodedRoot['data'] ?? [];
          return designersJson.map((item) => Designer.fromJson(item)).toList();
        } else {
          throw Exception(decodedRoot['error'] ?? '디자이너 목록을 불러오지 못했습니다.');
        }
      } else {
        throw Exception('서버 오류가 발생했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('디자이너 목록 조회 실패: $e');
    }
  }
}
