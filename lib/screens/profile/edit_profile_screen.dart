import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../providers/user_provider.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  String? name;
  String? phone;
  int? tuoi;
  String? oldPassword;
  String? newPassword;
  String? confirmNewPassword;
  bool _isOldPasswordVisible = false;
  bool _isNewPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  // Controllers để quản lý các trường nhập liệu
  final TextEditingController _oldPasswordController = TextEditingController();
  final TextEditingController _newPasswordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  @override
  void dispose() {
    _oldPasswordController.dispose();
    _newPasswordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final userProvider = Provider.of<UserProvider>(context);
    final user = userProvider.userData;

    // Kiểm tra nếu người dùng chưa đăng nhập
    if (userProvider.token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa thông tin",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        backgroundColor: Colors.blueAccent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blueAccent))
          : Container(
        color: Colors.grey[100],
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 30),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Tiêu đề
                const Text(
                  "Cập nhật thông tin cá nhân",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  "Vui lòng nhập thông tin mới để cập nhật hồ sơ của bạn.",
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 30),

                // Tên
                _buildTextField(
                  label: 'Tên',
                  initialValue: user?['name'],
                  icon: Icons.person,
                  onSaved: (value) => name = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập tên';
                    }
                    return null;
                  },
                ),

                // Email (chỉ hiển thị, không cho chỉnh sửa)
                _buildReadOnlyField(
                  label: 'Email',
                  value: user?['email'] ?? 'Không có email',
                  icon: Icons.email,
                ),

                // Số điện thoại
                _buildTextField(
                  label: 'Số điện thoại',
                  initialValue: user?['phone'],
                  icon: Icons.phone,
                  onSaved: (value) => phone = value,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Vui lòng nhập số điện thoại';
                    }
                    return null;
                  },
                ),

                // Tuổi
                _buildTextField(
                  label: 'Tuổi',
                  initialValue: user?['tuoi']?.toString(),
                  icon: Icons.cake,
                  keyboardType: TextInputType.number,
                  onSaved: (value) => tuoi = int.tryParse(value ?? ''),
                ),

                // Mật khẩu cũ
                _buildTextField(
                  label: 'Mật khẩu cũ (nếu muốn thay đổi mật khẩu)',
                  controller: _oldPasswordController,
                  icon: Icons.lock_outline,
                  obscureText: !_isOldPasswordVisible,
                  onSaved: (value) => oldPassword = value,
                  errorText: userProvider.errorMessage != null &&
                      userProvider.errorMessage!.containsKey('old_password')
                      ? userProvider.errorMessage!['old_password']
                      : null,
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isOldPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isOldPasswordVisible = !_isOldPasswordVisible;
                      });
                    },
                  ),
                ),

                // Mật khẩu mới
                _buildTextField(
                  label: 'Mật khẩu mới',
                  controller: _newPasswordController,
                  icon: Icons.lock,
                  obscureText: !_isNewPasswordVisible,
                  onSaved: (value) => newPassword = value,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 6) {
                      return 'Mật khẩu mới phải có ít nhất 6 ký tự';
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isNewPasswordVisible = !_isNewPasswordVisible;
                      });
                    },
                  ),
                ),

                // Xác nhận mật khẩu mới
                _buildTextField(
                  label: 'Xác nhận mật khẩu mới',
                  controller: _confirmPasswordController,
                  icon: Icons.lock,
                  obscureText: !_isConfirmPasswordVisible,
                  onSaved: (value) => confirmNewPassword = value,
                  validator: (value) {
                    if (newPassword != null && newPassword!.isNotEmpty) {
                      if (value == null || value.isEmpty) {
                        return 'Vui lòng xác nhận mật khẩu mới';
                      }
                      if (value != newPassword) {
                        return 'Mật khẩu xác nhận không khớp';
                      }
                    }
                    return null;
                  },
                  suffixIcon: IconButton(
                    icon: Icon(
                      _isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off,
                      color: Colors.grey,
                    ),
                    onPressed: () {
                      setState(() {
                        _isConfirmPasswordVisible = !_isConfirmPasswordVisible;
                      });
                    },
                  ),
                ),

                const SizedBox(height: 30),

                // Nút cập nhật
                Center(
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blueAccent,
                      minimumSize: const Size(double.infinity, 56),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 5,
                    ),
                    onPressed: () async {
                      if (_formKey.currentState!.validate()) {
                        _formKey.currentState!.save();
                        final updatedData = <String, dynamic>{};

                        // Thêm các trường cần cập nhật
                        if (name != null && name != user?['name']) updatedData['name'] = name;
                        if (phone != null && phone != user?['phone']) updatedData['phone'] = phone;
                        if (tuoi != null && tuoi != user?['tuoi']) updatedData['tuoi'] = tuoi;

                        // Xử lý mật khẩu
                        if (newPassword != null && newPassword!.isNotEmpty) {
                          if (oldPassword == null || oldPassword!.isEmpty) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Vui lòng nhập mật khẩu cũ để thay đổi mật khẩu'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }
                          updatedData['old_password'] = oldPassword;
                          updatedData['password'] = newPassword;
                        }

                        if (updatedData.isNotEmpty) {
                          // Hiển thị dialog xác nhận
                          bool? confirm = await _showConfirmationDialog(context);
                          if (confirm == true) {
                            try {
                              // Gọi API cập nhật
                              await userProvider.updateUser(updatedData);

                              // Kiểm tra lỗi từ backend
                              if (userProvider.errorMessage != null) {
                                // Nếu có lỗi, hiển thị thông báo lỗi và không thoát màn hình
                                if (userProvider.errorMessage!.containsKey('old_password')) {
                                  // Lỗi mật khẩu cũ không đúng đã được hiển thị trực tiếp trên trường nhập
                                  return;
                                } else {
                                  // Hiển thị các lỗi khác (nếu có)
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        userProvider.errorMessage!['general']?.toString() ??
                                            'Có lỗi xảy ra khi cập nhật thông tin',
                                      ),
                                      backgroundColor: Colors.red,
                                    ),
                                  );
                                  return;
                                }
                              }

                              // Nếu không có lỗi, hiển thị thông báo thành công
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text('Cập nhật thông tin thành công'),
                                  backgroundColor: Colors.green,
                                ),
                              );

                              // Xóa các trường mật khẩu sau khi cập nhật thành công
                              _oldPasswordController.clear();
                              _newPasswordController.clear();
                              _confirmPasswordController.clear();

                              // Thoát màn hình sau khi cập nhật thành công
                              Navigator.pop(context);
                            } catch (e) {
                              // Hiển thị lỗi nếu có ngoại lệ xảy ra
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Lỗi: $e'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          }
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Không có thay đổi để cập nhật'),
                              backgroundColor: Colors.orange,
                            ),
                          );
                        }
                      }
                    },
                    child: const Text(
                      "Cập nhật",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget để tạo TextField với thiết kế đẹp
  Widget _buildTextField({
    required String label,
    String? initialValue,
    TextEditingController? controller,
    required IconData icon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required FormFieldSetter<String> onSaved,
    FormFieldValidator<String>? validator,
    Widget? suffixIcon,
    String? errorText,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        controller: controller,
        initialValue: controller == null ? initialValue : null,
        obscureText: obscureText,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          suffixIcon: suffixIcon,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.blueAccent, width: 2),
          ),
          errorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 1),
          ),
          focusedErrorBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.red, width: 2),
          ),
          errorText: errorText,
          filled: true,
          fillColor: Colors.white,
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

  // Widget để tạo trường chỉ hiển thị (không cho chỉnh sửa)
  Widget _buildReadOnlyField({
    required String label,
    required String value,
    required IconData icon,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: value,
        readOnly: true,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(
            color: Colors.black54,
            fontSize: 16,
          ),
          prefixIcon: Icon(icon, color: Colors.blueAccent),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Colors.grey, width: 1),
          ),
          filled: true,
          fillColor: Colors.grey[200], // Màu nền nhạt để biểu thị không thể chỉnh sửa
          contentPadding: const EdgeInsets.symmetric(vertical: 16, horizontal: 16),
        ),
      ),
    );
  }

  // Dialog xác nhận
  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Xác nhận cập nhật",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black87),
        ),
        content: const Text(
          "Bạn có chắc chắn muốn cập nhật thông tin này không?",
          style: TextStyle(color: Colors.black54),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Hủy",
              style: TextStyle(color: Colors.grey),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.blueAccent,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Xác nhận",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}