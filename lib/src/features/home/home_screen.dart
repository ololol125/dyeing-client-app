// lib/src/features/home/home_screen.dart
import 'package:flutter/material.dart';
import '../booking/booking_screen.dart';
import './shop_map_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  // 📝 DB 스키마(shop)에 맞춘 임시 매장 구조화 데이터
  final List<Map<String, dynamic>> _allShops = [
    {
      "shopName": "영현네 뿌리염색 전문점",
      "baseAddress": "대구 중구 삼덕동 1가",
      "distance": "350m",
      "imageUrl":
          "https://images.unsplash.com/photo-1560066984-138dadb4c035?w=500&q=80",
    },
    {
      "shopName": "찰스 전체염색 삼덕점",
      "baseAddress": "대구 중구 삼덕동 2가",
      "distance": "1.2km",
      "imageUrl":
          "https://images.unsplash.com/photo-1522335789203-aabd1fc54bc9?w=500&q=80",
    },
    {
      "shopName": "깔끔염색방 대구점",
      "baseAddress": "대구 북구 대학로 80 (산격동)",
      "distance": "4.5km",
      "imageUrl":
          "https://cdn.imweb.me/upload/S20200421b6b9cc7b086ce/96a7ada89babf.jpg",
    },
  ];

  List<Map<String, dynamic>> _filteredShops = [];

  @override
  void initState() {
    super.initState();
    _filteredShops = _allShops;
  }

  void _filterShops(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredShops = _allShops;
      } else {
        _filteredShops = _allShops
            .where(
              (shop) =>
                  shop["shopName"].toLowerCase().contains(query.toLowerCase()),
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

              // 🔄 이 부분의 suffixIcon 로직을 변경합니다!
              suffixIcon: _searchController.text.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear, color: Colors.grey),
                      onPressed: () {
                        _searchController.clear();
                        _filterShops('');
                      },
                    )
                  : IconButton(
                      icon: const Icon(
                        Icons.map,
                        color: Colors.indigo,
                      ), // 🗺️ 지도 버튼 배치
                      onPressed: () {
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
      body: _filteredShops.isEmpty
          ? const Center(
              child: Text(
                '검색 결과와 일치하는 염색방이 없습니다.',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : ListView.builder(
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
                          builder: (context) =>
                              BookingScreen(shopName: shop["shopName"]),
                        ),
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // 1. 매장 이미지 (모서리가 둥근 사각형)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              shop["imageUrl"],
                              width: 80,
                              height: 80,
                              fit: BoxFit.cover,
                              // 이미지 로딩 실패 시 플레이스홀더 아이콘 표시
                              errorBuilder: (context, error, stackTrace) =>
                                  Container(
                                    width: 80,
                                    height: 80,
                                    color: Colors.grey[200],
                                    child: const Icon(
                                      Icons.store,
                                      color: Colors.grey,
                                    ),
                                  ),
                            ),
                          ),
                          const SizedBox(width: 12),

                          // 2. 매장 정보 텍스트 영역
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // 매장 이름
                                Text(
                                  shop["shopName"],
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 6),
                                // 매장 주소
                                Text(
                                  shop["baseAddress"],
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey[600],
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 8),
                                // 현재 주소에서 거리 표시 (위치 아이콘 포함)
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.location_on,
                                      size: 14,
                                      color: Colors.redAccent,
                                    ),
                                    const SizedBox(width: 2),
                                    Text(
                                      shop["distance"],
                                      style: const TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.redAccent,
                                      ),
                                    ),
                                  ],
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
    );
  }
}
