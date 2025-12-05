import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/app_theme.dart';
import '../../widgets/category_chip.dart';
import '../../widgets/food_item_card.dart';
import '../../services/category_service.dart';
import '../../services/food_item_service.dart';
import '../../services/user_session.dart';
import '../../services/local_cart_manager.dart';
import '../../services/local_favorites_manager.dart';
import '../auth/sign_in_screen.dart';
import '../food_detail/food_detail_screen.dart';

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
  List<dynamic> _allFoodItems = []; // All food items
  List<dynamic> _foodItems = []; // Filtered food items
  bool _isLoading = true;
  bool _isFilteringCategory = false;
  final _cart = LocalCartManager.instance;
  final _favorites = LocalFavoritesManager.instance;
  
  // Address
  Map<String, dynamic>? _selectedAddress;
  List<Map<String, dynamic>> _addresses = [];
  
  // Notifications count (demo)
  int _notificationCount = 0;
  
  // Scaffold key for drawer
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadData();
    _loadAddresses();
    _loadNotificationCount();
    _cart.addListener(_onCartChanged);
  }

  @override
  void dispose() {
    _cart.removeListener(_onCartChanged);
    super.dispose();
  }

  void _onCartChanged() {
    if (mounted) setState(() {});
  }

  Future<void> _loadNotificationCount() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notificationsJson = prefs.getString('notifications');
      if (notificationsJson != null) {
        final List<dynamic> notifications = jsonDecode(notificationsJson);
        _notificationCount = notifications.where((n) => n['isRead'] == false).length;
      } else {
        // Demo: 3 thông báo chưa đọc
        _notificationCount = 3;
      }
      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Error loading notifications: $e');
    }
  }

  Future<void> _loadAddresses() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString('delivery_addresses');
      if (addressesJson != null) {
        final List<dynamic> decoded = jsonDecode(addressesJson);
        _addresses = decoded.cast<Map<String, dynamic>>();
        
        // Tìm địa chỉ mặc định hoặc lấy địa chỉ đầu tiên
        if (_addresses.isNotEmpty) {
          _selectedAddress = _addresses.firstWhere(
            (addr) => addr['isDefault'] == true,
            orElse: () => _addresses.first,
          );
        }
        if (mounted) setState(() {});
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final categoriesResponse = await CategoryService.getAllCategories();
      final foodItemsResponse = await FoodItemService.getAllFoodItems();
      
      setState(() {
        _categories = categoriesResponse['data'] ?? [];
        _allFoodItems = foodItemsResponse['data'] ?? [];
        _foodItems = _allFoodItems;
        _selectedCategoryIndex = 0; // Reset to "Tất cả"
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

  void _showAddressSelector() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.6,
        ),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Chọn địa chỉ giao hàng',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            
            // Address list
            if (_addresses.isEmpty)
              Padding(
                padding: const EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(Icons.location_off_outlined, size: 60, color: Colors.grey.shade300),
                    const SizedBox(height: 16),
                    Text(
                      'Chưa có địa chỉ nào',
                      style: TextStyle(color: Colors.grey.shade600),
                    ),
                  ],
                ),
              )
            else
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: _addresses.length,
                  itemBuilder: (context, index) {
                    final address = _addresses[index];
                    final isSelected = _selectedAddress?['id'] == address['id'];
                    return _buildAddressItem(address, isSelected);
                  },
                ),
              ),
            
            // Add new address button
            Padding(
              padding: const EdgeInsets.all(16),
              child: SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pushNamed(context, '/addresses').then((_) {
                      _loadAddresses();
                    });
                  },
                  icon: const Icon(Icons.add),
                  label: const Text('Thêm địa chỉ mới'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: AppColors.primaryColor,
                    side: const BorderSide(color: AppColors.primaryColor),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAddressItem(Map<String, dynamic> address, bool isSelected) {
    final type = address['type'] ?? 'home';
    final typeIcon = type == 'home' 
        ? Icons.home_outlined 
        : type == 'office' 
            ? Icons.business_outlined 
            : Icons.location_on_outlined;
    
    return InkWell(
      onTap: () {
        setState(() => _selectedAddress = address);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Đã chọn: ${address['address']}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 1),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade200,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: isSelected 
                    ? AppColors.primaryColor.withOpacity(0.2) 
                    : Colors.grey.shade100,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                typeIcon, 
                color: isSelected ? AppColors.primaryColor : Colors.grey,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Text(
                        address['name'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (address['isDefault'] == true) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Text(
                            'Mặc định',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    address['phone'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    address['address'] ?? '',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(Icons.check_circle, color: AppColors.primaryColor),
          ],
        ),
      ),
    );
  }

  Future<void> _filterByCategory(int index) async {
    if (index == _selectedCategoryIndex) return;
    
    setState(() {
      _selectedCategoryIndex = index;
      _isFilteringCategory = true;
    });

    try {
      if (index == 0) {
        // "Tất cả" - show all items
        setState(() {
          _foodItems = _allFoodItems;
          _isFilteringCategory = false;
        });
      } else {
        // Filter by specific category
        final categoryId = _categories[index - 1]['id'];
        final response = await FoodItemService.getFoodItemsByCategory(categoryId);
        setState(() {
          _foodItems = response['data'] ?? [];
          _isFilteringCategory = false;
        });
      }
    } catch (e) {
      setState(() {
        _isFilteringCategory = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi lọc danh mục: ${e.toString()}'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      drawer: _buildDrawer(),
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
                    // Section Title - Dynamic based on category
                    SliverToBoxAdapter(
                      child: _buildSectionTitle(
                        _selectedCategoryIndex == 0 
                            ? 'Đề xuất cho bạn' 
                            : _categories.isNotEmpty && _selectedCategoryIndex - 1 < _categories.length
                                ? _categories[_selectedCategoryIndex - 1]['categoryName'] ?? 'Món ăn'
                                : 'Món ăn',
                        onSeeAll: () {},
                      ),
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
          Expanded(
            child: Row(
              children: [
                GestureDetector(
                  onTap: () => _scaffoldKey.currentState?.openDrawer(),
                  child: Container(
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
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: GestureDetector(
                    onTap: _showAddressSelector,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: const [
                            Text(
                              'Giao đến',
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
                        Text(
                          _selectedAddress != null
                              ? _selectedAddress!['address'] ?? 'Chọn địa chỉ'
                              : 'Thêm địa chỉ giao hàng',
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: _selectedAddress != null 
                                ? AppColors.primaryColor 
                                : AppColors.subColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
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
    // Build category list with "Tất cả" at the beginning
    final displayCategories = _categories.isEmpty
        ? ['Tất cả', 'Fast Food', 'Pizza', 'Burger', 'Drinks', 'Dessert']
        : ['Tất cả', ..._categories.map((c) => c['categoryName'] ?? c['name'] ?? '')];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        SizedBox(
          height: 50,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 20),
            itemCount: displayCategories.length,
            itemBuilder: (context, index) {
              return CategoryChip(
                name: displayCategories[index].toString(),
                isSelected: index == _selectedCategoryIndex,
                onTap: () => _filterByCategory(index),
              );
            },
          ),
        ),
        // Loading indicator when filtering
        if (_isFilteringCategory)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: AppColors.primaryColor,
                ),
              ),
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

    final displayItems = _foodItems.isEmpty && _allFoodItems.isEmpty ? sampleFoods : _foodItems;
    
    // Show message when no items in selected category
    if (displayItems.isEmpty && !_isFilteringCategory) {
      return Container(
        height: 150,
        margin: const EdgeInsets.symmetric(horizontal: 20),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
            ),
          ],
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.restaurant_menu,
                size: 40,
                color: AppColors.subColor.withOpacity(0.5),
              ),
              const SizedBox(height: 10),
              const Text(
                'Không có món ăn trong danh mục này',
                style: TextStyle(
                  color: AppColors.subColor,
                  fontSize: 14,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return SizedBox(
      height: 220,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        itemCount: displayItems.length,
        itemBuilder: (context, index) {
          final item = displayItems[index];
          final itemId = item['id'];
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: FoodItemCard(
              id: itemId,
              name: item['foodName'] ?? item['name'] ?? '',
              shopName: item['shopName'] ?? item['shop']?['shopName'] ?? 'Shop',
              shopId: item['shopId'] ?? item['shop']?['id'] ?? 0,
              price: (item['price'] ?? 0).toDouble(),
              discountPrice: item['discountPrice']?.toDouble(),
              rating: (item['averageRating'] ?? item['rating'] ?? 4.5).toDouble(),
              reviewCount: item['reviewCount'] ?? 25,
              imageUrl: item['image'] ?? item['imageUrl'],
              isVerified: true,
              onTap: () {
                if (itemId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailScreen(
                        foodId: itemId,
                        initialData: item,
                      ),
                    ),
                  );
                }
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

    final displayItems = _foodItems.isEmpty && _allFoodItems.isEmpty ? sampleFoods : _foodItems;
    
    // Show empty state when filtering shows no results
    if (displayItems.isEmpty) {
      return const SizedBox.shrink();
    }

    // Sort by rating or sales based on selected tab
    final sortedItems = List<dynamic>.from(displayItems);
    if (_selectedTabIndex == 1) {
      // Sort by rating (Đánh giá)
      sortedItems.sort((a, b) {
        final ratingA = (a['rating'] ?? a['averageRating'] ?? 0).toDouble();
        final ratingB = (b['rating'] ?? b['averageRating'] ?? 0).toDouble();
        return ratingB.compareTo(ratingA);
      });
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: sortedItems.take(5).map((item) {
          final itemId = item['id'];
          return FoodItemListTile(
            id: itemId,
            name: item['foodName'] ?? item['name'] ?? '',
            shopName: item['shopName'] ?? item['shop']?['shopName'] ?? 'Shop',
            shopId: item['shopId'] ?? item['shop']?['id'] ?? 0,
            price: (item['price'] ?? 0).toDouble(),
            discountPrice: item['discountPrice']?.toDouble(),
            rating: (item['averageRating'] ?? item['rating'] ?? 4.5).toDouble(),
            distance: item['distance'],
            deliveryTime: item['time'] ?? item['deliveryTime'],
            discount: item['discount'],
            imageUrl: item['image'] ?? item['imageUrl'],
            onTap: () {
              if (itemId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => FoodDetailScreen(
                      foodId: itemId,
                      initialData: item,
                    ),
                  ),
                );
              }
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
          _buildNavItem(Icons.favorite, 'Yêu thích', 3, badgeCount: _favorites.foodFavoritesCount),
          _buildNavItem(Icons.notifications, 'Thông báo', 4, badgeCount: _notificationCount),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index, {int badgeCount = 0}) {
    final isSelected = _selectedBottomNavIndex == index;
    return GestureDetector(
      onTap: () {
        setState(() => _selectedBottomNavIndex = index);
        // Navigate to corresponding screen
        switch (index) {
          case 0:
            // Home - already here
            break;
          case 1:
            Navigator.pushNamed(context, '/nearby');
            break;
          case 3:
            Navigator.pushNamed(context, '/favorites');
            break;
          case 4:
            Navigator.pushNamed(context, '/notifications');
            break;
        }
      },
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
    final cartCount = _cart.itemCount;
    return GestureDetector(
      onTap: () {
        Navigator.pushNamed(context, '/cart');
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
            if (cartCount > 0)
              Positioned(
                right: 10,
                top: 10,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: AppColors.accentColor,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    cartCount > 9 ? '9+' : '$cartCount',
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
      ),
    );
  }
}
