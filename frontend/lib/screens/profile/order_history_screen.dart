import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/app_theme.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<Map<String, dynamic>> _orders = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _loadOrders();
  }
  
  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }
  
  Future<void> _loadOrders() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final ordersJson = prefs.getString('order_history');
      if (ordersJson != null) {
        final List<dynamic> decoded = jsonDecode(ordersJson);
        _orders = decoded.cast<Map<String, dynamic>>();
      } else {
        // Demo data
        _orders = _getDemoOrders();
        await prefs.setString('order_history', jsonEncode(_orders));
      }
    } catch (e) {
      debugPrint('Error loading orders: $e');
      _orders = _getDemoOrders();
    }
    setState(() => _isLoading = false);
  }
  
  List<Map<String, dynamic>> _getDemoOrders() {
    return [
      {
        'id': 'DH001',
        'date': '2025-12-05 14:30',
        'status': 'delivered',
        'total': 185000,
        'shopName': 'Phở Hà Nội',
        'shopImage': 'https://images.unsplash.com/photo-1569058242567-93de6f36f8eb?w=100',
        'items': [
          {'name': 'Phở Bò Đặc Biệt', 'quantity': 2, 'price': 65000},
          {'name': 'Nem Rán', 'quantity': 1, 'price': 35000},
          {'name': 'Nước Chanh', 'quantity': 2, 'price': 10000},
        ],
        'deliveryAddress': '123 Nguyễn Văn Linh, Q.7, TP.HCM',
        'paymentMethod': 'Tiền mặt',
      },
      {
        'id': 'DH002',
        'date': '2025-12-04 19:15',
        'status': 'delivered',
        'total': 120000,
        'shopName': 'Cơm Tấm Sài Gòn',
        'shopImage': 'https://images.unsplash.com/photo-1512058564366-18510be2db19?w=100',
        'items': [
          {'name': 'Cơm Tấm Sườn Bì Chả', 'quantity': 2, 'price': 55000},
          {'name': 'Nước Ngọt', 'quantity': 2, 'price': 5000},
        ],
        'deliveryAddress': '456 Lê Văn Sỹ, Q.3, TP.HCM',
        'paymentMethod': 'MoMo',
      },
      {
        'id': 'DH003',
        'date': '2025-12-06 12:00',
        'status': 'processing',
        'total': 95000,
        'shopName': 'Bún Bò Huế',
        'shopImage': 'https://images.unsplash.com/photo-1582878826629-29b7ad1cdc43?w=100',
        'items': [
          {'name': 'Bún Bò Đặc Biệt', 'quantity': 1, 'price': 55000},
          {'name': 'Bún Bò Giò Heo', 'quantity': 1, 'price': 40000},
        ],
        'deliveryAddress': '789 Hai Bà Trưng, Q.1, TP.HCM',
        'paymentMethod': 'ZaloPay',
      },
      {
        'id': 'DH004',
        'date': '2025-12-03 20:30',
        'status': 'cancelled',
        'total': 75000,
        'shopName': 'Bánh Mì Huỳnh Hoa',
        'shopImage': 'https://images.unsplash.com/photo-1600628421055-4d30de868b8f?w=100',
        'items': [
          {'name': 'Bánh Mì Thịt Nướng', 'quantity': 2, 'price': 30000},
          {'name': 'Bánh Mì Đặc Biệt', 'quantity': 1, 'price': 15000},
        ],
        'deliveryAddress': '321 Võ Văn Tần, Q.3, TP.HCM',
        'paymentMethod': 'Tiền mặt',
        'cancelReason': 'Quán hết món',
      },
    ];
  }
  
  List<Map<String, dynamic>> _getFilteredOrders(String? status) {
    if (status == null) return _orders;
    return _orders.where((order) => order['status'] == status).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Lịch sử đơn hàng',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primaryColor,
          unselectedLabelColor: AppColors.subColor,
          indicatorColor: AppColors.primaryColor,
          isScrollable: true,
          tabs: const [
            Tab(text: 'Tất cả'),
            Tab(text: 'Đang xử lý'),
            Tab(text: 'Đã giao'),
            Tab(text: 'Đã hủy'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : TabBarView(
              controller: _tabController,
              children: [
                _buildOrderList(null),
                _buildOrderList('processing'),
                _buildOrderList('delivered'),
                _buildOrderList('cancelled'),
              ],
            ),
    );
  }
  
  Widget _buildOrderList(String? status) {
    final orders = _getFilteredOrders(status);
    
    if (orders.isEmpty) {
      return _buildEmptyState(status);
    }
    
    return RefreshIndicator(
      onRefresh: _loadOrders,
      color: AppColors.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: orders.length,
        itemBuilder: (context, index) => _buildOrderCard(orders[index]),
      ),
    );
  }
  
  Widget _buildEmptyState(String? status) {
    String message;
    IconData icon;
    
    switch (status) {
      case 'processing':
        message = 'Không có đơn hàng đang xử lý';
        icon = Icons.pending_outlined;
        break;
      case 'delivered':
        message = 'Chưa có đơn hàng nào được giao';
        icon = Icons.check_circle_outline;
        break;
      case 'cancelled':
        message = 'Không có đơn hàng đã hủy';
        icon = Icons.cancel_outlined;
        break;
      default:
        message = 'Chưa có đơn hàng nào';
        icon = Icons.receipt_long_outlined;
    }
    
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            message,
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: () => Navigator.pushNamed(context, '/home'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            child: const Text(
              'Đặt món ngay',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
  
  Widget _buildOrderCard(Map<String, dynamic> order) {
    final status = order['status'];
    final statusInfo = _getStatusInfo(status);
    
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusInfo['bgColor'],
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Icon(statusInfo['icon'], size: 18, color: statusInfo['color']),
                    const SizedBox(width: 6),
                    Text(
                      statusInfo['label'],
                      style: TextStyle(
                        color: statusInfo['color'],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                Text(
                  '#${order['id']}',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          
          // Shop info
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.network(
                    order['shopImage'] ?? '',
                    width: 50,
                    height: 50,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => Container(
                      width: 50,
                      height: 50,
                      color: Colors.grey.shade200,
                      child: const Icon(Icons.store, color: Colors.grey),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        order['shopName'] ?? '',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        order['date'] ?? '',
                        style: TextStyle(
                          color: Colors.grey.shade500,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      _formatPrice(order['total']),
                      style: const TextStyle(
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      '${(order['items'] as List).length} món',
                      style: TextStyle(
                        color: Colors.grey.shade500,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // Items preview
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.grey.shade50,
              border: Border(
                top: BorderSide(color: Colors.grey.shade200),
                bottom: BorderSide(color: Colors.grey.shade200),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    (order['items'] as List).map((item) => '${item['name']} x${item['quantity']}').join(', '),
                    style: TextStyle(
                      color: Colors.grey.shade600,
                      fontSize: 13,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          
          // Actions
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showOrderDetail(order),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.textPrimary,
                      side: BorderSide(color: Colors.grey.shade300),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text('Chi tiết'),
                  ),
                ),
                const SizedBox(width: 12),
                if (status == 'delivered')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () {
                        // Đặt lại đơn hàng
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Đã thêm vào giỏ hàng'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Đặt lại', style: TextStyle(color: Colors.white)),
                    ),
                  ),
                if (status == 'processing')
                  Expanded(
                    child: ElevatedButton(
                      onPressed: () => _trackOrder(order),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text('Theo dõi', style: TextStyle(color: Colors.white)),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
  
  Map<String, dynamic> _getStatusInfo(String status) {
    switch (status) {
      case 'processing':
        return {
          'label': 'Đang xử lý',
          'color': Colors.orange,
          'bgColor': Colors.orange.shade50,
          'icon': Icons.pending_outlined,
        };
      case 'delivered':
        return {
          'label': 'Đã giao',
          'color': Colors.green,
          'bgColor': Colors.green.shade50,
          'icon': Icons.check_circle_outline,
        };
      case 'cancelled':
        return {
          'label': 'Đã hủy',
          'color': Colors.red,
          'bgColor': Colors.red.shade50,
          'icon': Icons.cancel_outlined,
        };
      default:
        return {
          'label': 'Không xác định',
          'color': Colors.grey,
          'bgColor': Colors.grey.shade50,
          'icon': Icons.help_outline,
        };
    }
  }
  
  String _formatPrice(dynamic price) {
    final p = (price ?? 0).toDouble();
    return '${p.toStringAsFixed(0).replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]}.',
    )}đ';
  }
  
  void _showOrderDetail(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
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
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                  Text(
                    'Đơn hàng #${order['id']}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 48),
                ],
              ),
            ),
            
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Status
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _getStatusInfo(order['status'])['bgColor'],
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _getStatusInfo(order['status'])['icon'],
                            color: _getStatusInfo(order['status'])['color'],
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _getStatusInfo(order['status'])['label'],
                            style: TextStyle(
                              color: _getStatusInfo(order['status'])['color'],
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                    
                    if (order['cancelReason'] != null) ...[
                      const SizedBox(height: 10),
                      Text(
                        'Lý do hủy: ${order['cancelReason']}',
                        style: const TextStyle(color: AppColors.error),
                      ),
                    ],
                    
                    const SizedBox(height: 20),
                    
                    // Shop info
                    const Text(
                      'Quán',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            order['shopImage'] ?? '',
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (_, __, ___) => Container(
                              width: 50,
                              height: 50,
                              color: Colors.grey.shade200,
                              child: const Icon(Icons.store, color: Colors.grey),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Text(
                          order['shopName'] ?? '',
                          style: const TextStyle(fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Items
                    const Text(
                      'Các món đã đặt',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    ...(order['items'] as List).map((item) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              '${item['name']} x${item['quantity']}',
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Text(
                            _formatPrice(item['price'] * item['quantity']),
                            style: const TextStyle(fontWeight: FontWeight.w500),
                          ),
                        ],
                      ),
                    )),
                    
                    const Divider(height: 30),
                    
                    // Total
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          'Tổng cộng',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        Text(
                          _formatPrice(order['total']),
                          style: const TextStyle(
                            color: AppColors.primaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Delivery address
                    const Text(
                      'Địa chỉ giao hàng',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, color: AppColors.subColor),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            order['deliveryAddress'] ?? '',
                            style: TextStyle(color: Colors.grey.shade700),
                          ),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Payment method
                    const Text(
                      'Phương thức thanh toán',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.payment_outlined, color: AppColors.subColor),
                        const SizedBox(width: 8),
                        Text(
                          order['paymentMethod'] ?? '',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
                    ),
                    
                    const SizedBox(height: 20),
                    
                    // Order time
                    const Text(
                      'Thời gian đặt',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        const Icon(Icons.access_time, color: AppColors.subColor),
                        const SizedBox(width: 8),
                        Text(
                          order['date'] ?? '',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                      ],
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
  
  void _trackOrder(Map<String, dynamic> order) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        decoration: const BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'Theo dõi đơn hàng',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            _buildTrackingStep('Đã xác nhận đơn', true),
            _buildTrackingStep('Đang chuẩn bị', true),
            _buildTrackingStep('Đang giao hàng', false),
            _buildTrackingStep('Đã giao hàng', false),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Row(
                children: [
                  Icon(Icons.access_time, color: AppColors.primaryColor),
                  SizedBox(width: 10),
                  Text(
                    'Dự kiến giao: 15-20 phút',
                    style: TextStyle(
                      color: AppColors.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTrackingStep(String title, bool isCompleted) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 24,
            height: 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isCompleted ? AppColors.success : Colors.grey.shade300,
            ),
            child: isCompleted
                ? const Icon(Icons.check, color: Colors.white, size: 16)
                : null,
          ),
          const SizedBox(width: 12),
          Text(
            title,
            style: TextStyle(
              color: isCompleted ? AppColors.textPrimary : AppColors.subColor,
              fontWeight: isCompleted ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }
}
