import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../routes.dart';

// Màn hình đăng ký, một StatefulWidget để quản lý trạng thái
class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  // Các controller để lấy dữ liệu từ TextFormField
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();

  // Key để validate toàn bộ form
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false; // Trạng thái loading khi gửi request đăng ký
  bool agreePolicy = false; // Trạng thái checkbox "đồng ý điều khoản"

  // Hàm xử lý logic đăng ký
  void _register() async {
    // 1. Kiểm tra form hợp lệ
    if (!_formKey.currentState!.validate()) return;

    // 2. Kiểm tra checkbox điều khoản
    if (!agreePolicy) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Bạn cần đồng ý với điều khoản để tiếp tục.")),
      );
      return;
    }

    // 3. Bật trạng thái loading
    setState(() {
      isLoading = true;
    });

    // 4. Gọi AuthProvider để gửi request đăng ký
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    bool success = await authProvider.register(
      nameController.text.trim(),
      emailController.text.trim(),
      phoneController.text.trim(),
      passwordController.text.trim(),
    );

    // 5. Tắt trạng thái loading
    setState(() {
      isLoading = false;
    });

    // 6. Xử lý kết quả đăng ký
    if (success) {
      // Thành công: Hiển thị thông báo và chuyển sang màn login sau 2 giây
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Đăng ký thành công! Đang chuyển đến trang đăng nhập...")),
      );
      Future.delayed(const Duration(seconds: 2), () {
        Navigator.pushReplacementNamed(
          context,
          AppRoutes.login,
          arguments: {
            "email": emailController.text.trim(),
            "password": passwordController.text.trim(),
          },
        );
      });
    } else {
      // Thất bại: Hiển thị thông báo lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(authProvider.errorMessage ?? "Lỗi đăng ký")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200], // Màu nền tổng thể: xám nhạt
      body: SafeArea(
        child: SingleChildScrollView( // Cho phép cuộn khi nội dung dài
          child: Column(
            children: [
              // 1. Ảnh header
              const SizedBox(height: 16),
              Center(
                child: Image.asset(
                  'assets/login_header.png',
                  height: 180,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const Icon(Icons.error), // Hiển thị lỗi nếu không tải được ảnh
                ),
              ),
              const SizedBox(height: 24),

              // 2. Tiêu đề
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Hãy bắt đầu nào!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // 3. Mô tả ngắn
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    "Vui lòng nhập thông tin hợp lệ để tạo tài khoản.",
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.grey[700],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              // 4. Form đăng ký (Container trắng chứa các trường nhập liệu)
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white, // Nền trắng nổi bật trên nền xám
                  borderRadius: BorderRadius.circular(16), // Bo góc
                ),
                child: Form(
                  key: _formKey, // Gắn key để validate form
                  child: Column(
                    children: [
                      // Trường nhập tên
                      _buildTextField(
                        nameController,
                        "Tên",
                        Icons.person,
                        "Vui lòng nhập tên",
                      ),
                      // Trường nhập email
                      _buildTextField(
                        emailController,
                        "Địa chỉ Email",
                        Icons.email,
                        "Vui lòng nhập email",
                        isEmail: true,
                      ),
                      // Trường nhập số điện thoại
                      _buildTextField(
                        phoneController,
                        "Số điện thoại",
                        Icons.phone,
                        "Vui lòng nhập số điện thoại",
                      ),
                      // Trường nhập mật khẩu
                      _buildTextField(
                        passwordController,
                        "Mật khẩu",
                        Icons.lock,
                        "Vui lòng nhập mật khẩu",
                        isPassword: true,
                      ),
                      // Trường xác nhận mật khẩu
                      _buildTextField(
                        confirmPasswordController,
                        "Xác nhận mật khẩu",
                        Icons.lock,
                        "Vui lòng xác nhận mật khẩu",
                        isPassword: true,
                        confirmPasswordOf: passwordController,
                      ),
                      const SizedBox(height: 12),

                      // 5. Checkbox điều khoản
                      Row(
                        children: [
                          Checkbox(
                            value: agreePolicy,
                            onChanged: (val) {
                              setState(() {
                                agreePolicy = val ?? false; // Cập nhật trạng thái checkbox
                              });
                            },
                          ),
                          Flexible(
                            child: Text.rich(
                              TextSpan(
                                text: "Tôi đồng ý với ",
                                style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                                children: [
                                  TextSpan(
                                    text: "Điều khoản dịch vụ",
                                    style: TextStyle(fontSize: 14, color: Colors.blue), // Chưa có sự kiện nhấp vào
                                  ),
                                  const TextSpan(text: " & "),
                                  TextSpan(
                                    text: "chính sách bảo mật.",
                                    style: TextStyle(fontSize: 14, color: Colors.blue), // Chưa có sự kiện nhấp vào
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // 6. Nút "Tiếp tục"
                      isLoading
                          ? const CircularProgressIndicator() // Hiển thị loading khi đang xử lý
                          : SizedBox(
                        width: double.infinity,
                        height: 50,
                        child: ElevatedButton(
                          onPressed: _register, // Gọi hàm đăng ký khi nhấn
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.lightBlue, // Màu xanh nhạt
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          child: const Text(
                            "Tiếp tục",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),

                      // 7. Link chuyển sang màn đăng nhập
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            "Bạn đã có tài khoản? ",
                            style: TextStyle(fontSize: 14, color: Colors.grey),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login), // Chuyển sang màn login
                            child: const Text(
                              "Đăng nhập",
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.lightBlue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          )
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  /// Hàm tái sử dụng để tạo TextFormField
  Widget _buildTextField(
      TextEditingController controller,
      String label,
      IconData icon,
      String errorText, {
        bool isEmail = false,
        bool isPassword = false,
        TextEditingController? confirmPasswordOf,
      }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextFormField(
        controller: controller,
        obscureText: isPassword, // Ẩn text nếu là mật khẩu
        keyboardType: isEmail ? TextInputType.emailAddress : TextInputType.text, // Bàn phím phù hợp
        decoration: InputDecoration(
          hintText: label,
          prefixIcon: Icon(icon, color: Colors.grey[700]),
          filled: true,
          fillColor: Colors.grey[100], // Nền xám nhạt cho trường nhập
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none, // Không viền
          ),
        ),
        validator: (value) { // Logic validate cho từng trường
          if (value == null || value.trim().isEmpty) {
            return errorText;
          }
          if (isEmail) {
            final emailRegExp = RegExp(r'^[^@]+@[^@]+\.[^@]+');
            if (!emailRegExp.hasMatch(value.trim())) {
              return "Email không hợp lệ";
            }
          }
          if (isPassword && value.length < 6) {
            return "Mật khẩu tối thiểu 6 ký tự";
          }
          if (confirmPasswordOf != null) {
            if (value.trim() != confirmPasswordOf.text.trim()) {
              return "Mật khẩu không khớp";
            }
          }
          return null;
        },
      ),
    );
  }
}