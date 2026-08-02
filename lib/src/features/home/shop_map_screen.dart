// lib/src/features/home/shop_map_screen.dart
import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart';
import 'package:flutter_naver_map/flutter_naver_map.dart';
import '../../models/shop.dart';
import '../../services/post_service.dart';
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

  const ShopMapScreen({Key? key, required this.shops}) : super(key: key);

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
      appBar: AppBar(
        title: const Text(
          '내 주변 염색방 지도',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
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
            Container(
              color: Colors.indigo[50],
              child: const Center(
                child: Text(
                  '네이버 지도는 모바일 앱(Android/iOS)에서만 지원됩니다.',
                  style: TextStyle(color: Colors.grey),
                ),
              ),
            ),

          // 2. 지도 위에 둥둥 떠있는 하단 매장 정보 카드 (가로 스크롤 가능)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            height: 110,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              itemCount: widget.shops.length,
              itemBuilder: (context, index) {
                final shop = widget.shops[index];
                final thumbnailUrl = _shopThumbnails[shop.shopId];
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () => _focusShop(shop),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: SizedBox(
                            width: 60,
                            height: 60,
                            child: thumbnailUrl != null
                                ? Image.network(
                                    thumbnailUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) =>
                                        _shopThumbnailPlaceholder(),
                                  )
                                : _shopThumbnailPlaceholder(),
                          ),
                        ),
                        title: Text(
                          shop.shopName,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                        subtitle: Text(
                          shop.baseAddress,
                          style: const TextStyle(fontSize: 11),
                        ),
                        trailing: IconButton(
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 16,
                            color: Colors.indigo,
                          ),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => ShopDetailScreen(shop: shop),
                              ),
                            );
                          },
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

  Widget _shopThumbnailPlaceholder() {
    return Container(
      color: Colors.indigo[50],
      child: const Icon(Icons.store, color: Colors.indigo),
    );
  }
}
