import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/food_item_card.dart';
import '../../services/category_service.dart';
import '../../services/food_item_service.dart';
import '../../services/user_session.dart';
import '../auth/sign_in_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedCategoryIndex = 0;
  int _selectedBottomNavIndex = 0;
  int _selectedTabIndex = 0; // 0 = Bán chạy, 1 = Đánh giá
  
  List<dynamic> _categories = [];
  List<dynamic> _foodItems = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categoriesResponse = await CategoryService.getAllCategories();
      final foodItemsResponse = await FoodItemService.getAllFoodItems();
      
      setState(() {
        _categories = categoriesResponse['data'] ?? [];
        _foodItems = foodItemsResponse['data'] ?? [];
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
            : RefreshIndicator(
                onRefresh: _loadData,
                color: AppColors.primaryColor,
                child: CustomScrollView(
                  slivers: [
                    // Header
                    SliverToBoxAdapter(
                      child: _buildHeader(),
                    ),
                    // Search Bar
                    SliverToBoxAdapter(
                      child: _buildSearchBar(),
                    ),
                    // Categories
                    SliverToBoxAdapter(
                      child: _buildCategories(),
                    ),
                    // Banner
                    SliverToBoxAdapter(
                      child: _buildBanner(),
                    ),
                    // Section Title - Đề xuất cho bạn
                    SliverToBoxAdapter(
                      child: _buildSectionTitle('Đề xuất cho bạn', onSeeAll: () {}),
                    ),
                    // Food Grid
                    SliverToBoxAdapter(
                      child: _buildFoodGrid(),
                    ),
                    // Tabs - Bán chạy / Đánh giá
                    SliverToBoxAdapter(
                      child: _buildTabs(),
                    ),
                    // Food List
                    SliverToBoxAdapter(
                      child: _buildFoodList(),
                    ),
                    // Bottom Padding
                    const SliverToBoxAdapter(
                      child: SizedBox(height: 100),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: _buildBottomNavBar(),
    );
  }

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Location
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.menu,
                  color: AppColors.textPrimary,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Text(
                        'Deliver to',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.subColor,
                        ),
                      ),
                      Icon(
                        Icons.keyboard_arrow_down,
                        color: AppColors.subColor,
                        size: 16,
                      ),
                    ],
                  ),
                  const Text(
                    '4102 Pretty View Lane',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ],
              ),
            ],
          ),
          // Avatar
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(
                context,
                '/profile',
                arguments: UserSession.instance.toProfileArgs(),
              );
            },
            child: Stack(
              children: [
                Container(
                  width: 45,
                  height: 45,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.primaryColor.withOpacity(0.1),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: AppColors.primaryColor,
                  ),
                ),
                Positioned(
                  right: 0,
                  top: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: AppColors.white, width: 2),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        height: 55,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD3D1D8).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: TextField(
          decoration: InputDecoration(
            hintText: 'Tìm món ăn',
            hintStyle: const TextStyle(
              color: AppColors.subColor,
              fontSize: 14,
            ),
            prefixIcon: const Icon(Icons.search, color: AppColors.subColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          ),
        ),
      ),
    );
  }

  Widget _buildCategories() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: _categories.isEmpty ? 5 : _categories.length,
            itemBuilder: (context, index) {
              if (_categories.isEmpty) {
                // Show sample categories when API is not available
                final sampleCategories = ['Fast Food', 'Pizza', 'Burger', 'Drinks', 'Dessert'];
                return CategoryChip(
                  name: sampleCategories[index],
                  isSelected: index == _selectedCategoryIndex,
                  onTap: () {
                    setState(() => _selectedCategoryIndex = index);
                  },
                );
              }
              final category = _categories[index];
              return CategoryChip(
                name: category['name'] ?? '',
                iconUrl: category['imageUrl'],
                isSelected: index == _selectedCategoryIndex,
                onTap: () {
                  setState(() => _selectedCategoryIndex = index);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildBanner() {
    return Container(
      margin: const EdgeInsets.all(20),
      height: 140,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primaryColor, Color(0xFFFF9A6C)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Stack(
        children: [
          Positioned(
            right: 20,
            top: 20,
            bottom: 20,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.2),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Text(
                  'Giảm 30%',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.white,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Cho đơn hàng đầu tiên',
                  style: TextStyle(
                    fontSize: 14,
                    color: AppColors.white,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, {VoidCallback? onSeeAll}) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
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
          if (onSeeAll != null)
            TextButton(
              onPressed: onSeeAll,
              child: const Text(
                'Xem tất cả',
                style: TextStyle(
                  fontSize: 14,
                  color: AppColors.primaryColor,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildFoodGrid() {
    // Sample data when API is not available
    final sampleFoods = [
      {'name': 'Burger King', 'shop': 'Fast Food', 'price': 45000.0, 'rating': 4.5},
      {'name': 'Pizza Margherita', 'shop': 'Pizza House', 'price': 89000.0, 'rating': 4.8},
      {'name': 'Gà Rán KFC', 'shop': 'KFC', 'price': 55000.0, 'rating': 4.3},
      {'name': 'Cơm Chiên', 'shop': 'Quán Việt', 'price': 35000.0, 'rating': 4.6},
    ];

    final displayItems = _foodItems.isEmpty ? sampleFoods : _foodItems;

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final item = displayItems[index];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FoodItemCard(
              name: item['name'] ?? '',
              shopName: item['shop'] ?? item['shopName'] ?? 'Shop',
              price: (item['price'] ?? 0).toDouble(),
              rating: (item['rating'] ?? item['averageRating'] ?? 4.5).toDouble(),
              reviewCount: item['reviewCount'] ?? 25,
              imageUrl: item['imageUrl'],
              isVerified: true,
              onTap: () {
                // TODO: Navigate to food detail
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildTabs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        children: [
          _buildTabButton('Bán chạy', 0),
          const SizedBox(width: 15),
          _buildTabButton('Đánh giá', 1),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index) {
    final isSelected = _selectedTabIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedTabIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : AppColors.inputBorder,
          ),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isSelected ? AppColors.white : AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildFoodList() {
    // Sample data when API is not available
    final sampleFoods = [
      {'name': 'Phở Bò Tái Nạm', 'shop': 'Phở 24', 'price': 50000.0, 'rating': 4.7, 'distance': '1.2km', 'time': '15 phút'},
      {'name': 'Bún Chả Hà Nội', 'shop': 'Bún Chả Obama', 'price': 45000.0, 'rating': 4.9, 'distance': '0.8km', 'time': '12 phút', 'discount': '-20%'},
      {'name': 'Bánh Mì Thịt', 'shop': 'Bánh Mì Phượng', 'price': 25000.0, 'rating': 4.6, 'distance': '2.0km', 'time': '20 phút'},
    ];

    final displayItems = _foodItems.isEmpty ? sampleFoods : _foodItems;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: displayItems.take(5).map((item) {
          return FoodItemListTile(
            name: item['name'] ?? '',
            shopName: item['shop'] ?? item['shopName'] ?? 'Shop',
            price: (item['price'] ?? 0).toDouble(),
            rating: (item['rating'] ?? item['averageRating'] ?? 4.5).toDouble(),
            distance: item['distance'],
            deliveryTime: item['time'] ?? item['deliveryTime'],
            discount: item['discount'],
            imageUrl: item['imageUrl'],
            onTap: () {
              // TODO: Navigate to food detail
            },
          );
        }).toList(),
      ),
    );
  }

  Widget _buildBottomNavBar() {
    return Container(
      height: 80,
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildNavItem(Icons.home_filled, 'Trang chủ', 0),
          _buildNavItem(Icons.location_on, 'Gần bạn', 1),
          _buildNavItemCenter(),
          _buildNavItem(Icons.favorite, 'Yêu thích', 3, badgeCount: 2),
          _buildNavItem(Icons.notifications, 'Thông báo', 4, badgeCount: 5),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {int badgeCount = 0}) {
    final isSelected = _selectedBottomNavIndex == index;
    return GestureDetector(
      onTap: () => setState(() => _selectedBottomNavIndex = index),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Stack(
            clipBehavior: Clip.none,
            children: [
              Icon(
                icon,
                color: isSelected ? AppColors.primaryColor : AppColors.subColor,
                size: 28,
              ),
              if (badgeCount > 0)
                Positioned(
                  right: -8,
                  top: -5,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: AppColors.primaryColor,
                      shape: BoxShape.circle,
                    ),
                    child: Text(
                      badgeCount.toString(),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 11,
              color: isSelected ? AppColors.primaryColor : AppColors.subColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavItemCenter() {
    return GestureDetector(
      onTap: () {
        // TODO: Navigate to cart
        setState(() => _selectedBottomNavIndex = 2);
      },
      child: Container(
        width: 60,
        height: 60,
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppColors.primaryColor.withOpacity(0.4),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            const Icon(
              Icons.shopping_cart,
              color: AppColors.white,
              size: 28,
            ),
            Positioned(
              right: 10,
              top: 10,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: const BoxDecoration(
                  color: AppColors.accentColor,
                  shape: BoxShape.circle,
                ),
                child: const Text(
                  '3',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
