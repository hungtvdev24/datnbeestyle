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
  bool _obscurePassword = true; // To toggle password visibility
  bool _obscureConfirmPassword = true; // To toggle confirm password visibility

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
      backgroundColor: Colors.white, // Đồng bộ màu nền trắng với LoginScreen
      body: SingleChildScrollView( // Cho phép cuộn khi nội dung dài
        child: Stack(
          children: [
            // PHẦN TRÊN (nền hồng, chứa hình minh hoạ)
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE4EC), // Màu hồng nhạt giống LoginScreen
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/login_header.png', // Giữ nguyên hình ảnh
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                    ),
                  ),
                ],
              ),
            ),
            // Close button at the top-left
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.black),
                onPressed: () {
                  Navigator.pop(context);
                },
              ),
            ),
            // PHẦN DƯỚI (Form đăng ký)
            Padding(
              padding: const EdgeInsets.only(top: 280), // Đẩy form xuống dưới banner
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title
                    const Text(
                      "Hãy bắt đầu nào!",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black, // Đồng bộ màu chữ đen
                        fontFamily: 'Roboto', // Đồng bộ font với LoginScreen
                      ),
                    ),
                    const SizedBox(height: 24),

                    Form(
                      key: _formKey,
                      child: Column(
                        children: [
                          // Trường nhập tên
                          _buildTextField(
                            nameController,
                            "Tên",
                            "Vui lòng nhập tên",
                          ),
                          const SizedBox(height: 16),
                          // Trường nhập email
                          _buildTextField(
                            emailController,
                            "Email",
                            "Vui lòng nhập địa chỉ Email",
                            isEmail: true,
                          ),
                          const SizedBox(height: 16),
                          // Trường nhập số điện thoại
                          _buildTextField(
                            phoneController,
                            "Số điện thoại",
                            "Vui lòng nhập số điện thoại",
                            isPhone: true,
                          ),
                          const SizedBox(height: 16),
                          // Trường nhập mật khẩu
                          _buildTextField(
                            passwordController,
                            "Mật khẩu",
                            "Vui lòng nhập mật khẩu",
                            isPassword: true,
                            obscureText: _obscurePassword,
                            onToggleVisibility: () {
                              setState(() {
                                _obscurePassword = !_obscurePassword;
                              });
                            },
                          ),
                          const SizedBox(height: 16),
                          // Trường xác nhận mật khẩu
                          _buildTextField(
                            confirmPasswordController,
                            "Xác nhận mật khẩu",
                            "Vui lòng xác nhận mật khẩu",
                            isPassword: true,
                            obscureText: _obscureConfirmPassword,
                            onToggleVisibility: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                            confirmPasswordOf: passwordController,
                          ),
                          const SizedBox(height: 24),

                          // Checkbox điều khoản
                          Row(
                            children: [
                              Checkbox(
                                value: agreePolicy,
                                onChanged: (val) {
                                  setState(() {
                                    agreePolicy = val ?? false;
                                  });
                                },
                              ),
                              Flexible(
                                child: Text.rich(
                                  TextSpan(
                                    text: "Tôi đồng ý với ",
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black, // Đồng bộ màu đen
                                      fontFamily: 'Roboto', // Đồng bộ font
                                    ),
                                    children: [
                                      TextSpan(
                                        text: "Điều khoản dịch vụ",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.pink, // Đồng bộ màu hồng cho liên kết
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                      const TextSpan(text: " & "),
                                      TextSpan(
                                        text: "chính sách bảo mật.",
                                        style: const TextStyle(
                                          fontSize: 14,
                                          color: Colors.pink, // Đồng bộ màu hồng cho liên kết
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Nút "Tiếp tục"
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.white, // Đồng bộ nền trắng
                                foregroundColor: Colors.black, // Đồng bộ màu chữ đen
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24), // Đồng bộ bo góc 24
                                  side: const BorderSide(color: Colors.black), // Đồng bộ viền đen
                                ),
                                elevation: 0,
                              ),
                              onPressed: isLoading ? null : _register,
                              child: isLoading
                                  ? const CircularProgressIndicator(
                                color: Colors.black, // Đồng bộ màu loading
                              )
                                  : const Text(
                                "Tiếp tục",
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black, // Đồng bộ màu chữ đen
                                  fontFamily: 'Roboto', // Đồng bộ font
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 24),

                          // Link chuyển sang màn đăng nhập
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "Bạn đã có tài khoản? ",
                                style: TextStyle(
                                  fontSize: 14,
                                  color: Colors.black, // Đồng bộ màu đen
                                  fontFamily: 'Roboto', // Đồng bộ font
                                ),
                              ),
                              GestureDetector(
                                onTap: () => Navigator.pushReplacementNamed(context, AppRoutes.login),
                                child: const Text(
                                  "Đăng nhập",
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.pink, // Đồng bộ màu hồng cho liên kết
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto', // Đồng bộ font
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
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

  /// Hàm tái sử dụng để tạo TextFormField
  Widget _buildTextField(
      TextEditingController controller,
      String hintText,
      String errorText, {
        bool isEmail = false,
        bool isPassword = false,
        bool isPhone = false, // Thêm flag cho số điện thoại
        bool obscureText = false,
        VoidCallback? onToggleVisibility,
        TextEditingController? confirmPasswordOf,
      }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText, // Ẩn text nếu là mật khẩu
      keyboardType: isEmail
          ? TextInputType.emailAddress
          : (isPhone ? TextInputType.phone : TextInputType.text), // Thêm kiểu bàn phím cho sdt
      decoration: InputDecoration(
        hintText: hintText,
        filled: true,
        fillColor: Colors.grey[100], // Đồng bộ màu nền xám nhạt
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8), // Đồng bộ bo góc 8
          borderSide: BorderSide.none, // Không viền
        ),
        suffixIcon: isPassword
            ? IconButton(
          icon: Icon(
            obscureText ? Icons.visibility_off : Icons.visibility,
            color: Colors.grey,
          ),
          onPressed: onToggleVisibility,
        )
            : null,
      ),
      style: const TextStyle(fontFamily: 'Roboto'), // Đồng bộ font
      validator: (value) {
        // Nếu chưa nhập thì chỉ validate khi là trường bắt buộc
        if (value == null || value.trim().isEmpty) {
          // Số điện thoại không bắt buộc, nên nếu để trống thì hợp lệ
          if (isPhone) return null;
          return errorText;
        }

        // Validation cho email
        if (isEmail) {
          final emailRegExp = RegExp(r'^[^@]+@gmail\.com$');
          if (!emailRegExp.hasMatch(value.trim())) {
            return "Email phải có định dạng @gmail.com";
          }
        }

        // Validation cho số điện thoại (nếu có nhập)
        if (isPhone && value.trim().isNotEmpty) {
          final phoneRegExp = RegExp(r'^0\d{9}$');
          if (!phoneRegExp.hasMatch(value.trim())) {
            return "Số điện thoại phải bắt đầu bằng 0 và có đúng 10 số";
          }
        }

        // Validation cho mật khẩu
        if (isPassword && value.length < 6) {
          return "Mật khẩu tối thiểu 6 ký tự";
        }

        // Validation cho xác nhận mật khẩu
        if (confirmPasswordOf != null) {
          if (value.trim() != confirmPasswordOf.text.trim()) {
            return "Mật khẩu không khớp";
          }
        }

        return null;
      },
    );
  }
}