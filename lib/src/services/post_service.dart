// lib/src/services/post_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../core/constants.dart';
import '../models/post.dart';

class PostService {
  // 공개 게시물 전체 피드 조회 (GET, 로그인 불필요)
  // shopId를 넘기면 해당 매장의 게시물만 걸러서 반환한다.
  static Future<List<Post>> getPosts({int? shopId}) async {
    final url = Uri.parse('${AppConstants.baseUrl}/v1/posts');

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedRoot = json.decode(
          utf8.decode(response.bodyBytes),
        );

        if (decodedRoot['success'] == true) {
          final List<dynamic> postsJson = decodedRoot['data'] ?? [];
          final posts = postsJson.map((item) => Post.fromJson(item)).toList();
          if (shopId == null) return posts;
          return posts.where((post) => post.shopId == shopId).toList();
        } else {
          throw Exception(decodedRoot['error'] ?? '게시물 목록을 불러오지 못했습니다.');
        }
      } else {
        throw Exception('서버 오류가 발생했습니다. (코드: ${response.statusCode})');
      }
    } catch (e) {
      throw Exception('게시물 목록 조회 실패: $e');
    }
  }
}
