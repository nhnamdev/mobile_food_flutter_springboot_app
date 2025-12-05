import 'package:flutter/material.dart';
import '../../config/app_theme.dart';
import '../../services/local_cart_manager.dart';
import '../../services/local_favorites_manager.dart';

class FoodItemCard extends StatefulWidget {
  final int? id;
  final String? imageUrl;
  final String name;
  final String shopName;
  final int shopId;
  final double price;
  final double? discountPrice;
  final double rating;
  final int reviewCount;
  final bool isVerified;
  final VoidCallback? onTap;
  final bool showAddToCart;
  final bool showFavorite;

  const FoodItemCard({
    super.key,
    this.id,
    this.imageUrl,
    required this.name,
    required this.shopName,
    this.shopId = 0,
    required this.price,
    this.discountPrice,
    required this.rating,
    this.reviewCount = 0,
    this.isVerified = false,
    this.onTap,
    this.showAddToCart = true,
    this.showFavorite = true,
  });

  @override
  State<FoodItemCard> createState() => _FoodItemCardState();
}

class _FoodItemCardState extends State<FoodItemCard> {
  bool _isFavorite = false;
  final _favorites = LocalFavoritesManager.instance;

  @override
  void initState() {
    super.initState();
    _loadFavoriteStatus();
  }

  Future<void> _loadFavoriteStatus() async {
    if (widget.id == null) return;
    await _favorites.init();
    if (mounted) {
      setState(() {
        _isFavorite = _favorites.isFoodFavorite(widget.id!);
      });
    }
  }

  Future<void> _toggleFavorite() async {
    if (widget.id == null) return;
    
    final newStatus = await _favorites.toggleFoodFavorite(widget.id!);
    
    if (mounted) {
      setState(() => _isFavorite = newStatus);
      
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

  void _addToCart(BuildContext context) {
    if (widget.id == null) return;
    
    final cart = LocalCartManager.instance;
    cart.addFromFoodData(
      id: widget.id!,
      name: widget.name,
      shopName: widget.shopName,
      shopId: widget.shopId,
      price: widget.price,
      discountPrice: widget.discountPrice,
      imageUrl: widget.imageUrl,
    );
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Đã thêm "${widget.name}" vào giỏ hàng'),
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
    return GestureDetector(
      onTap: widget.onTap,
      child: Container(
        width: 160,
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD3D1D8).withOpacity(0.25),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image Container
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(15)),
                  child: widget.imageUrl != null
                      ? Image.network(
                          widget.imageUrl!,
                          height: 110,
                          width: double.infinity,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
                // Price Badge
                Positioned(
                  top: 10,
                  left: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(
                      '${widget.price.toStringAsFixed(0)}đ',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                // Add to Cart Button
                if (widget.showAddToCart && widget.id != null)
                  Positioned(
                    bottom: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: () => _addToCart(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 20,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ),
                // Favorite Button
                if (widget.showFavorite && widget.id != null)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: GestureDetector(
                      onTap: _toggleFavorite,
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isFavorite ? Icons.favorite : Icons.favorite_border,
                          size: 16,
                          color: AppColors.primaryColor,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            // Content
            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Rating
                  Row(
                    children: [
                      const Icon(Icons.star, color: AppColors.accentColor, size: 16),
                      const SizedBox(width: 4),
                      Text(
                        widget.rating.toStringAsFixed(1),
                        style: const TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        ' (${widget.reviewCount})',
                        style: const TextStyle(
                          fontSize: 11,
                          color: AppColors.subColor,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Food Name
                  Text(
                    widget.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  // Shop Name
                  Row(
                    children: [
                      if (widget.isVerified) ...[
                        const Icon(Icons.verified, color: Colors.green, size: 14),
                        const SizedBox(width: 4),
                      ],
                      Expanded(
                        child: Text(
                          widget.shopName,
                          style: const TextStyle(
                            fontSize: 12,
                            color: AppColors.subColor,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
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
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 110,
      width: double.infinity,
      color: AppColors.background,
      child: const Icon(
        Icons.fastfood,
        size: 40,
        color: AppColors.subColor,
      ),
    );
  }
}

class FoodItemListTile extends StatelessWidget {
  final int? id;
  final String? imageUrl;
  final String name;
  final String shopName;
  final int shopId;
  final double price;
  final double? discountPrice;
  final double rating;
  final String? distance;
  final String? deliveryTime;
  final String? discount;
  final VoidCallback? onTap;
  final bool showAddToCart;

  const FoodItemListTile({
    super.key,
    this.id,
    this.imageUrl,
    required this.name,
    required this.shopName,
    this.shopId = 0,
    required this.price,
    this.discountPrice,
    required this.rating,
    this.distance,
    this.deliveryTime,
    this.discount,
    this.onTap,
    this.showAddToCart = true,
  });

  void _addToCart(BuildContext context) {
    if (id == null) return;
    
    final cart = LocalCartManager.instance;
    cart.addFromFoodData(
      id: id!,
      name: name,
      shopName: shopName,
      shopId: shopId,
      price: price,
      discountPrice: discountPrice,
      imageUrl: imageUrl,
    );
    
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text('Đã thêm "$name" vào giỏ hàng'),
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
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFD3D1D8).withOpacity(0.15),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            // Image
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.horizontal(left: Radius.circular(15)),
                  child: imageUrl != null
                      ? Image.network(
                          imageUrl!,
                          height: 100,
                          width: 100,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return _buildPlaceholderImage();
                          },
                        )
                      : _buildPlaceholderImage(),
                ),
                if (discount != null)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primaryColor,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        discount!,
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
            // Content
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Name
                    Text(
                      name,
                      style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: AppColors.textPrimary,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    // Shop name
                    Text(
                      shopName,
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // Rating & Info Row
                    Row(
                      children: [
                        const Icon(Icons.star, color: AppColors.accentColor, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          rating.toStringAsFixed(1),
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppColors.textPrimary,
                          ),
                        ),
                        if (distance != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.location_on, color: AppColors.subColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            distance!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.subColor,
                            ),
                          ),
                        ],
                        if (deliveryTime != null) ...[
                          const SizedBox(width: 12),
                          const Icon(Icons.access_time, color: AppColors.subColor, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            deliveryTime!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.subColor,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ),
              ),
            ),
            // Price and Add to Cart
            Padding(
              padding: const EdgeInsets.only(right: 12),
              child: Column(
                children: [
                  Text(
                    '${price.toStringAsFixed(0)}đ',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppColors.primaryColor,
                    ),
                  ),
                  if (showAddToCart && id != null) ...[
                    const SizedBox(height: 8),
                    GestureDetector(
                      onTap: () => _addToCart(context),
                      child: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor,
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.primaryColor.withOpacity(0.4),
                              blurRadius: 8,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.add,
                          size: 18,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlaceholderImage() {
    return Container(
      height: 100,
      width: 100,
      color: AppColors.background,
      child: const Icon(
        Icons.fastfood,
        size: 30,
        color: AppColors.subColor,
      ),
    );
  }
}
