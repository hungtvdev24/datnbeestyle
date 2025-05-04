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

    if (userProvider.token == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        Navigator.pushReplacementNamed(context, '/login');
      });
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Chỉnh sửa thông tin",
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.black,
            fontFamily: 'Roboto',
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
      ),
      body: userProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.black))
          : SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "Cập nhật thông tin cá nhân",
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                "Vui lòng nhập thông tin mới để cập nhật hồ sơ của bạn.",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'Roboto',
                ),
              ),
              const SizedBox(height: 30),
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
              _buildReadOnlyField(
                label: 'Email',
                value: user?['email'] ?? 'Không có email',
                icon: Icons.email,
              ),
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
              _buildTextField(
                label: 'Tuổi',
                initialValue: user?['tuoi']?.toString(),
                icon: Icons.cake,
                keyboardType: TextInputType.number,
                onSaved: (value) => tuoi = int.tryParse(value ?? ''),
              ),
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
              Center(
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: Colors.black,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(24),
                      side: const BorderSide(color: Colors.black),
                    ),
                    elevation: 0,
                  ),
                  onPressed: () async {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      final updatedData = <String, dynamic>{};

                      if (name != null && name != user?['name']) updatedData['name'] = name;
                      if (phone != null && phone != user?['phone']) updatedData['phone'] = phone;
                      if (tuoi != null && tuoi != user?['tuoi']) updatedData['tuoi'] = tuoi;

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
                        bool? confirm = await _showConfirmationDialog(context);
                        if (confirm == true) {
                          try {
                            await userProvider.updateUser(updatedData);

                            if (userProvider.errorMessage != null) {
                              if (userProvider.errorMessage!.containsKey('old_password')) {
                                return;
                              } else {
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

                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Cập nhật thông tin thành công'),
                                backgroundColor: Colors.green,
                              ),
                            );

                            _oldPasswordController.clear();
                            _newPasswordController.clear();
                            _confirmPasswordController.clear();

                            Navigator.pop(context);
                          } catch (e) {
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
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'Roboto',
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
          hintText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: Colors.pink),
          suffixIcon: suffixIcon,
          errorText: errorText,
        ),
        style: const TextStyle(fontFamily: 'Roboto'),
        onSaved: onSaved,
        validator: validator,
      ),
    );
  }

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
          hintText: label,
          filled: true,
          fillColor: Colors.grey[200],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
          prefixIcon: Icon(icon, color: Colors.pink),
        ),
        style: const TextStyle(fontFamily: 'Roboto'),
      ),
    );
  }

  Future<bool?> _showConfirmationDialog(BuildContext context) {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Text(
          "Xác nhận cập nhật",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Colors.black87,
            fontFamily: 'Roboto',
          ),
        ),
        content: const Text(
          "Bạn có chắc chắn muốn cập nhật thông tin này không?",
          style: TextStyle(color: Colors.black54, fontFamily: 'Roboto'),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text(
              "Hủy",
              style: TextStyle(color: Colors.grey, fontFamily: 'Roboto'),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(24),
                side: const BorderSide(color: Colors.black),
              ),
              elevation: 0,
            ),
            onPressed: () => Navigator.pop(context, true),
            child: const Text(
              "Xác nhận",
              style: TextStyle(
                color: Colors.black,
                fontFamily: 'Roboto',
              ),
            ),
          ),
        ],
      ),
    );
  }
}