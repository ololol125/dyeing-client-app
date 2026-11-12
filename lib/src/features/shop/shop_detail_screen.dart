import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/format.dart';
import '../../core/messages.dart';
import '../../core/theme.dart';
import '../../models/post.dart';
import '../../models/shop.dart';
import '../../services/post_service.dart';
import '../../widgets/app_widgets.dart';
import '../booking/booking_screen.dart';

// 매장 상세 화면: 전화·길찾기를 가장 위에 크게 두고, 가격·영업시간·매장 소식을 보여준다.
// 여기서 예약 화면으로 이어진다.
class ShopDetailScreen extends StatefulWidget {
  final Shop shop;

  const ShopDetailScreen({super.key, required this.shop});

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
      setState(() => _postsError = friendlyError(e));
    } finally {
      setState(() => _isLoadingPosts = false);
    }
  }

  bool get _hasPhone =>
      widget.shop.phone != null && widget.shop.phone!.trim().isNotEmpty;

  Future<void> _call() async {
    final number = widget.shop.phone!.replaceAll(RegExp(r'[^0-9+]'), '');
    final opened = await launchUrl(Uri(scheme: 'tel', path: number));
    if (!opened && mounted) {
      showAppMessage(context, '전화를 걸 수 없어요. 매장 번호: ${widget.shop.phone}');
    }
  }

  // 네이버 지도에서 매장 주소를 찾아 길찾기를 시작할 수 있게 연다 (앱이 없으면 웹으로)
  Future<void> _openDirections() async {
    final query = Uri.encodeComponent(
      '${widget.shop.shopName} ${widget.shop.baseAddress}',
    );
    final opened = await launchUrl(
      Uri.parse('https://map.naver.com/p/search/$query'),
      mode: LaunchMode.externalApplication,
    );
    if (!opened && mounted) {
      showAppMessage(context, '지도를 열 수 없어요. 주소: ${widget.shop.baseAddress}');
    }
  }

  @override
  Widget build(BuildContext context) {
    final shop = widget.shop;

    return Scaffold(
      appBar: AppBar(title: const Text('매장 정보')),
      body: RefreshIndicator(
        onRefresh: _loadPosts,
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.screen,
            AppSpacing.sm,
            AppSpacing.screen,
            AppSpacing.xxl,
          ),
          children: [
            ContentWidth(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    shop.shopName,
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    shop.baseAddress,
                    style: const TextStyle(
                      fontSize: AppTextSize.body,
                      color: AppColors.inkSub,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),
                  _buildContactButtons(),
                  const SizedBox(height: AppSpacing.xl),
                  _buildPriceCard(shop),
                  const SizedBox(height: AppSpacing.md),
                  _buildInfoCard(shop),
                  const SizedBox(height: AppSpacing.xl),
                  const SectionTitle('매장 소식'),
                  _buildPostsSection(),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomActionBar(
        child: PrimaryButton(
          label: '예약하기',
          icon: Icons.event_available,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => BookingScreen(shop: shop),
              ),
            );
          },
        ),
      ),
    );
  }

  // 전화하기 / 길찾기: 화면 맨 위에 크게
  Widget _buildContactButtons() {
    final directions = OutlinedButton.icon(
      onPressed: _openDirections,
      icon: const Icon(Icons.directions_outlined),
      label: const Text('길찾기'),
    );
    if (!_hasPhone) return directions;

    return Row(
      children: [
        Expanded(
          child: OutlinedButton.icon(
            onPressed: _call,
            icon: const Icon(Icons.call_outlined),
            label: const Text('전화하기'),
          ),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(child: directions),
      ],
    );
  }

  Widget _buildPriceCard(Shop shop) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('시술 가격', style: Theme.of(context).textTheme.titleLarge),
            const SizedBox(height: AppSpacing.md),
            _priceRow('뿌리 염색', '자라난 뿌리 부분만', shop.rootPrice),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: AppSpacing.md),
              child: Divider(),
            ),
            _priceRow('전체 염색', '단발 기준 · 길이에 따라 추가 요금', shop.fullPrice),
          ],
        ),
      ),
    );
  }

  Widget _priceRow(String name, String note, int price) {
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      crossAxisAlignment: WrapCrossAlignment.end,
      spacing: AppSpacing.md,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              name,
              style: const TextStyle(
                fontSize: AppTextSize.button,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              note,
              style: const TextStyle(
                fontSize: AppTextSize.caption,
                color: AppColors.inkSub,
              ),
            ),
          ],
        ),
        Text(
          formatWon(price),
          style: const TextStyle(
            fontSize: AppTextSize.title,
            fontWeight: FontWeight.w700,
            color: AppColors.primary,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(Shop shop) {
    final hasHours =
        shop.businessHours != null && shop.businessHours!.trim().isNotEmpty;
    final hasDescription =
        shop.description != null && shop.description!.trim().isNotEmpty;
    if (!_hasPhone && !hasHours && !hasDescription) {
      return const SizedBox.shrink();
    }

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (hasDescription) ...[
              Text(
                shop.description!,
                style: const TextStyle(fontSize: AppTextSize.body, height: 1.6),
              ),
              if (_hasPhone || hasHours) ...[
                const SizedBox(height: AppSpacing.md),
                const Divider(),
                const SizedBox(height: AppSpacing.sm),
              ],
            ],
            if (hasHours)
              InfoRow(
                icon: Icons.schedule,
                label: '영업시간',
                value: shop.businessHours!,
              ),
            if (_hasPhone)
              InfoRow(
                icon: Icons.call_outlined,
                label: '전화번호',
                value: shop.phone!,
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPostsSection() {
    if (_isLoadingPosts) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.xl),
        child: LoadingMessage(text: '매장 소식을 불러오는 중입니다'),
      );
    }

    if (_postsError != null) {
      return StateMessage.error(message: _postsError!, onRetry: _loadPosts);
    }

    if (_posts.isEmpty) {
      return const Padding(
        padding: EdgeInsets.symmetric(vertical: AppSpacing.lg),
        child: Text(
          '아직 올라온 매장 소식이 없어요.',
          style: TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
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

  @override
  Widget build(BuildContext context) {
    final date = post.createdAt?.toLocal();

    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (post.imageUrl != null && post.imageUrl!.isNotEmpty)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ShopThumbnail(imageUrl: post.imageUrl),
            ),
          Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(post.title, style: Theme.of(context).textTheme.titleLarge),
                if (post.content != null && post.content!.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    post.content!,
                    style: const TextStyle(
                      fontSize: AppTextSize.body,
                      height: 1.6,
                    ),
                  ),
                ],
                if (date != null) ...[
                  const SizedBox(height: AppSpacing.md),
                  Text(
                    '${date.year}년 ${formatDate(date)}',
                    style: const TextStyle(
                      fontSize: AppTextSize.caption,
                      color: AppColors.inkSub,
                    ),
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
