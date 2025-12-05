import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Cart Item Model
class CartItem {
  final int id;
  final String name;
  final String shopName;
  final int shopId;
  final double price;
  final double? discountPrice;
  final String? imageUrl;
  int quantity;
  String? note;
  List<String> extras;

  CartItem({
    required this.id,
    required this.name,
    required this.shopName,
    required this.shopId,
    required this.price,
    this.discountPrice,
    this.imageUrl,
    this.quantity = 1,
    this.note,
    this.extras = const [],
  });

  double get totalPrice => (discountPrice ?? price) * quantity;
  
  double get unitPrice => discountPrice ?? price;
  
  bool get hasDiscount => discountPrice != null && discountPrice! < price;
  
  double get discountPercent => hasDiscount 
      ? ((price - discountPrice!) / price * 100) 
      : 0;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'shopName': shopName,
    'shopId': shopId,
    'price': price,
    'discountPrice': discountPrice,
    'imageUrl': imageUrl,
    'quantity': quantity,
    'note': note,
    'extras': extras,
  };

  factory CartItem.fromJson(Map<String, dynamic> json) => CartItem(
    id: json['id'],
    name: json['name'],
    shopName: json['shopName'],
    shopId: json['shopId'] ?? 0,
    price: (json['price'] ?? 0).toDouble(),
    discountPrice: json['discountPrice']?.toDouble(),
    imageUrl: json['imageUrl'],
    quantity: json['quantity'] ?? 1,
    note: json['note'],
    extras: List<String>.from(json['extras'] ?? []),
  );

  CartItem copyWith({
    int? id,
    String? name,
    String? shopName,
    int? shopId,
    double? price,
    double? discountPrice,
    String? imageUrl,
    int? quantity,
    String? note,
    List<String>? extras,
  }) {
    return CartItem(
      id: id ?? this.id,
      name: name ?? this.name,
      shopName: shopName ?? this.shopName,
      shopId: shopId ?? this.shopId,
      price: price ?? this.price,
      discountPrice: discountPrice ?? this.discountPrice,
      imageUrl: imageUrl ?? this.imageUrl,
      quantity: quantity ?? this.quantity,
      note: note ?? this.note,
      extras: extras ?? this.extras,
    );
  }
}

/// Local Cart Manager - Singleton pattern with ChangeNotifier
class LocalCartManager extends ChangeNotifier {
  static final LocalCartManager _instance = LocalCartManager._internal();
  factory LocalCartManager() => _instance;
  LocalCartManager._internal();

  static LocalCartManager get instance => _instance;

  final List<CartItem> _items = [];
  String? _promoCode;
  double _promoDiscount = 0;
  double _deliveryFee = 15000;

  // Getters
  List<CartItem> get items => List.unmodifiable(_items);
  
  int get itemCount => _items.fold(0, (sum, item) => sum + item.quantity);
  
  int get uniqueItemCount => _items.length;
  
  double get subtotal => _items.fold(0, (sum, item) => sum + item.totalPrice);
  
  double get deliveryFee => _items.isEmpty ? 0 : _deliveryFee;
  
  double get promoDiscount => _promoDiscount;
  
  String? get promoCode => _promoCode;
  
  double get total {
    if (_items.isEmpty) return 0;
    final result = subtotal + deliveryFee - promoDiscount;
    return result < 0 ? 0 : result;
  }
  
  bool get isEmpty => _items.isEmpty;
  
  bool get isNotEmpty => _items.isNotEmpty;

  // Get items grouped by shop
  Map<String, List<CartItem>> get itemsByShop {
    final Map<String, List<CartItem>> grouped = {};
    for (var item in _items) {
      if (!grouped.containsKey(item.shopName)) {
        grouped[item.shopName] = [];
      }
      grouped[item.shopName]!.add(item);
    }
    return grouped;
  }

  // Check if item exists in cart
  bool hasItem(int itemId) => _items.any((item) => item.id == itemId);
  
  // Get item by ID
  CartItem? getItem(int itemId) {
    try {
      return _items.firstWhere((item) => item.id == itemId);
    } catch (e) {
      return null;
    }
  }
  
  // Get quantity of specific item
  int getItemQuantity(int itemId) {
    final item = getItem(itemId);
    return item?.quantity ?? 0;
  }

  // Add item to cart
  void addItem(CartItem item) {
    final existingIndex = _items.indexWhere((i) => i.id == item.id);
    
    if (existingIndex >= 0) {
      // Item exists, increase quantity
      _items[existingIndex].quantity += item.quantity;
    } else {
      // New item
      _items.add(item);
    }
    
    _saveToLocal();
    notifyListeners();
  }

  // Add item from food data
  void addFromFoodData({
    required int id,
    required String name,
    required String shopName,
    required int shopId,
    required double price,
    double? discountPrice,
    String? imageUrl,
    int quantity = 1,
    String? note,
    List<String>? extras,
  }) {
    addItem(CartItem(
      id: id,
      name: name,
      shopName: shopName,
      shopId: shopId,
      price: price,
      discountPrice: discountPrice,
      imageUrl: imageUrl,
      quantity: quantity,
      note: note,
      extras: extras ?? [],
    ));
  }

  // Remove item from cart
  void removeItem(int itemId) {
    _items.removeWhere((item) => item.id == itemId);
    _saveToLocal();
    notifyListeners();
  }

  // Update item quantity
  void updateQuantity(int itemId, int quantity) {
    if (quantity <= 0) {
      removeItem(itemId);
      return;
    }
    
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].quantity = quantity;
      _saveToLocal();
      notifyListeners();
    }
  }

  // Increase item quantity
  void increaseQuantity(int itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].quantity++;
      _saveToLocal();
      notifyListeners();
    }
  }

  // Decrease item quantity
  void decreaseQuantity(int itemId) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      if (_items[index].quantity > 1) {
        _items[index].quantity--;
      } else {
        _items.removeAt(index);
      }
      _saveToLocal();
      notifyListeners();
    }
  }

  // Update item note
  void updateNote(int itemId, String? note) {
    final index = _items.indexWhere((item) => item.id == itemId);
    if (index >= 0) {
      _items[index].note = note;
      _saveToLocal();
      notifyListeners();
    }
  }

  // Clear all items
  void clear() {
    _items.clear();
    _promoCode = null;
    _promoDiscount = 0;
    _saveToLocal();
    notifyListeners();
  }

  // Apply promo code
  Future<Map<String, dynamic>> applyPromoCode(String code) async {
    // Simulate promo code validation
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Mock promo codes
    final promoCodes = {
      'GIAM10': {'type': 'percent', 'value': 0.1, 'name': 'Giảm 10%'},
      'GIAM20': {'type': 'percent', 'value': 0.2, 'name': 'Giảm 20%'},
      'GIAM30K': {'type': 'fixed', 'value': 30000.0, 'name': 'Giảm 30.000đ'},
      'GIAM50K': {'type': 'fixed', 'value': 50000.0, 'name': 'Giảm 50.000đ'},
      'FREESHIP': {'type': 'freeship', 'value': 0.0, 'name': 'Miễn phí vận chuyển'},
      'NEWUSER': {'type': 'percent', 'value': 0.15, 'name': 'Giảm 15% cho khách mới'},
    };
    
    final upperCode = code.toUpperCase();
    if (promoCodes.containsKey(upperCode)) {
      final promo = promoCodes[upperCode]!;
      _promoCode = upperCode;
      
      if (promo['type'] == 'freeship') {
        _promoDiscount = _deliveryFee;
      } else if (promo['type'] == 'percent') {
        _promoDiscount = subtotal * (promo['value'] as double);
      } else {
        _promoDiscount = promo['value'] as double;
      }
      
      _saveToLocal();
      notifyListeners();
      return {
        'success': true,
        'message': 'Áp dụng mã "${promo['name']}" thành công!',
        'discount': _promoDiscount,
      };
    }
    
    return {
      'success': false,
      'message': 'Mã giảm giá không hợp lệ hoặc đã hết hạn',
    };
  }

  // Remove promo code
  void removePromoCode() {
    _promoCode = null;
    _promoDiscount = 0;
    _saveToLocal();
    notifyListeners();
  }

  // Set delivery fee
  void setDeliveryFee(double fee) {
    _deliveryFee = fee;
    notifyListeners();
  }

  // Save cart to local storage
  Future<void> _saveToLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartData = {
        'items': _items.map((item) => item.toJson()).toList(),
        'promoCode': _promoCode,
        'promoDiscount': _promoDiscount,
        'deliveryFee': _deliveryFee,
      };
      await prefs.setString('cart_data', jsonEncode(cartData));
    } catch (e) {
      debugPrint('Error saving cart: $e');
    }
  }

  // Load cart from local storage
  Future<void> loadFromLocal() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cartJson = prefs.getString('cart_data');
      
      if (cartJson != null) {
        final cartData = jsonDecode(cartJson);
        _items.clear();
        
        final itemsList = cartData['items'] as List?;
        if (itemsList != null) {
          for (var itemJson in itemsList) {
            _items.add(CartItem.fromJson(itemJson));
          }
        }
        
        _promoCode = cartData['promoCode'];
        _promoDiscount = (cartData['promoDiscount'] ?? 0).toDouble();
        _deliveryFee = (cartData['deliveryFee'] ?? 15000).toDouble();
        
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading cart: $e');
    }
  }
}
