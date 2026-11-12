// lib/src/features/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../core/format.dart';
import '../../core/messages.dart';
import '../../core/theme.dart';
import '../../models/shop.dart';
import '../../services/post_service.dart';
import '../../services/shop_service.dart';
import '../../widgets/app_widgets.dart';
import '../shop/shop_detail_screen.dart';
import './shop_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Shop> _allShops = [];
  List<Shop> _filteredShops = [];
  bool _isLoading = true;
  String? _errorMessage;

  // shopId -> 매장 최신 게시물의 대표 이미지 URL (없으면 아이콘으로 대체 표시)
  Map<int, String> _shopThumbnails = {};

  @override
  void initState() {
    super.initState();
    _loadShops();
    _loadThumbnails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  // 실제 백엔드 DB에서 매장 목록을 동기화
  Future<void> _loadShops() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final shops = await ShopService.getShops();
      setState(() {
        _allShops = shops;
        _filteredShops = _applyFilter(shops, _searchController.text);
      });
    } catch (e) {
      setState(() => _errorMessage = friendlyError(e));
    } finally {
      setState(() => _isLoading = false);
    }
  }

  // 매장 카드에 쓸 대표 이미지를 매장별 최신 게시물에서 뽑아온다.
  // 실패하거나 게시물이 없어도 카드가 아이콘으로 정상 표시되므로 조용히 무시한다.
  Future<void> _loadThumbnails() async {
    try {
      final posts = await PostService.getPosts(); // 최신순 정렬로 내려옴
      final thumbnails = <int, String>{};
      for (final post in posts) {
        if (post.imageUrl != null &&
            post.imageUrl!.isNotEmpty &&
            !thumbnails.containsKey(post.shopId)) {
          thumbnails[post.shopId] = post.imageUrl!;
        }
      }
      if (mounted) setState(() => _shopThumbnails = thumbnails);
    } catch (_) {
      // 썸네일은 부가 정보라 실패해도 목록 자체는 계속 보여준다.
    }
  }

  // 매장 이름 또는 주소(동네 이름)로 찾기
  List<Shop> _applyFilter(List<Shop> shops, String query) {
    final q = query.trim();
    if (q.isEmpty) return shops;
    return shops
        .where((shop) => shop.shopName.contains(q) || shop.baseAddress.contains(q))
        .toList();
  }

  void _filterShops(String query) {
    setState(() => _filteredShops = _applyFilter(_allShops, query));
  }

  void _openMap() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ShopMapScreen(shops: _allShops)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('염색온')),
      body: _isLoading
          ? const LoadingMessage(text: '염색방 목록을 불러오는 중입니다')
          : _errorMessage != null
              ? StateMessage.error(message: _errorMessage!, onRetry: _loadShops)
              : RefreshIndicator(
                  onRefresh: _loadShops,
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(
                      AppSpacing.screen,
                      AppSpacing.sm,
                      AppSpacing.screen,
                      AppSpacing.xxl,
                    ),
                    children: [
                      ContentWidth(child: _buildSearchArea()),
                      const SizedBox(height: AppSpacing.xl),
                      if (_filteredShops.isEmpty)
                        _buildEmptyResult()
                      else
                        ..._filteredShops.map(
                          (shop) => ContentWidth(
                            child: _ShopCard(
                              shop: shop,
                              thumbnailUrl: _shopThumbnails[shop.shopId],
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
    );
  }

  Widget _buildSearchArea() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          '어느 염색방에 가실까요?',
          style: Theme.of(context).textTheme.headlineSmall,
        ),
        const SizedBox(height: AppSpacing.md),
        TextField(
          controller: _searchController,
          onChanged: (value) {
            _filterShops(value);
            setState(() {}); // 지우기 버튼 표시 갱신
          },
          textInputAction: TextInputAction.search,
          decoration: InputDecoration(
            hintText: '매장 이름이나 동네 이름',
            prefixIcon: const Icon(Icons.search, size: 28),
            suffixIcon: _searchController.text.isEmpty
                ? null
                : TextButton(
                    onPressed: () {
                      _searchController.clear();
                      _filterShops('');
                      setState(() {});
                    },
                    child: const Text('지우기'),
                  ),
          ),
        ),
        const SizedBox(height: AppSpacing.md),
        OutlinedButton.icon(
          onPressed: _allShops.isEmpty ? null : _openMap,
          icon: const Icon(Icons.map_outlined),
          label: const Text('지도에서 찾기'),
        ),
      ],
    );
  }

  Widget _buildEmptyResult() {
    final searching = _searchController.text.trim().isNotEmpty;
    return Padding(
      padding: const EdgeInsets.only(top: AppSpacing.xl),
      child: StateMessage(
        icon: Icons.search_off,
        title: searching ? '찾으시는 염색방이 없어요' : '등록된 염색방이 아직 없어요',
        message: searching ? '다른 이름이나 동네 이름으로 찾아보세요.' : null,
        actionLabel: searching ? '전체 매장 보기' : null,
        onAction: searching
            ? () {
                _searchController.clear();
                _filterShops('');
              }
            : null,
      ),
    );
  }
}

class _ShopCard extends StatelessWidget {
  final Shop shop;
  final String? thumbnailUrl;

  const _ShopCard({required this.shop, required this.thumbnailUrl});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppSpacing.lg),
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ShopDetailScreen(shop: shop)),
          );
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // 매장 대표 이미지 (매장 게시물의 최신 사진, 없으면 아이콘)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ShopThumbnail(imageUrl: thumbnailUrl),
            ),
            Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(shop.shopName, style: Theme.of(context).textTheme.headlineSmall),
                  const SizedBox(height: AppSpacing.xs),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(top: 3),
                        child: Icon(Icons.place_outlined, size: 22, color: AppColors.inkSub),
                      ),
                      const SizedBox(width: AppSpacing.xs),
                      Expanded(
                        child: Text(
                          shop.baseAddress,
                          style: const TextStyle(fontSize: AppTextSize.body, color: AppColors.inkSub),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                  // 가격은 크고 굵게, 시술별로 한 줄씩
                  _PriceLine(label: '뿌리 염색', price: shop.rootPrice),
                  const SizedBox(height: AppSpacing.xs),
                  _PriceLine(label: '전체 염색', price: shop.fullPrice),
                  const SizedBox(height: AppSpacing.md),
                  const Divider(),
                  const SizedBox(height: AppSpacing.sm),
                  const Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Text(
                        '매장 보기',
                        style: TextStyle(
                          fontSize: AppTextSize.button,
                          fontWeight: FontWeight.w700,
                          color: AppColors.primary,
                        ),
                      ),
                      Icon(Icons.chevron_right, size: 28, color: AppColors.primary),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PriceLine extends StatelessWidget {
  final String label;
  final int price;

  const _PriceLine({required this.label, required this.price});

  @override
  Widget build(BuildContext context) {
    return AmountRow(
      label: label,
      amount: formatWon(price),
      labelSize: AppTextSize.body,
      labelWeight: FontWeight.w400,
      amountSize: AppTextSize.button,
    );
  }
}
