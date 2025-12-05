import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../config/app_theme.dart';
import '../../services/auth_service.dart';
import '../../services/supabase_google_auth_service.dart';

class ProfileScreen extends StatefulWidget {
  final int userId;
  final String? initialName;
  final String? initialEmail;
  final String? initialPhone;
  final String? initialAvatar;
  
  const ProfileScreen({
    super.key,
    required this.userId,
    this.initialName,
    this.initialEmail,
    this.initialPhone,
    this.initialAvatar,
  });

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _emailController;
  late TextEditingController _phoneController;
  
  bool _isLoading = false;
  bool _isEditing = false;
  String? _avatarUrl;
  
  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.initialName ?? '');
    _emailController = TextEditingController(text: widget.initialEmail ?? '');
    _phoneController = TextEditingController(text: widget.initialPhone ?? '');
    _avatarUrl = widget.initialAvatar;
    _loadProfile();
  }
  
  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }
  
  Future<void> _loadProfile() async {
    setState(() => _isLoading = true);
    try {
      // Lấy user từ Supabase Auth thay vì backend
      final user = Supabase.instance.client.auth.currentUser;
      if (user != null) {
        setState(() {
          _nameController.text = user.userMetadata?['full_name'] ?? 
                                 user.userMetadata?['name'] ?? 
                                 widget.initialName ?? '';
          _emailController.text = user.email ?? widget.initialEmail ?? '';
          _phoneController.text = user.phone ?? widget.initialPhone ?? '';
          _avatarUrl = user.userMetadata?['avatar_url'] ?? 
                       user.userMetadata?['picture'] ?? 
                       widget.initialAvatar;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Không thể tải thông tin: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  Future<void> _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isLoading = true);
    try {
      // Cập nhật user metadata trong Supabase
      await Supabase.instance.client.auth.updateUser(
        UserAttributes(
          data: {
            'full_name': _nameController.text.trim(),
            'phone': _phoneController.text.trim(),
            'avatar_url': _avatarUrl,
          },
        ),
      );
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Cập nhật thành công!'),
            backgroundColor: AppColors.success,
          ),
        );
        setState(() => _isEditing = false);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }
  
  void _showChangePasswordDialog() {
    final currentPasswordController = TextEditingController();
    final newPasswordController = TextEditingController();
    final confirmPasswordController = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Đổi mật khẩu'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: currentPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu hiện tại',
                prefixIcon: Icon(Icons.lock_outline),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: newPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: confirmPasswordController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Xác nhận mật khẩu mới',
                prefixIcon: Icon(Icons.lock),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          ElevatedButton(
            onPressed: () async {
              if (newPasswordController.text != confirmPasswordController.text) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Mật khẩu xác nhận không khớp'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              
              try {
                // Supabase không cần mật khẩu hiện tại để đổi mật khẩu
                await Supabase.instance.client.auth.updateUser(
                  UserAttributes(password: newPasswordController.text),
                );
                
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Đổi mật khẩu thành công!'),
                    backgroundColor: AppColors.success,
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Lỗi: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryColor,
            ),
            child: const Text('Xác nhận', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
  
  void _logout() {
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Tài khoản',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          if (!_isEditing)
            IconButton(
              icon: const Icon(Icons.edit, color: AppColors.primaryColor),
              onPressed: () => setState(() => _isEditing = true),
            )
          else
            IconButton(
              icon: const Icon(Icons.close, color: AppColors.textSecondary),
              onPressed: () => setState(() => _isEditing = false),
            ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Form(
                key: _formKey,
                child: Column(
                  children: [
                    // Avatar
                    _buildAvatar(),
                    const SizedBox(height: 30),
                    
                    // Form fields
                    _buildTextField(
                      controller: _nameController,
                      label: 'Họ tên',
                      icon: Icons.person_outline,
                      enabled: _isEditing,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Vui lòng nhập họ tên';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _emailController,
                      label: 'Email',
                      icon: Icons.email_outlined,
                      enabled: false, // Email không cho sửa
                      keyboardType: TextInputType.emailAddress,
                    ),
                    const SizedBox(height: 16),
                    
                    _buildTextField(
                      controller: _phoneController,
                      label: 'Số điện thoại',
                      icon: Icons.phone_outlined,
                      enabled: _isEditing,
                      keyboardType: TextInputType.phone,
                    ),
                    const SizedBox(height: 30),
                    
                    // Save button
                    if (_isEditing)
                      SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _isLoading ? null : _saveProfile,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryColor,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(28),
                            ),
                          ),
                          child: const Text(
                            'LƯU THAY ĐỔI',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    
                    const SizedBox(height: 20),
                    const Divider(),
                    const SizedBox(height: 10),
                    
                    // Menu items
                    _buildMenuItem(
                      icon: Icons.lock_outline,
                      title: 'Đổi mật khẩu',
                      onTap: _showChangePasswordDialog,
                    ),
                    _buildMenuItem(
                      icon: Icons.location_on_outlined,
                      title: 'Địa chỉ giao hàng',
                      onTap: () {
                        Navigator.pushNamed(context, '/addresses');
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.receipt_long_outlined,
                      title: 'Lịch sử đơn hàng',
                      onTap: () {
                        Navigator.pushNamed(context, '/order-history');
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.favorite_border,
                      title: 'Yêu thích',
                      onTap: () {
                        Navigator.pushNamed(context, '/favorites');
                      },
                    ),
                    _buildMenuItem(
                      icon: Icons.settings_outlined,
                      title: 'Cài đặt',
                      onTap: () {
                        // Navigate to settings
                      },
                    ),
                    const Divider(),
                    _buildMenuItem(
                      icon: Icons.logout,
                      title: 'Đăng xuất',
                      textColor: AppColors.error,
                      onTap: _logout,
                    ),
                  ],
                ),
              ),
            ),
    );
  }
  
  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.inputBorder,
          ),
          child: ClipOval(
            child: _avatarUrl != null && _avatarUrl!.isNotEmpty
                ? Image.network(
                    _avatarUrl!,
                    width: 120,
                    height: 120,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.person, size: 60, color: AppColors.subColor);
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const Center(
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.primaryColor,
                        ),
                      );
                    },
                  )
                : const Icon(Icons.person, size: 60, color: AppColors.subColor),
          ),
        ),
        if (_isEditing)
          Positioned(
            bottom: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: const BoxDecoration(
                color: AppColors.primaryColor,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
      ],
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    bool enabled = true,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      enabled: enabled,
      keyboardType: keyboardType,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: AppColors.subColor),
        filled: true,
        fillColor: enabled ? Colors.white : AppColors.background,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: AppColors.inputBorder),
        ),
      ),
    );
  }
  
  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppColors.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          color: textColor ?? AppColors.textPrimary,
          fontSize: 16,
        ),
      ),
      trailing: Icon(
        Icons.arrow_forward_ios,
        size: 16,
        color: textColor ?? AppColors.subColor,
      ),
      onTap: onTap,
    );
  }
}
