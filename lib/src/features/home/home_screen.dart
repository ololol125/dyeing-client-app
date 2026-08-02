// lib/src/features/home/home_screen.dart
import 'package:flutter/material.dart';
import '../../models/shop.dart';
import '../../services/shop_service.dart';
import '../shop/shop_detail_screen.dart';
import './shop_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  List<Shop> _allShops = [];
  List<Shop> _filteredShops = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _loadShops();
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
        _filteredShops = shops;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString().replaceFirst('Exception: ', '');
      });
    } finally {
      setState(() => _isLoading = false);
    }
  }

  void _filterShops(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredShops = _allShops;
      } else {
        _filteredShops = _allShops
            .where(
              (shop) => shop.shopName.toLowerCase().contains(
                query.toLowerCase(),
              ),
            )
            .toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Container(
          width: double.infinity,
          height: 45,
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(12),
          ),
          child: TextField(
            controller: _searchController,
            onChanged: _filterShops,
            decoration: InputDecoration(
              hintText: '염색방 이름이나 지역을 검색해 보세요',
              hintStyle: TextStyle(color: Colors.grey[500], fontSize: 14),
              prefixIcon: const Icon(Icons.search, color: Colors.grey),
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _filterShops('');
                      },
                    )
                  : IconButton(
                      icon: const Icon(Icons.map, color: Colors.indigo),
                      onPressed: _allShops.isEmpty
                          ? null
                          : () {
                              // 지도 화면으로 이동하며 현재 매장 데이터를 넘겨줍니다.
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      ShopMapScreen(shops: _allShops),
                                ),
                              );
                            },
                    ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(vertical: 12),
            ),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _errorMessage != null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(_errorMessage!, style: const TextStyle(color: Colors.grey)),
                  const SizedBox(height: 12),
                  TextButton(onPressed: _loadShops, child: const Text('다시 시도')),
                ],
              ),
            )
          : _filteredShops.isEmpty
          ? const Center(
              child: Text(
                '검색 결과와 일치하는 염색방이 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : RefreshIndicator(
              onRefresh: _loadShops,
              child: ListView.builder(
                itemCount: _filteredShops.length,
                itemBuilder: (context, index) {
                  final shop = _filteredShops[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    elevation: 2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: InkWell(
                      borderRadius: BorderRadius.circular(12),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => ShopDetailScreen(shop: shop),
                          ),
                        );
                      },
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 매장 대표 아이콘 (DB에 매장 이미지 필드가 없어 아이콘으로 대체)
                            Container(
                              width: 80,
                              height: 80,
                              decoration: BoxDecoration(
                                color: Colors.indigo[50],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: const Icon(
                                Icons.store,
                                color: Colors.indigo,
                                size: 32,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // 매장 정보 텍스트 영역
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    shop.shopName,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 6),
                                  Text(
                                    shop.baseAddress,
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  const SizedBox(height: 8),
                                  Text(
                                    '뿌리 ${shop.rootPrice}원 · 전체 ${shop.fullPrice}원',
                                    style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.redAccent,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
