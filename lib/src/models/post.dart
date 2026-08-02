// lib/src/models/post.dart
class Post {
  final int postId;
  final int shopId;
  final String title;
  final String? content;
  final String? imageUrl;
  final String status; // 'PUBLISHED' or 'DRAFT'
  final DateTime? createdAt;

  Post({
    required this.postId,
    required this.shopId,
    required this.title,
    this.content,
    this.imageUrl,
    required this.status,
    this.createdAt,
  });

  // Next.js (Prisma) 백엔드 GET /v1/posts 응답 데이터 파싱
  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      postId: json['postId'],
      shopId: json['shopId'],
      title: json['title'],
      content: json['content'],
      imageUrl: json['imageUrl'],
      status: json['status'] ?? 'PUBLISHED',
      createdAt: json['createdAt'] != null
          ? DateTime.tryParse(json['createdAt'])
          : null,
    );
  }
}
