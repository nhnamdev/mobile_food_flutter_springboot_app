import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../widgets/food_item_card.dart';
import '../../services/local_favorites_manager.dart';
import '../../services/food_item_service.dart';
import '../food_detail/food_detail_screen.dart';

class FavoritesScreen extends StatefulWidget {
  const FavoritesScreen({super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _favorites = LocalFavoritesManager.instance;
  
  List<Map<String, dynamic>> _favoriteFoods = [];
  List<Map<String, dynamic>> _favoriteShops = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _loadFavorites();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadFavorites() async {
    setState(() => _isLoading = true);
    
    try {
      await _favorites.init();
      
      // Load chi tiết các món ăn yêu thích từ API
      final foodIds = _favorites.foodFavorites;
      final List<Map<String, dynamic>> foods = [];
      
      for (final foodId in foodIds) {
        try {
          final response = await FoodItemService.getFoodItemById(foodId);
          if (response['success'] == true && response['data'] != null) {
            foods.add(Map<String, dynamic>.from(response['data']));
          }
        } catch (e) {
          debugPrint('Error loading food $foodId: $e');
        }
      }
      
      setState(() {
        _favoriteFoods = foods;
        _favoriteShops = []; // TODO: Load shop details from API
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

  Future<void> _removeFavorite(String type, int id) async {
    try {
      if (type == 'food') {
        await _favorites.removeFoodFavorite(id);
      } else {
        await _favorites.toggleShopFavorite(id);
      }
      
      await _loadFavorites();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã xóa khỏi yêu thích'),
            backgroundColor: AppColors.success,
          ),
        );
      }
    } catch (e) {
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
          'Yêu thích',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.subColor,
          indicatorColor: AppColors.primaryColor,
          indicatorWeight: 3,
          tabs: [
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.fastfood, size: 18),
                  const SizedBox(width: 8),
                  Text('Món ăn (${_favoriteFoods.length})'),
                ],
              ),
            ),
            Tab(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.store, size: 18),
                  const SizedBox(width: 8),
                  Text('Quán (${_favoriteShops.length})'),
                ],
              ),
            ),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildFoodsList(),
                _buildShopsList(),
              ],
            ),
    );
  }

  Widget _buildFoodsList() {
    if (_favoriteFoods.isEmpty) {
      return _buildEmptyState(
        icon: Icons.favorite_border,
        title: 'Chưa có món yêu thích',
        subtitle: 'Hãy khám phá và thêm món ăn yêu thích của bạn',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: GridView.builder(
        padding: const EdgeInsets.all(20),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          childAspectRatio: 0.75,
          crossAxisSpacing: 15,
          mainAxisSpacing: 15,
        ),
        itemCount: _favoriteFoods.length,
        itemBuilder: (context, index) {
          final food = _favoriteFoods[index];
          final foodId = food['id'] as int?;
          
          return Dismissible(
            key: Key('food_${food['id']}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              if (foodId != null) _removeFavorite('food', foodId);
            },
            child: FoodItemCard(
              id: foodId,
              name: food['foodName'] ?? food['name'] ?? 'Món ăn',
              shopName: food['shop']?['shopName'] ?? food['shopName'] ?? 'Quán ăn',
              shopId: food['shop']?['id'] ?? food['shopId'] ?? 0,
              price: (food['price'] ?? 0).toDouble(),
              rating: (food['averageRating'] ?? food['rating'] ?? 4.5).toDouble(),
              imageUrl: food['image'] ?? food['imageUrl'],
              showFavorite: false,
              onTap: () {
                if (foodId != null) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => FoodDetailScreen(
                        foodId: foodId,
                        initialData: food,
                      ),
                    ),
                  ).then((_) => _loadFavorites());
                }
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildShopsList() {
    if (_favoriteShops.isEmpty) {
      return _buildEmptyState(
        icon: Icons.store_outlined,
        title: 'Chưa có quán yêu thích',
        subtitle: 'Hãy khám phá và thêm quán yêu thích của bạn',
      );
    }

    return RefreshIndicator(
      onRefresh: _loadFavorites,
      child: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: _favoriteShops.length,
        itemBuilder: (context, index) {
          final shop = _favoriteShops[index];
          return Dismissible(
            key: Key('shop_${shop['id']}'),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: AppColors.error,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) => _removeFavorite('shop', shop['id']),
            child: _buildShopCard(shop),
          );
        },
      ),
    );
  }

  Widget _buildShopCard(Map<String, dynamic> shop) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
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
          // Image
          ClipRRect(
            borderRadius: const BorderRadius.horizontal(left: Radius.circular(16)),
            child: Image.network(
              shop['logo'] ?? shop['image'] ?? '',
              width: 100,
              height: 100,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Container(
                width: 100,
                height: 100,
                color: AppColors.background,
                child: const Icon(Icons.store, size: 40, color: AppColors.subColor),
              ),
            ),
          ),
          // Info
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    shop['shopName'] ?? shop['name'] ?? 'Quán',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    shop['address'] ?? '',
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppColors.subColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accentColor, size: 14),
                      const SizedBox(width: 4),
                      Text(
                        '${shop['rating'] ?? 4.5}',
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          shop['shopStatus'] ?? 'active',
                          style: const TextStyle(
                            fontSize: 10,
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          // Favorite Button
          IconButton(
            icon: const Icon(Icons.favorite, color: AppColors.primaryColor),
            onPressed: () => _removeFavorite('shop', shop['id']),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String subtitle,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: AppColors.primaryColor.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, size: 60, color: AppColors.primaryColor),
          ),
          const SizedBox(height: 24),
          Text(
            title,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.subColor,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Khám phá ngay',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
