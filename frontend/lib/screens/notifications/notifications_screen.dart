import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_theme.dart';
import '../../services/notification_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  List<Map<String, dynamic>> _notifications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  Future<void> _loadNotifications() async {
    setState(() => _isLoading = true);
    try {
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        final result = await NotificationService.getNotifications(user.id);
        setState(() {
          _notifications = List<Map<String, dynamic>>.from(result);
          _isLoading = false;
        });
      } else {
        // Demo data khi chưa đăng nhập
        setState(() {
          _notifications = _getDemoNotifications();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _notifications = _getDemoNotifications();
        _isLoading = false;
      });
    }
  }

  List<Map<String, dynamic>> _getDemoNotifications() {
    return [
      {
        'id': 1,
        'type': 'order',
        'title': 'Đơn hàng đã được giao',
        'message': 'Đơn hàng #12345 đã được giao thành công. Cảm ơn bạn đã sử dụng dịch vụ!',
        'time': DateTime.now().subtract(const Duration(minutes: 5)),
        'isRead': false,
        'icon': Icons.check_circle,
        'color': AppColors.success,
      },
      {
        'id': 2,
        'type': 'promo',
        'title': '🎉 Khuyến mãi đặc biệt!',
        'message': 'Giảm 30% cho đơn hàng đầu tiên trong tuần. Mã: TUANMOI30',
        'time': DateTime.now().subtract(const Duration(hours: 2)),
        'isRead': false,
        'icon': Icons.local_offer,
        'color': AppColors.primaryColor,
      },
      {
        'id': 3,
        'type': 'order',
        'title': 'Đang giao hàng',
        'message': 'Đơn hàng #12344 đang được shipper giao đến bạn. Dự kiến 15 phút nữa.',
        'time': DateTime.now().subtract(const Duration(hours: 5)),
        'isRead': true,
        'icon': Icons.delivery_dining,
        'color': AppColors.accentColor,
      },
      {
        'id': 4,
        'type': 'system',
        'title': 'Cập nhật ứng dụng',
        'message': 'Phiên bản mới 2.0 đã có sẵn với nhiều tính năng mới. Cập nhật ngay!',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': true,
        'icon': Icons.system_update,
        'color': AppColors.info,
      },
      {
        'id': 5,
        'type': 'promo',
        'title': 'Flash Sale 12:00',
        'message': 'Giảm giá sốc 50% cho tất cả món ăn từ 12:00 - 13:00 hôm nay!',
        'time': DateTime.now().subtract(const Duration(days: 1)),
        'isRead': true,
        'icon': Icons.flash_on,
        'color': AppColors.error,
      },
      {
        'id': 6,
        'type': 'review',
        'title': 'Đánh giá đơn hàng',
        'message': 'Hãy đánh giá đơn hàng #12340 của bạn để nhận 10 điểm thưởng!',
        'time': DateTime.now().subtract(const Duration(days: 2)),
        'isRead': true,
        'icon': Icons.star,
        'color': AppColors.accentColor,
      },
    ];
  }

  Future<void> _markAsRead(int id) async {
    setState(() {
      final index = _notifications.indexWhere((n) => n['id'] == id);
      if (index != -1) {
        _notifications[index]['isRead'] = true;
      }
    });
    // TODO: Call API to mark as read
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      for (var notification in _notifications) {
        notification['isRead'] = true;
      }
    });
    // TODO: Call API to mark all as read
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Đã đánh dấu tất cả là đã đọc'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  Future<void> _deleteNotification(int id) async {
    setState(() {
      _notifications.removeWhere((n) => n['id'] == id);
    });
    // TODO: Call API to delete
  }

  Future<void> _clearAll() async {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tất cả thông báo?'),
        content: const Text('Bạn có chắc chắn muốn xóa tất cả thông báo?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              setState(() => _notifications.clear());
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa tất cả thông báo'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  int get _unreadCount => _notifications.where((n) => n['isRead'] == false).length;

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
        title: Row(
          children: [
            const Text(
              'Thông báo',
              style: TextStyle(
                color: AppColors.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            if (_unreadCount > 0) ...[
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryColor,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  '$_unreadCount mới',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
        actions: [
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert, color: AppColors.textPrimary),
            onSelected: (value) {
              if (value == 'read_all') {
                _markAllAsRead();
              } else if (value == 'clear_all') {
                _clearAll();
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'read_all',
                child: Row(
                  children: [
                    Icon(Icons.done_all, color: AppColors.primaryColor),
                    SizedBox(width: 8),
                    Text('Đánh dấu đã đọc'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_all',
                child: Row(
                  children: [
                    Icon(Icons.delete_sweep, color: AppColors.error),
                    SizedBox(width: 8),
                    Text('Xóa tất cả'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _notifications.isEmpty
              ? _buildEmptyState()
              : RefreshIndicator(
                  onRefresh: _loadNotifications,
                  child: ListView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    itemCount: _notifications.length,
                    itemBuilder: (context, index) {
                      final notification = _notifications[index];
                      return _buildNotificationItem(notification);
                    },
                  ),
                ),
    );
  }

  Widget _buildNotificationItem(Map<String, dynamic> notification) {
    final isRead = notification['isRead'] as bool;
    final time = notification['time'] as DateTime;
    
    return Dismissible(
      key: Key('notification_${notification['id']}'),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.error,
        child: const Icon(Icons.delete, color: Colors.white),
      ),
      onDismissed: (_) => _deleteNotification(notification['id']),
      child: InkWell(
        onTap: () {
          _markAsRead(notification['id']);
          _showNotificationDetail(notification);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
          decoration: BoxDecoration(
            color: isRead ? Colors.transparent : AppColors.primaryColor.withOpacity(0.05),
              border: Border(
              bottom: BorderSide(
                color: AppColors.inputBorder,
                width: 1,
              ),
            ),
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Icon
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: (notification['color'] as Color).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  notification['icon'] as IconData,
                  color: notification['color'] as Color,
                  size: 24,
                ),
              ),
              const SizedBox(width: 12),
              // Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            notification['title'],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: isRead ? FontWeight.w500 : FontWeight.bold,
                              color: AppColors.textPrimary,
                            ),
                          ),
                        ),
                        if (!isRead)
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppColors.primaryColor,
                              shape: BoxShape.circle,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      notification['message'],
                      style: TextStyle(
                        fontSize: 13,
                        color: isRead ? AppColors.subColor : AppColors.textPrimary.withOpacity(0.8),
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      _formatTime(time),
                      style: const TextStyle(
                        fontSize: 12,
                        color: AppColors.subColor,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final diff = now.difference(time);

    if (diff.inMinutes < 1) {
      return 'Vừa xong';
    } else if (diff.inMinutes < 60) {
      return '${diff.inMinutes} phút trước';
    } else if (diff.inHours < 24) {
      return '${diff.inHours} giờ trước';
    } else if (diff.inDays < 7) {
      return '${diff.inDays} ngày trước';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }

  void _showNotificationDetail(Map<String, dynamic> notification) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: (notification['color'] as Color).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    notification['icon'] as IconData,
                    color: notification['color'] as Color,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'],
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        _formatTime(notification['time']),
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppColors.subColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            Text(
              notification['message'],
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textPrimary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            if (notification['type'] == 'order')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Navigate to order detail
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Xem đơn hàng',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            if (notification['type'] == 'promo')
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    // TODO: Apply promo code
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryColor,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Sử dụng ngay',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
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
            child: const Icon(
              Icons.notifications_none,
              size: 60,
              color: AppColors.primaryColor,
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Không có thông báo',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Bạn chưa có thông báo nào',
            style: TextStyle(
              fontSize: 14,
              color: AppColors.subColor,
            ),
          ),
        ],
      ),
    );
  }
}
