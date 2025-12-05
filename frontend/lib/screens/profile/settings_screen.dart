import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_theme.dart';
import '../../services/settings_manager.dart';
import '../../services/supabase_google_auth_service.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _settings = SettingsManager.instance;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initSettings();
  }

  Future<void> _initSettings() async {
    await _settings.init();
    setState(() => _isLoading = false);
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
          'Cài đặt',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // === THÔNG BÁO ===
                  _buildSectionTitle('Thông báo'),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.notifications_outlined,
                      iconColor: AppColors.primaryColor,
                      title: 'Thông báo đẩy',
                      subtitle: 'Nhận thông báo từ ứng dụng',
                      value: _settings.notifications,
                      onChanged: (value) async {
                        await _settings.setNotifications(value);
                        setState(() {});
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.delivery_dining,
                      iconColor: Colors.blue,
                      title: 'Cập nhật đơn hàng',
                      subtitle: 'Nhận thông báo về trạng thái đơn hàng',
                      value: _settings.orderUpdates,
                      onChanged: (value) async {
                        await _settings.setOrderUpdates(value);
                        setState(() {});
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.local_offer_outlined,
                      iconColor: Colors.orange,
                      title: 'Khuyến mãi',
                      subtitle: 'Nhận thông tin về ưu đãi và giảm giá',
                      value: _settings.promotions,
                      onChanged: (value) async {
                        await _settings.setPromotions(value);
                        setState(() {});
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.store_outlined,
                      iconColor: Colors.green,
                      title: 'Quán mới',
                      subtitle: 'Thông báo khi có quán ăn mới gần bạn',
                      value: _settings.newRestaurants,
                      onChanged: (value) async {
                        await _settings.setNewRestaurants(value);
                        setState(() {});
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // === HIỂN THỊ ===
                  _buildSectionTitle('Hiển thị'),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.dark_mode_outlined,
                      iconColor: Colors.purple,
                      title: 'Chế độ tối',
                      subtitle: 'Bật giao diện tối cho ứng dụng',
                      value: _settings.darkMode,
                      onChanged: (value) async {
                        await _settings.setDarkMode(value);
                        setState(() {});
                        _showSnackBar('Tính năng đang phát triển');
                      },
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.language,
                      iconColor: Colors.teal,
                      title: 'Ngôn ngữ',
                      subtitle: _settings.languageDisplayName,
                      onTap: () => _showLanguageDialog(),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.straighten,
                      iconColor: Colors.indigo,
                      title: 'Đơn vị khoảng cách',
                      subtitle: _settings.distanceUnit.toUpperCase(),
                      onTap: () => _showDistanceUnitDialog(),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // === QUYỀN RIÊNG TƯ ===
                  _buildSectionTitle('Quyền riêng tư'),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.location_on_outlined,
                      iconColor: Colors.red,
                      title: 'Dịch vụ vị trí',
                      subtitle: 'Cho phép ứng dụng truy cập vị trí',
                      value: _settings.locationServices,
                      onChanged: (value) async {
                        await _settings.setLocationServices(value);
                        setState(() {});
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.history,
                      iconColor: Colors.blueGrey,
                      title: 'Lưu lịch sử tìm kiếm',
                      subtitle: 'Lưu các tìm kiếm gần đây',
                      value: _settings.saveSearchHistory,
                      onChanged: (value) async {
                        await _settings.setSaveSearchHistory(value);
                        setState(() {});
                      },
                    ),
                    _buildDivider(),
                    _buildSwitchTile(
                      icon: Icons.fingerprint,
                      iconColor: Colors.deepPurple,
                      title: 'Đăng nhập sinh trắc học',
                      subtitle: 'Sử dụng vân tay hoặc FaceID',
                      value: _settings.biometricLogin,
                      onChanged: (value) async {
                        await _settings.setBiometricLogin(value);
                        setState(() {});
                        _showSnackBar('Tính năng đang phát triển');
                      },
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // === THANH TOÁN ===
                  _buildSectionTitle('Thanh toán'),
                  _buildSettingsCard([
                    _buildNavigationTile(
                      icon: Icons.payment,
                      iconColor: Colors.green,
                      title: 'Phương thức thanh toán mặc định',
                      subtitle: _settings.paymentDisplayName,
                      onTap: () => _showPaymentDialog(),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.credit_card,
                      iconColor: Colors.blue,
                      title: 'Quản lý thẻ',
                      subtitle: 'Thêm, xóa hoặc sửa thẻ thanh toán',
                      onTap: () => _showSnackBar('Tính năng đang phát triển'),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // === DỮ LIỆU ===
                  _buildSectionTitle('Dữ liệu'),
                  _buildSettingsCard([
                    _buildSwitchTile(
                      icon: Icons.play_circle_outline,
                      iconColor: Colors.pink,
                      title: 'Tự động phát video',
                      subtitle: 'Tự động phát video trong ứng dụng',
                      value: _settings.autoPlayVideo,
                      onChanged: (value) async {
                        await _settings.setAutoPlayVideo(value);
                        setState(() {});
                      },
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.delete_sweep_outlined,
                      iconColor: Colors.orange,
                      title: 'Xóa lịch sử tìm kiếm',
                      subtitle: 'Xóa tất cả tìm kiếm gần đây',
                      onTap: () => _confirmClearSearchHistory(),
                    ),
                    _buildDivider(),
                    _buildActionTile(
                      icon: Icons.cleaning_services_outlined,
                      iconColor: Colors.brown,
                      title: 'Xóa cache',
                      subtitle: 'Xóa dữ liệu tạm của ứng dụng',
                      onTap: () => _confirmClearCache(),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // === HỖ TRỢ ===
                  _buildSectionTitle('Hỗ trợ'),
                  _buildSettingsCard([
                    _buildNavigationTile(
                      icon: Icons.help_outline,
                      iconColor: Colors.blue,
                      title: 'Trung tâm trợ giúp',
                      subtitle: 'Câu hỏi thường gặp và hướng dẫn',
                      onTap: () => _showSnackBar('Tính năng đang phát triển'),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.chat_bubble_outline,
                      iconColor: Colors.green,
                      title: 'Liên hệ hỗ trợ',
                      subtitle: 'Chat với nhân viên hỗ trợ',
                      onTap: () => _showSnackBar('Tính năng đang phát triển'),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.bug_report_outlined,
                      iconColor: Colors.red,
                      title: 'Báo cáo lỗi',
                      subtitle: 'Gửi báo cáo lỗi đến đội ngũ phát triển',
                      onTap: () => _showSnackBar('Tính năng đang phát triển'),
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // === THÔNG TIN ===
                  _buildSectionTitle('Thông tin'),
                  _buildSettingsCard([
                    _buildNavigationTile(
                      icon: Icons.description_outlined,
                      iconColor: Colors.grey,
                      title: 'Điều khoản dịch vụ',
                      onTap: () => _showTermsOfService(),
                    ),
                    _buildDivider(),
                    _buildNavigationTile(
                      icon: Icons.privacy_tip_outlined,
                      iconColor: Colors.grey,
                      title: 'Chính sách bảo mật',
                      onTap: () => _showPrivacyPolicy(),
                    ),
                    _buildDivider(),
                    _buildInfoTile(
                      icon: Icons.info_outline,
                      iconColor: Colors.grey,
                      title: 'Phiên bản',
                      trailing: 'v1.0.0',
                    ),
                  ]),

                  const SizedBox(height: 24),

                  // === RESET & LOGOUT ===
                  _buildSettingsCard([
                    _buildActionTile(
                      icon: Icons.restore,
                      iconColor: Colors.orange,
                      title: 'Khôi phục cài đặt mặc định',
                      subtitle: 'Đặt lại tất cả cài đặt về mặc định',
                      onTap: () => _confirmResetSettings(),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  _buildSettingsCard([
                    _buildActionTile(
                      icon: Icons.logout,
                      iconColor: AppColors.error,
                      title: 'Đăng xuất',
                      titleColor: AppColors.error,
                      onTap: () => _confirmLogout(),
                    ),
                  ]),

                  const SizedBox(height: 16),

                  _buildSettingsCard([
                    _buildActionTile(
                      icon: Icons.delete_forever,
                      iconColor: AppColors.error,
                      title: 'Xóa tài khoản',
                      titleColor: AppColors.error,
                      onTap: () => _confirmDeleteAccount(),
                    ),
                  ]),

                  const SizedBox(height: 40),
                ],
              ),
            ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 12),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  Widget _buildSettingsCard(List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(children: children),
    );
  }

  Widget _buildDivider() {
    return const Divider(height: 1, indent: 60);
  }

  Widget _buildSwitchTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: Switch.adaptive(
        value: value,
        onChanged: onChanged,
        activeColor: AppColors.primaryColor,
      ),
    );
  }

  Widget _buildNavigationTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      trailing: const Icon(Icons.chevron_right, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    String? subtitle,
    Color? titleColor,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: titleColor ?? AppColors.textPrimary,
        ),
      ),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(
                fontSize: 12,
                color: AppColors.textSecondary,
              ),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String trailing,
  }) {
    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: iconColor.withOpacity(0.1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(icon, color: iconColor, size: 22),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: AppColors.textPrimary,
        ),
      ),
      trailing: Text(
        trailing,
        style: const TextStyle(
          fontSize: 14,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // === DIALOGS ===

  void _showLanguageDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Chọn ngôn ngữ'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildLanguageOption('vi', 'Tiếng Việt', '🇻🇳'),
            _buildLanguageOption('en', 'English', '🇺🇸'),
          ],
        ),
      ),
    );
  }

  Widget _buildLanguageOption(String code, String name, String flag) {
    final isSelected = _settings.language == code;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(name),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
          : null,
      onTap: () async {
        await _settings.setLanguage(code);
        Navigator.pop(context);
        setState(() {});
        _showSnackBar('Đã chuyển sang $name');
      },
    );
  }

  void _showDistanceUnitDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đơn vị khoảng cách'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _buildUnitOption('km', 'Kilomet (km)'),
            _buildUnitOption('mi', 'Dặm (mi)'),
          ],
        ),
      ),
    );
  }

  Widget _buildUnitOption(String code, String name) {
    final isSelected = _settings.distanceUnit == code;
    return ListTile(
      title: Text(name),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
          : null,
      onTap: () async {
        await _settings.setDistanceUnit(code);
        Navigator.pop(context);
        setState(() {});
      },
    );
  }

  void _showPaymentDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Phương thức thanh toán'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildPaymentOption('cash', 'Tiền mặt', Icons.money),
              _buildPaymentOption('momo', 'MoMo', Icons.account_balance_wallet),
              _buildPaymentOption('zalopay', 'ZaloPay', Icons.account_balance_wallet),
              _buildPaymentOption('vnpay', 'VNPay', Icons.qr_code),
              _buildPaymentOption('card', 'Thẻ ngân hàng', Icons.credit_card),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPaymentOption(String code, String name, IconData icon) {
    final isSelected = _settings.defaultPayment == code;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primaryColor : Colors.grey),
      title: Text(name),
      trailing: isSelected
          ? const Icon(Icons.check_circle, color: AppColors.primaryColor)
          : null,
      onTap: () async {
        await _settings.setDefaultPayment(code);
        Navigator.pop(context);
        setState(() {});
      },
    );
  }

  void _confirmClearSearchHistory() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa lịch sử tìm kiếm'),
        content: const Text('Bạn có chắc muốn xóa tất cả lịch sử tìm kiếm?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _settings.clearSearchHistory();
              Navigator.pop(context);
              _showSnackBar('Đã xóa lịch sử tìm kiếm');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmClearCache() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa cache'),
        content: const Text('Bạn có chắc muốn xóa cache ứng dụng? Điều này có thể làm chậm ứng dụng tạm thời.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _settings.clearCache();
              Navigator.pop(context);
              _showSnackBar('Đã xóa cache');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Xóa', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmResetSettings() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Khôi phục cài đặt'),
        content: const Text('Bạn có chắc muốn đặt lại tất cả cài đặt về mặc định?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await _settings.resetToDefaults();
              Navigator.pop(context);
              setState(() {});
              _showSnackBar('Đã khôi phục cài đặt mặc định');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Khôi phục', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmLogout() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đăng xuất'),
        content: const Text('Bạn có chắc chắn muốn đăng xuất?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              await SupabaseGoogleAuthService.signOut();
              if (mounted) {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/welcome',
                  (route) => false,
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Đăng xuất', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _confirmDeleteAccount() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xóa tài khoản'),
        content: const Text(
          'Bạn có chắc chắn muốn xóa tài khoản? Hành động này không thể hoàn tác và tất cả dữ liệu của bạn sẽ bị xóa vĩnh viễn.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _showSnackBar('Tính năng đang phát triển');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.error,
            ),
            child: const Text('Xóa tài khoản', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  void _showTermsOfService() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Điều khoản dịch vụ',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: const Text(
                    '''1. GIỚI THIỆU
Chào mừng bạn đến với FoodApp. Bằng việc sử dụng ứng dụng này, bạn đồng ý tuân thủ các điều khoản và điều kiện sau đây.

2. SỬ DỤNG DỊCH VỤ
- Bạn phải từ 18 tuổi trở lên để sử dụng dịch vụ này.
- Bạn có trách nhiệm duy trì bảo mật tài khoản của mình.
- Nghiêm cấm sử dụng dịch vụ cho mục đích bất hợp pháp.

3. ĐẶT HÀNG VÀ THANH TOÁN
- Giá cả có thể thay đổi mà không cần thông báo trước.
- Chúng tôi có quyền từ chối hoặc hủy đơn hàng nếu cần thiết.
- Thanh toán được xử lý an toàn qua các đối tác thanh toán của chúng tôi.

4. GIAO HÀNG
- Thời gian giao hàng chỉ mang tính chất ước tính.
- Chúng tôi không chịu trách nhiệm về việc giao hàng chậm do các yếu tố ngoài tầm kiểm soát.

5. HOÀN TRẢ VÀ HỦY ĐƠN
- Đơn hàng có thể được hủy trước khi nhà hàng bắt đầu chuẩn bị.
- Chính sách hoàn tiền áp dụng theo từng trường hợp cụ thể.

6. QUYỀN SỞ HỮU TRÍ TUỆ
Tất cả nội dung trong ứng dụng thuộc quyền sở hữu của FoodApp hoặc các đối tác được cấp phép.

7. GIỚI HẠN TRÁCH NHIỆM
FoodApp không chịu trách nhiệm về bất kỳ thiệt hại gián tiếp nào phát sinh từ việc sử dụng dịch vụ.

8. THAY ĐỔI ĐIỀU KHOẢN
Chúng tôi có quyền thay đổi điều khoản này bất cứ lúc nào. Việc tiếp tục sử dụng dịch vụ đồng nghĩa với việc bạn chấp nhận các thay đổi.

Cập nhật lần cuối: 01/12/2024''',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showPrivacyPolicy() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.9,
        minChildSize: 0.5,
        expand: false,
        builder: (context, scrollController) => Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'Chính sách bảo mật',
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: const Text(
                    '''1. THU THẬP THÔNG TIN
Chúng tôi thu thập các thông tin sau:
- Thông tin cá nhân: Tên, email, số điện thoại, địa chỉ
- Thông tin vị trí: Để cung cấp dịch vụ giao hàng
- Thông tin thiết bị: Loại thiết bị, hệ điều hành

2. SỬ DỤNG THÔNG TIN
Thông tin được sử dụng để:
- Xử lý và giao đơn hàng
- Cải thiện trải nghiệm người dùng
- Gửi thông báo về đơn hàng và khuyến mãi
- Hỗ trợ khách hàng

3. BẢO MẬT THÔNG TIN
- Chúng tôi sử dụng mã hóa SSL để bảo vệ dữ liệu
- Thông tin thanh toán được xử lý bởi đối tác thanh toán an toàn
- Nhân viên chỉ truy cập dữ liệu khi cần thiết

4. CHIA SẺ THÔNG TIN
Chúng tôi có thể chia sẻ thông tin với:
- Nhà hàng đối tác để xử lý đơn hàng
- Tài xế giao hàng
- Đối tác thanh toán
- Cơ quan chức năng khi được yêu cầu theo pháp luật

5. QUYỀN CỦA BẠN
Bạn có quyền:
- Truy cập và cập nhật thông tin cá nhân
- Yêu cầu xóa tài khoản
- Từ chối nhận email marketing
- Yêu cầu bản sao dữ liệu của bạn

6. COOKIE VÀ TRACKING
Chúng tôi sử dụng cookie để:
- Ghi nhớ đăng nhập
- Phân tích hành vi người dùng
- Cá nhân hóa trải nghiệm

7. THAY ĐỔI CHÍNH SÁCH
Chính sách này có thể được cập nhật. Chúng tôi sẽ thông báo về các thay đổi quan trọng.

8. LIÊN HỆ
Nếu có câu hỏi về chính sách bảo mật, vui lòng liên hệ:
- Email: privacy@foodapp.vn
- Hotline: 1900-xxxx

Cập nhật lần cuối: 01/12/2024''',
                    style: TextStyle(
                      fontSize: 14,
                      height: 1.6,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }
}
