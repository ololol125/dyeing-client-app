// lib/src/features/shop/shop_detail_screen.dart
import 'package:flutter/material.dart';
import '../../models/post.dart';
import '../../models/shop.dart';
import '../../services/post_service.dart';
import '../booking/booking_screen.dart';

// 매장 상세 화면: 매장 소개/연락처/영업시간과 매장 소식(게시물) 피드를 보여주고,
// 여기서 예약 화면으로 이어진다.
class ShopDetailScreen extends StatefulWidget {
  final Shop shop;

  const ShopDetailScreen({Key? key, required this.shop}) : super(key: key);

  @override
  State<ShopDetailScreen> createState() => _ShopDetailScreenState();
}

class _ShopDetailScreenState extends State<ShopDetailScreen> {
  List<Post> _posts = [];
  bool _isLoadingPosts = true;
  String? _postsError;

  @override
  void initState() {
    super.initState();
    _loadPosts();
  }

  Future<void> _loadPosts() async {
    setState(() {
      _isLoadingPosts = true;
      _postsError = null;
    });

    try {
      final posts = await PostService.getPosts(shopId: widget.shop.shopId);
      setState(() => _posts = posts);
    } catch (e) {
      setState(() {
        _postsError = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _isLoadingPosts = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          shop.shopName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            _buildShopHeader(shop),
            const SizedBox(height: 24),
            const Text(
              '매장 소식',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildPostsSection(),
          ],
        ),
      ),
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.grey[200]!,
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SafeArea(
          child: SizedBox(
            width: double.infinity,
            height: 50,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.indigo,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => BookingScreen(shop: shop),
                  ),
                );
              },
              child: const Text(
                '예약하기',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildShopHeader(Shop shop) {
    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              shop.shopName,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.indigo,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              shop.baseAddress,
              style: TextStyle(fontSize: 13, color: Colors.grey[600]),
            ),
            if (shop.description != null && shop.description!.isNotEmpty) ...[
              const SizedBox(height: 12),
              Text(
                shop.description!,
                style: const TextStyle(fontSize: 14, height: 1.4),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(height: 1),
            const SizedBox(height: 12),
            if (shop.phone != null && shop.phone!.isNotEmpty)
              _infoRow(Icons.call_outlined, '전화번호', shop.phone!),
            if (shop.businessHours != null && shop.businessHours!.isNotEmpty) ...[
              const SizedBox(height: 8),
              _infoRow(Icons.access_time, '영업시간', shop.businessHours!),
            ],
            const SizedBox(height: 8),
            _infoRow(
              Icons.payments_outlined,
              '가격',
              '뿌리 ${shop.rootPrice}원 · 전체 ${shop.fullPrice}원',
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 16, color: Colors.grey[500]),
        const SizedBox(width: 8),
        SizedBox(
          width: 70,
          child: Text(label, style: TextStyle(fontSize: 13, color: Colors.grey[600])),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500),
          ),
        ),
      ],
    );
  }

  Widget _buildPostsSection() {
    if (_isLoadingPosts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(child: CircularProgressIndicator()),
      );
    }

    if (_postsError != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(_postsError!, style: const TextStyle(color: Colors.grey)),
          TextButton(onPressed: _loadPosts, child: const Text('다시 시도')),
        ],
      );
    }

    if (_posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: 24),
        child: Center(
          child: Text(
            '아직 등록된 매장 소식이 없습니다.',
            style: TextStyle(color: Colors.grey),
          ),
        ),
      );
    }

    return Column(
      children: _posts.map((post) => _PostCard(post: post)).toList(),
    );
  }
}

class _PostCard extends StatelessWidget {
  final Post post;

  const _PostCard({required this.post});

  String get _dateLabel {
    final date = post.createdAt;
    if (date == null) return '';
    return '${date.year}.${date.month.toString().padLeft(2, '0')}.${date.day.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.grey[200]!),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.grey[100],
                  child: const Icon(Icons.broken_image_outlined, color: Colors.grey),
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.title,
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                ),
                if (post.content != null && post.content!.isNotEmpty) ...[
                  const SizedBox(height: 6),
                  Text(
                    post.content!,
                    style: TextStyle(fontSize: 13, color: Colors.grey[700], height: 1.4),
                  ),
                ],
                if (_dateLabel.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Text(
                    _dateLabel,
                    style: TextStyle(fontSize: 11, color: Colors.grey[400]),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
