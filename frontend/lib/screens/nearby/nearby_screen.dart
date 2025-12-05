import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/food_item_card.dart';
import '../../services/food_item_service.dart';

class NearbyScreen extends StatefulWidget {
  const NearbyScreen({super.key});

  @override
  State<NearbyScreen> createState() => _NearbyScreenState();
}

class _NearbyScreenState extends State<NearbyScreen> {
  List<dynamic> _nearbyShops = [];
  List<dynamic> _nearbyFoods = [];
  bool _isLoading = true;
  String _currentLocation = 'Đang xác định vị trí...';
  double _selectedRadius = 5.0; // km

  @override
  void initState() {
    super.initState();
    _loadNearbyData();
  }

  Future<void> _loadNearbyData() async {
    setState(() => _isLoading = true);
    try {
      // TODO: Integrate with location service and backend
      // Giả lập data
      await Future.delayed(const Duration(milliseconds: 500));
      
      final foodResponse = await FoodItemService.getAllFoodItems();
      
      setState(() {
        _currentLocation = '123 Nguyễn Văn Cừ, Q.5, TP.HCM';
        _nearbyFoods = foodResponse['data'] ?? [];
        _nearbyShops = [
          {
            'id': 1,
            'name': 'Quán Phở Hà Nội',
            'image': 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=400',
            'rating': 4.8,
            'distance': '0.5 km',
            'address': '45 Lê Văn Sỹ, Q.3',
            'isOpen': true,
            'deliveryTime': '15-20 phút',
          },
          {
            'id': 2,
            'name': 'Cơm Tấm Sài Gòn',
            'image': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=400',
            'rating': 4.5,
            'distance': '0.8 km',
            'address': '78 Hai Bà Trưng, Q.1',
            'isOpen': true,
            'deliveryTime': '20-25 phút',
          },
          {
            'id': 3,
            'name': 'Bánh Mì Huỳnh Hoa',
            'image': 'https://images.unsplash.com/photo-1600628421055-4d30de868b8f?w=400',
            'rating': 4.9,
            'distance': '1.2 km',
            'address': '26 Lê Thị Riêng, Q.1',
            'isOpen': false,
            'deliveryTime': '25-30 phút',
          },
          {
            'id': 4,
            'name': 'Bún Bò Huế Đông Ba',
            'image': 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=400',
            'rating': 4.6,
            'distance': '1.5 km',
            'address': '99 Võ Văn Tần, Q.3',
            'isOpen': true,
            'deliveryTime': '20-30 phút',
          },
        ];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Lỗi: $e'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Gần bạn',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppColors.textPrimary),
            onPressed: _showFilterDialog,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : RefreshIndicator(
              onRefresh: _loadNearbyData,
              child: CustomScrollView(
                slivers: [
                  // Location Card
                  SliverToBoxAdapter(child: _buildLocationCard()),
                  // Radius Selector
                  SliverToBoxAdapter(child: _buildRadiusSelector()),
                  // Nearby Shops Section
                  SliverToBoxAdapter(
                    child: _buildSectionTitle('Quán gần đây', _nearbyShops.length),
                  ),
                  SliverToBoxAdapter(child: _buildShopsList()),
                  // Nearby Foods Section
                  SliverToBoxAdapter(
                    child: _buildSectionTitle('Món ăn gần bạn', _nearbyFoods.length),
                  ),
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverGrid(
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        childAspectRatio: 0.75,
                        crossAxisSpacing: 15,
                        mainAxisSpacing: 15,
                      ),
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final food = _nearbyFoods[index];
                          return FoodItemCard(
                            name: food['foodName'] ?? 'Món ăn',
                            shopName: food['shopName'] ?? 'Quán ăn',
                            price: (food['price'] ?? 0).toDouble(),
                            rating: (food['rating'] ?? 4.5).toDouble(),
                            imageUrl: food['image'],
                          );
                        },
                        childCount: _nearbyFoods.length,
                      ),
                    ),
                  ),
                  const SliverToBoxAdapter(child: SizedBox(height: 100)),
                ],
              ),
            ),
    );
  }

  Widget _buildLocationCard() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppColors.primaryColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Vị trí của bạn',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.subColor,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _currentLocation,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(Icons.my_location, color: AppColors.primaryColor),
            onPressed: () {
              // TODO: Get current location
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Đang cập nhật vị trí...')),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadiusSelector() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Bán kính tìm kiếm',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimary,
                ),
              ),
              Text(
                '${_selectedRadius.toStringAsFixed(1)} km',
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: AppColors.primaryColor,
              inactiveTrackColor: AppColors.primaryColor.withOpacity(0.2),
              thumbColor: AppColors.primaryColor,
              overlayColor: AppColors.primaryColor.withOpacity(0.2),
            ),
            child: Slider(
              value: _selectedRadius,
              min: 1,
              max: 20,
              divisions: 19,
              onChanged: (value) {
                setState(() => _selectedRadius = value);
              },
              onChangeEnd: (value) {
                // Reload data with new radius
                _loadNearbyData();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, int count) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count kết quả',
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.primaryColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildShopsList() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: _nearbyShops.length,
        itemBuilder: (context, index) {
          final shop = _nearbyShops[index];
          return _buildShopCard(shop);
        },
      ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Image
          Stack(
            children: [
              ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: Image.network(
                  shop['image'],
                  height: 100,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    height: 100,
                    color: AppColors.background,
                    child: const Icon(Icons.restaurant, size: 40, color: AppColors.subColor),
                  ),
                ),
              ),
              // Status Badge
              Positioned(
                top: 8,
                left: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: shop['isOpen'] ? AppColors.success : AppColors.error,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Text(
                    shop['isOpen'] ? 'Đang mở' : 'Đã đóng',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              // Distance Badge
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.location_on, color: Colors.white, size: 12),
                      const SizedBox(width: 4),
                      Text(
                        shop['distance'],
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          // Info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  shop['name'],
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  shop['address'],
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppColors.subColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.star, color: AppColors.accentColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      '${shop['rating']}',
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    const SizedBox(width: 12),
                    const Icon(Icons.access_time, color: AppColors.subColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      shop['deliveryTime'],
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subColor,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showFilterDialog() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Bộ lọc',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildFilterOption('Đang mở cửa', Icons.access_time),
            _buildFilterOption('Đánh giá cao', Icons.star),
            _buildFilterOption('Giao hàng nhanh', Icons.delivery_dining),
            _buildFilterOption('Khuyến mãi', Icons.local_offer),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.pop(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text('Áp dụng', style: TextStyle(color: Colors.white)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilterOption(String title, IconData icon) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primaryColor),
      title: Text(title),
      trailing: Switch(
        value: false,
        onChanged: (value) {},
        activeColor: AppColors.primaryColor,
      ),
    );
  }
}
