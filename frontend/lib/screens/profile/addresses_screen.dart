import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../config/app_theme.dart';

class AddressesScreen extends StatefulWidget {
  const AddressesScreen({super.key});

  @override
  State<AddressesScreen> createState() => _AddressesScreenState();
}

class _AddressesScreenState extends State<AddressesScreen> {
  List<Map<String, dynamic>> _addresses = [];
  bool _isLoading = true;
  
  @override
  void initState() {
    super.initState();
    _loadAddresses();
  }
  
  Future<void> _loadAddresses() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final addressesJson = prefs.getString('delivery_addresses');
      if (addressesJson != null) {
        final List<dynamic> decoded = jsonDecode(addressesJson);
        _addresses = decoded.cast<Map<String, dynamic>>();
      }
    } catch (e) {
      debugPrint('Error loading addresses: $e');
    }
    setState(() => _isLoading = false);
  }
  
  Future<void> _saveAddresses() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('delivery_addresses', jsonEncode(_addresses));
  }
  
  void _showAddEditDialog({Map<String, dynamic>? address, int? index}) {
    final isEdit = address != null;
    final nameController = TextEditingController(text: address?['name'] ?? '');
    final phoneController = TextEditingController(text: address?['phone'] ?? '');
    final addressController = TextEditingController(text: address?['address'] ?? '');
    final noteController = TextEditingController(text: address?['note'] ?? '');
    String selectedType = address?['type'] ?? 'home';
    bool isDefault = address?['isDefault'] ?? false;
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => StatefulBuilder(
        builder: (context, setModalState) => Container(
          height: MediaQuery.of(context).size.height * 0.85,
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
                      isEdit ? 'Sửa địa chỉ' : 'Thêm địa chỉ mới',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(width: 48),
                  ],
                ),
              ),
              
              // Form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Address Type
                      const Text(
                        'Loại địa chỉ',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 14,
                        ),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          _buildTypeChip(
                            'Nhà riêng',
                            'home',
                            Icons.home_outlined,
                            selectedType,
                            (type) => setModalState(() => selectedType = type),
                          ),
                          const SizedBox(width: 10),
                          _buildTypeChip(
                            'Văn phòng',
                            'office',
                            Icons.business_outlined,
                            selectedType,
                            (type) => setModalState(() => selectedType = type),
                          ),
                          const SizedBox(width: 10),
                          _buildTypeChip(
                            'Khác',
                            'other',
                            Icons.location_on_outlined,
                            selectedType,
                            (type) => setModalState(() => selectedType = type),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // Name
                      _buildTextField(
                        controller: nameController,
                        label: 'Họ và tên người nhận',
                        hint: 'Nhập họ và tên',
                        icon: Icons.person_outline,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Phone
                      _buildTextField(
                        controller: phoneController,
                        label: 'Số điện thoại',
                        hint: 'Nhập số điện thoại',
                        icon: Icons.phone_outlined,
                        keyboardType: TextInputType.phone,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Address
                      _buildTextField(
                        controller: addressController,
                        label: 'Địa chỉ chi tiết',
                        hint: 'Số nhà, tên đường, phường/xã, quận/huyện, tỉnh/thành phố',
                        icon: Icons.location_on_outlined,
                        maxLines: 3,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Note
                      _buildTextField(
                        controller: noteController,
                        label: 'Ghi chú (tùy chọn)',
                        hint: 'VD: Giao tại cổng, gọi trước 10 phút...',
                        icon: Icons.note_outlined,
                        maxLines: 2,
                      ),
                      
                      const SizedBox(height: 16),
                      
                      // Default checkbox
                      CheckboxListTile(
                        value: isDefault,
                        onChanged: (value) => setModalState(() => isDefault = value ?? false),
                        title: const Text('Đặt làm địa chỉ mặc định'),
                        controlAffinity: ListTileControlAffinity.leading,
                        contentPadding: EdgeInsets.zero,
                        activeColor: AppColors.primaryColor,
                      ),
                    ],
                  ),
                ),
              ),
              
              // Save Button
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, -5),
                    ),
                  ],
                ),
                child: SafeArea(
                  child: SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isEmpty || 
                            phoneController.text.isEmpty || 
                            addressController.text.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Vui lòng điền đầy đủ thông tin'),
                              backgroundColor: AppColors.error,
                            ),
                          );
                          return;
                        }
                        
                        final newAddress = {
                          'id': isEdit ? address!['id'] : DateTime.now().millisecondsSinceEpoch,
                          'name': nameController.text.trim(),
                          'phone': phoneController.text.trim(),
                          'address': addressController.text.trim(),
                          'note': noteController.text.trim(),
                          'type': selectedType,
                          'isDefault': isDefault,
                        };
                        
                        setState(() {
                          if (isDefault) {
                            // Remove default from other addresses
                            for (var addr in _addresses) {
                              addr['isDefault'] = false;
                            }
                          }
                          
                          if (isEdit && index != null) {
                            _addresses[index] = newAddress;
                          } else {
                            _addresses.add(newAddress);
                          }
                        });
                        
                        _saveAddresses();
                        Navigator.pop(context);
                        
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(isEdit ? 'Đã cập nhật địa chỉ' : 'Đã thêm địa chỉ mới'),
                            backgroundColor: AppColors.success,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: Text(
                        isEdit ? 'Cập nhật' : 'Thêm địa chỉ',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
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
  
  Widget _buildTypeChip(String label, String value, IconData icon, String selected, Function(String) onTap) {
    final isSelected = selected == value;
    return GestureDetector(
      onTap: () => onTap(value),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryColor.withOpacity(0.1) : Colors.grey.shade100,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppColors.primaryColor : Colors.grey.shade300,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, size: 18, color: isSelected ? AppColors.primaryColor : Colors.grey),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AppColors.primaryColor : Colors.grey.shade700,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    int maxLines = 1,
    TextInputType? keyboardType,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          maxLines: maxLines,
          keyboardType: keyboardType,
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: TextStyle(color: Colors.grey.shade400),
            prefixIcon: Icon(icon, color: AppColors.subColor),
            filled: true,
            fillColor: Colors.grey.shade50,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade200),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.primaryColor),
            ),
          ),
        ),
      ],
    );
  }
  
  void _deleteAddress(int index) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Xác nhận xóa'),
        content: const Text('Bạn có chắc muốn xóa địa chỉ này?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              setState(() => _addresses.removeAt(index));
              _saveAddresses();
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Đã xóa địa chỉ'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Xóa', style: TextStyle(color: AppColors.error)),
          ),
        ],
      ),
    );
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
          'Địa chỉ giao hàng',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppColors.primaryColor))
          : _addresses.isEmpty
              ? _buildEmptyState()
              : _buildAddressList(),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditDialog(),
        backgroundColor: AppColors.primaryColor,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('Thêm địa chỉ', style: TextStyle(color: Colors.white)),
      ),
    );
  }
  
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.location_off_outlined, size: 80, color: Colors.grey.shade300),
          const SizedBox(height: 16),
          Text(
            'Chưa có địa chỉ nào',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Thêm địa chỉ giao hàng để đặt món nhanh hơn',
            style: TextStyle(color: Colors.grey.shade500),
          ),
        ],
      ),
    );
  }
  
  Widget _buildAddressList() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: _addresses.length,
      itemBuilder: (context, index) {
        final address = _addresses[index];
        return _buildAddressCard(address, index);
      },
    );
  }
  
  Widget _buildAddressCard(Map<String, dynamic> address, int index) {
    final type = address['type'] ?? 'home';
    final typeIcon = type == 'home' 
        ? Icons.home_outlined 
        : type == 'office' 
            ? Icons.business_outlined 
            : Icons.location_on_outlined;
    final typeLabel = type == 'home' 
        ? 'Nhà riêng' 
        : type == 'office' 
            ? 'Văn phòng' 
            : 'Khác';
    
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
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
          ListTile(
            contentPadding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
            leading: Container(
              width: 45,
              height: 45,
              decoration: BoxDecoration(
                color: AppColors.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(typeIcon, color: AppColors.primaryColor),
            ),
            title: Row(
              children: [
                Text(
                  address['name'] ?? '',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    typeLabel,
                    style: TextStyle(
                      fontSize: 11,
                      color: Colors.grey.shade600,
                    ),
                  ),
                ),
                if (address['isDefault'] == true) ...[
                  const SizedBox(width: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primaryColor.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Text(
                      'Mặc định',
                      style: TextStyle(
                        fontSize: 11,
                        color: AppColors.primaryColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ],
            ),
            subtitle: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 4),
                Text(
                  address['phone'] ?? '',
                  style: TextStyle(color: Colors.grey.shade600),
                ),
                const SizedBox(height: 4),
                Text(
                  address['address'] ?? '',
                  style: TextStyle(color: Colors.grey.shade600),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (address['note']?.isNotEmpty == true) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Ghi chú: ${address['note']}',
                    style: TextStyle(
                      color: Colors.grey.shade500,
                      fontStyle: FontStyle.italic,
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const Divider(height: 1),
          Row(
            children: [
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _showAddEditDialog(address: address, index: index),
                  icon: const Icon(Icons.edit_outlined, size: 18),
                  label: const Text('Sửa'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.primaryColor),
                ),
              ),
              Container(width: 1, height: 30, color: Colors.grey.shade200),
              Expanded(
                child: TextButton.icon(
                  onPressed: () => _deleteAddress(index),
                  icon: const Icon(Icons.delete_outline, size: 18),
                  label: const Text('Xóa'),
                  style: TextButton.styleFrom(foregroundColor: AppColors.error),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
