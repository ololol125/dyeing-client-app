// lib/src/features/home/shop_map_screen.dart
import 'package:flutter/material.dart';
import '../booking/booking_screen.dart';

class ShopMapScreen extends StatelessWidget {
  final List<Map<String, dynamic>> shops;

  const ShopMapScreen({Key? key, required this.shops}) : super(key: key);

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
          // 1. 지도 가상 영역 (실제 SDK 연동 시 이 컨테이너 자리에 GoogleMap 위젯이 들어갑니다)
          Container(
            color: Colors.indigo[50], // 지도 배경 대용
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.my_location, size: 36, color: Colors.blue),
                  const SizedBox(height: 8),
                  const Text(
                    '내 현재 위치 (대구)',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 40),
                  // 가상 마커 핀 유출
                  Icon(
                    Icons.location_on,
                    size: 40,
                    color: Colors.redAccent[700],
                  ),
                  Text(
                    shops[0]['shopName'],
                    style: const TextStyle(
                      backgroundColor: Colors.white,
                      fontSize: 12,
                    ),
                  ),
                ],
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
              itemCount: shops.length,
              itemBuilder: (context, index) {
                final shop = shops[index];
                return Container(
                  width: MediaQuery.of(context).size.width * 0.8,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  child: Card(
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(10),
                      leading: ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.network(
                          shop['imageUrl'],
                          width: 60,
                          height: 60,
                          fit: BoxFit.cover,
                        ),
                      ),
                      title: Text(
                        shop['shopName'],
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                      subtitle: Text(
                        '${shop['baseAddress']}\n📍 ${shop['distance']}',
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
                              builder: (context) =>
                                  BookingScreen(shopName: shop['shopName']),
                            ),
                          );
                        },
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
