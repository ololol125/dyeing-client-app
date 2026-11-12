// lib/src/features/home/shop_map_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../core/format.dart';
import '../../core/theme.dart';
import '../../models/shop.dart';
import '../../services/post_service.dart';
import '../../widgets/app_widgets.dart';
import '../shop/shop_detail_screen.dart';

// 매장이 하나도 없을 때 지도가 띄울 기본 좌표 (대구 중구)
const _fallbackCenter = NLatLng(35.8714, 128.6014);

// 네이버 지도 SDK는 Android/iOS 네이티브 전용
bool get _isMapSupportedPlatform =>
    !kIsWeb &&
    (defaultTargetPlatform == TargetPlatform.android ||
        defaultTargetPlatform == TargetPlatform.iOS);

class ShopMapScreen extends StatefulWidget {
  final List<Shop> shops;

  const ShopMapScreen({super.key, required this.shops});

  @override
  State<ShopMapScreen> createState() => _ShopMapScreenState();
}

class _ShopMapScreenState extends State<ShopMapScreen> {
  NaverMapController? _mapController;

  // shopId -> 매장 최신 게시물의 대표 이미지 URL (없으면 아이콘으로 대체 표시)
  Map<int, String> _shopThumbnails = {};

  @override
  void initState() {
    super.initState();
    _loadThumbnails();
  }

  // 실패해도 지도/카드 자체는 아이콘으로 정상 표시되므로 조용히 무시한다.
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
      // no-op
    }
  }

  NLatLng get _initialCenter {
    if (widget.shops.isEmpty) return _fallbackCenter;
    return NLatLng(widget.shops.first.latitude, widget.shops.first.longitude);
  }

  Future<void> _onMapReady(NaverMapController controller) async {
    _mapController = controller;

    for (final shop in widget.shops) {
      final marker = NMarker(
        id: shop.shopId.toString(),
        position: NLatLng(shop.latitude, shop.longitude),
        caption: NOverlayCaption(text: shop.shopName),
      );
      await controller.addOverlay(marker);
    }
  }

  Future<void> _focusShop(Shop shop) async {
    final controller = _mapController;
    if (controller == null) return;

    await controller.updateCamera(
      NCameraUpdate.withParams(
        target: NLatLng(shop.latitude, shop.longitude),
        zoom: 15,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('지도에서 찾기')),
      body: Stack(
        children: [
          // 1. 네이버 지도 (매장별 마커 표시). Web/데스크톱에서는 미지원 안내로 대체
          if (_isMapSupportedPlatform)
            NaverMap(
              options: NaverMapViewOptions(
                initialCameraPosition: NCameraPosition(
                  target: _initialCenter,
                  zoom: 12,
                ),
              ),
              onMapReady: _onMapReady,
            )
          else
            const StateMessage(
              icon: Icons.map_outlined,
              title: '이 기기에서는 지도를 볼 수 없어요',
              message: '휴대폰이나 태블릿 앱에서 이용해 주세요.',
            ),

          // 2. 지도 아래쪽 매장 카드 (옆으로 넘겨 보기). 카드를 누르면 지도가 그 매장으로 이동
          Positioned(
            bottom: AppSpacing.lg,
            left: 0,
            right: 0,
            height: 196,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
              itemCount: widget.shops.length,
              itemBuilder: (context, index) {
                final shop = widget.shops[index];
                final width = MediaQuery.of(context).size.width;
                return Container(
                  width: width > 600 ? 420 : width * 0.86,
                  margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xs),
                  child: Card(
                    margin: EdgeInsets.zero,
                    elevation: 3,
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => _focusShop(shop),
                      child: Padding(
                        padding: const EdgeInsets.all(AppSpacing.md),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(AppRadius.md),
                                  child: SizedBox(
                                    width: 72,
                                    height: 72,
                                    child: ShopThumbnail(
                                      imageUrl: _shopThumbnails[shop.shopId],
                                      iconSize: 32,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppSpacing.md),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        shop.shopName,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: Theme.of(context).textTheme.titleLarge,
                                      ),
                                      Text(
                                        '뿌리 염색 ${formatWon(shop.rootPrice)}',
                                        style: const TextStyle(
                                          fontSize: AppTextSize.body,
                                          fontWeight: FontWeight.w700,
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const Spacer(),
                            OutlinedButton(
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ShopDetailScreen(shop: shop),
                                  ),
                                );
                              },
                              child: const Text('매장 보기'),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
