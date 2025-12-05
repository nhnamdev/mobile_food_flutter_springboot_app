import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/food_item_service.dart';
import '../../services/local_cart_manager.dart';
import '../../services/local_favorites_manager.dart';

class FoodDetailScreen extends StatefulWidget {
  final int foodId;
  final Map<String, dynamic>? initialData;

  const FoodDetailScreen({
    super.key,
    required this.foodId,
    this.initialData,
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  Map<String, dynamic>? _foodData;
  bool _isLoading = true;
  bool _isFavorite = false;
  bool _isFavoriteLoading = false;
  int _quantity = 1;
  final _cart = LocalCartManager.instance;
  final _favorites = LocalFavoritesManager.instance;

  @override
  void initState() {
    super.initState();
    if (widget.initialData != null) {
      _foodData = widget.initialData;
      _isLoading = false;
    }
    _loadFoodDetail();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    await _favorites.init();
    if (mounted) {
      setState(() {
        _isFavorite = _favorites.isFoodFavorite(widget.foodId);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    setState(() => _isFavoriteLoading = true);
    
    final newStatus = await _favorites.toggleFoodFavorite(widget.foodId);
    
    if (mounted) {
      setState(() {
        _isFavorite = newStatus;
        _isFavoriteLoading = false;
      });
      
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(
                newStatus ? Icons.favorite : Icons.favorite_border,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(newStatus ? 'Đã thêm vào yêu thích' : 'Đã xóa khỏi yêu thích'),
            ],
          ),
          backgroundColor: newStatus ? AppColors.primaryColor : AppColors.subColor,
          duration: const Duration(seconds: 2),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  Future<void> _loadFoodDetail() async {
    try {
      final response = await FoodItemService.getFoodItemById(widget.foodId);
      if (response['success'] == true && response['data'] != null) {
        setState(() {
          _foodData = response['data'];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  String _formatPrice(double price) {
    return '${price.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}đ';
  }

  String get _name => _foodData?['foodName'] ?? _foodData?['name'] ?? 'Món ăn';
  String get _description => _foodData?['foodDescription'] ?? _foodData?['description'] ?? '';
  String? get _image => _foodData?['image'] ?? _foodData?['imageUrl'];
  double get _price => (_foodData?['price'] ?? 0).toDouble();
  double? get _discountPrice => _foodData?['discountPrice']?.toDouble();
  double get _rating => (_foodData?['averageRating'] ?? _foodData?['rating'] ?? 4.5).toDouble();
  int get _reviewCount => _foodData?['reviewCount'] ?? 25;
  String get _shopName => _foodData?['shopName'] ?? _foodData?['shop']?['shopName'] ?? 'Cửa hàng';
  int get _shopId => _foodData?['shopId'] ?? _foodData?['shop']?['id'] ?? 0;
  String get _categoryName => _foodData?['categoryName'] ?? _foodData?['category']?['name'] ?? '';

  bool get _hasDiscount => _discountPrice != null && _discountPrice! < _price;
  double get _finalPrice => _discountPrice ?? _price;
  double get _discountPercent => _hasDiscount ? ((_price - _discountPrice!) / _price * 100) : 0;

  void _addToCart() {
    _cart.addFromFoodData(
      id: widget.foodId,
      name: _name,
      shopName: _shopName,
      shopId: _shopId,
      price: _price,
      discountPrice: _discountPrice,
      imageUrl: _image,
      quantity: _quantity,
    );

    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Đã thêm $_quantity "$_name" vào giỏ hàng'),
            ),
          ],
        ),
        backgroundColor: AppColors.success,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        action: SnackBarAction(
          label: 'Xem giỏ',
          textColor: Colors.white,
          onPressed: () {
            Navigator.pushNamed(context, '/cart');
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _foodData == null
              ? _buildErrorState()
              : _buildContent(),
      bottomNavigationBar: _foodData != null ? _buildBottomBar() : null,
    );
  }

  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline, size: 60, color: AppColors.subColor),
          const SizedBox(height: 16),
          const Text(
            'Không tìm thấy món ăn',
            style: TextStyle(fontSize: 16, color: AppColors.subColor),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pop(context),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryColor),
            child: const Text('Quay lại', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    return CustomScrollView(
      slivers: [
        // App Bar with Image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          backgroundColor: AppColors.white,
          leading: GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: AppColors.textPrimary, size: 18),
            ),
          ),
          actions: [
            GestureDetector(
              onTap: _isFavoriteLoading ? null : _toggleFavorite,
              child: Container(
                margin: const EdgeInsets.all(8),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: _isFavoriteLoading
                    ? const SizedBox(
                        width: 22,
                        height: 22,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.primaryColor),
                      )
                    : Icon(
                        _isFavorite ? Icons.favorite : Icons.favorite_border,
                        color: _isFavorite ? AppColors.primaryColor : AppColors.textPrimary,
                        size: 22,
                ),
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            background: Stack(
              fit: StackFit.expand,
              children: [
                _image != null
                    ? Image.network(
                        _image!,
                        fit: BoxFit.cover,
                        errorBuilder: (_, __, ___) => _buildPlaceholderImage(),
                      )
                    : _buildPlaceholderImage(),
                // Gradient overlay
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Container(
                    height: 100,
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomCenter,
                        end: Alignment.topCenter,
                        colors: [
                          Colors.black.withOpacity(0.5),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
                // Discount badge
                if (_hasDiscount)
                  Positioned(
                    top: 100,
                    left: 16,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: AppColors.error,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '-${_discountPercent.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),

        // Content
        SliverToBoxAdapter(
          child: Container(
            decoration: const BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header info
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Category
                      if (_categoryName.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppColors.primaryColor.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(15),
                          ),
                          child: Text(
                            _categoryName,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.primaryColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      const SizedBox(height: 12),
                      
                      // Name
                      Text(
                        _name,
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Shop name
                      GestureDetector(
                        onTap: () {
                          // TODO: Navigate to shop
                        },
                        child: Row(
                          children: [
                            const Icon(Icons.store, size: 18, color: AppColors.subColor),
                            const SizedBox(width: 6),
                            Text(
                              _shopName,
                              style: const TextStyle(
                                fontSize: 14,
                                color: AppColors.subColor,
                              ),
                            ),
                            const Icon(Icons.chevron_right, size: 18, color: AppColors.subColor),
                          ],
                        ),
                      ),
                      const SizedBox(height: 16),

                      // Rating & Reviews
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            decoration: BoxDecoration(
                              color: AppColors.accentColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Row(
                              children: [
                                const Icon(Icons.star, color: AppColors.accentColor, size: 18),
                                const SizedBox(width: 4),
                                Text(
                                  _rating.toStringAsFixed(1),
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.textPrimary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 12),
                          Text(
                            '$_reviewCount đánh giá',
                            style: const TextStyle(
                              fontSize: 14,
                              color: AppColors.subColor,
                            ),
                          ),
                          const SizedBox(width: 20),
                          const Icon(Icons.access_time, size: 16, color: AppColors.subColor),
                          const SizedBox(width: 4),
                          const Text(
                            '15-20 phút',
                            style: TextStyle(
                              fontSize: 14,
                              color: AppColors.subColor,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),

                      // Price
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            _formatPrice(_finalPrice),
                            style: const TextStyle(
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                          if (_hasDiscount) ...[
                            const SizedBox(width: 12),
                            Text(
                              _formatPrice(_price),
                              style: const TextStyle(
                                fontSize: 18,
                                color: AppColors.subColor,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 8,
                  color: AppColors.background,
                ),

                // Description
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Mô tả',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        _description.isNotEmpty 
                            ? _description 
                            : 'Món ăn ngon, được chế biến từ nguyên liệu tươi ngon, đảm bảo vệ sinh an toàn thực phẩm.',
                        style: const TextStyle(
                          fontSize: 14,
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 8,
                  color: AppColors.background,
                ),

                // Quantity selector
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Số lượng',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          _buildQuantityButton(
                            icon: Icons.remove,
                            onTap: () {
                              if (_quantity > 1) {
                                setState(() => _quantity--);
                              }
                            },
                          ),
                          Container(
                            width: 60,
                            alignment: Alignment.center,
                            child: Text(
                              '$_quantity',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppColors.textPrimary,
                              ),
                            ),
                          ),
                          _buildQuantityButton(
                            icon: Icons.add,
                            onTap: () => setState(() => _quantity++),
                            isPrimary: true,
                          ),
                          const Spacer(),
                          Text(
                            _formatPrice(_finalPrice * _quantity),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                // Divider
                Container(
                  height: 8,
                  color: AppColors.background,
                ),

                // Reviews section
                Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text(
                            'Đánh giá',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              // TODO: Show all reviews
                            },
                            child: const Text(
                              'Xem tất cả',
                              style: TextStyle(color: AppColors.primaryColor),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      // Sample reviews
                      _buildReviewItem(
                        name: 'Nguyễn Văn A',
                        rating: 5,
                        comment: 'Món ăn rất ngon, giao hàng nhanh!',
                        date: '2 ngày trước',
                      ),
                      _buildReviewItem(
                        name: 'Trần Thị B',
                        rating: 4,
                        comment: 'Đồ ăn ngon, đóng gói cẩn thận.',
                        date: '1 tuần trước',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 100),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      color: AppColors.background,
      child: const Center(
        child: Icon(
          Icons.restaurant,
          size: 80,
          color: AppColors.subColor,
        ),
      ),
    );
  }

  Widget _buildQuantityButton({
    required IconData icon,
    required VoidCallback onTap,
    bool isPrimary = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 45,
        height: 45,
        decoration: BoxDecoration(
          color: isPrimary ? AppColors.primaryColor : AppColors.background,
          borderRadius: BorderRadius.circular(12),
          border: isPrimary ? null : Border.all(color: AppColors.inputBorder),
        ),
        child: Icon(
          icon,
          size: 22,
          color: isPrimary ? Colors.white : AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildReviewItem({
    required String name,
    required int rating,
    required String comment,
    required String date,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: AppColors.primaryColor.withOpacity(0.1),
                child: Text(
                  name[0],
                  style: const TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        color: AppColors.textPrimary,
                      ),
                    ),
                    Row(
                      children: [
                        ...List.generate(5, (index) => Icon(
                          index < rating ? Icons.star : Icons.star_border,
                          size: 14,
                          color: AppColors.accentColor,
                        )),
                        const SizedBox(width: 8),
                        Text(
                          date,
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
          const SizedBox(height: 10),
          Text(
            comment,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: const Offset(0, -5),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(25)),
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Cart button
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, '/cart'),
              child: Container(
                width: 55,
                height: 55,
                decoration: BoxDecoration(
                  color: AppColors.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    const Icon(
                      Icons.shopping_cart_outlined,
                      color: AppColors.primaryColor,
                      size: 26,
                    ),
                    if (_cart.itemCount > 0)
                      Positioned(
                        top: 8,
                        right: 8,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: AppColors.primaryColor,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            _cart.itemCount > 9 ? '9+' : '${_cart.itemCount}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
            const SizedBox(width: 15),
            // Add to cart button
            Expanded(
              child: ElevatedButton(
                onPressed: _addToCart,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.primaryColor,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  elevation: 0,
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.add_shopping_cart, color: Colors.white),
                    const SizedBox(width: 10),
                    Text(
                      'Thêm - ${_formatPrice(_finalPrice * _quantity)}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
