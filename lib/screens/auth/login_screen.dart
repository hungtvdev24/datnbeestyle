
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/user_provider.dart';
import '../../routes.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool isLoading = false;
  String? errorMessage;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args =
    ModalRoute.of(context)?.settings.arguments as Map<String, String>?;
    if (args != null) {
      emailController.text = args["email"] ?? "";
      passwordController.text = args["password"] ?? "";
      print('Pre-filled login: email=${args["email"]}, password=${args["password"]}');
    }
  }

  void _login() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    print(
        'Login attempt: email=${emailController.text.trim()}, password=${passwordController.text.trim()}');
    bool success = await authProvider.login(
      emailController.text.trim(),
      passwordController.text.trim(),
    );

    setState(() {
      isLoading = false;
      errorMessage = authProvider.errorMessage;
    });

    print(
        'Login result: success=$success, error=$errorMessage, token=${authProvider.token}');
    if (success) {
      try {
        final userProvider = Provider.of<UserProvider>(context, listen: false);
        await userProvider.setToken(authProvider.token!);
        print('Token saved to UserProvider: ${userProvider.token}');
        Navigator.pushReplacementNamed(context, AppRoutes.home);
      } catch (e) {
        print('Error saving token to UserProvider: $e');
        setState(() {
          errorMessage = 'Lỗi khi lưu token: $e';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Nền trắng chung
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            // PHẦN TRÊN (nền hồng, chứa hình minh hoạ)
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                // Màu hồng nhạt, bạn có thể đổi tuỳ ý
                color: Color(0xFFFCE4EC),
                // Bo cong phần đáy cho đẹp
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(40),
                  bottomRight: Radius.circular(40),
                ),
              ),
              child: Stack(
                children: [
                  // Ảnh minh hoạ chính
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Image.asset(
                      'assets/login_header.png', // Đổi thành ảnh của bạn
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                    ),
                  ),
                  // Có thể thêm các hình doodle, icon trang trí nếu muốn
                ],
              ),
            ),

            // PHẦN DƯỚI (Form đăng nhập)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Tiêu đề
                  const Text(
                    "Chào mừng trở lại!",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  // Mô tả ngắn
                  const Text(
                    "Hãy đăng nhập với thông tin mà bạn đã sử dụng khi đăng ký.",
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 20),

                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Email
                        TextFormField(
                          controller: emailController,
                          keyboardType: TextInputType.emailAddress,
                          decoration: InputDecoration(
                            hintText: "Địa chỉ Email",
                            prefixIcon: const Icon(Icons.email_outlined),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Vui lòng nhập địa chỉ Email"
                              : null,
                        ),
                        const SizedBox(height: 15),

                        // Mật khẩu
                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            hintText: "Mật khẩu",
                            prefixIcon: const Icon(Icons.lock_outline),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Vui lòng nhập mật khẩu"
                              : null,
                        ),

                        // Thông báo lỗi
                        if (errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8.0),
                            child: Text(
                              errorMessage!,
                              style: const TextStyle(
                                color: Colors.red,
                                fontSize: 14,
                              ),
                            ),
                          ),

                        // Quên mật khẩu?
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {
                              // Xử lý quên mật khẩu
                            },
                            child: const Text(
                              "Quên mật khẩu?",
                              style: TextStyle(color: Colors.blue),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),

                        // Nút Đăng nhập
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(vertical: 14),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            onPressed: isLoading ? null : _login,
                            child: isLoading
                                ? const CircularProgressIndicator(
                              color: Colors.white,
                            )
                                : const Text(
                              "Đăng nhập",
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Chưa có tài khoản?
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text("Chưa có tài khoản? "),
                            GestureDetector(
                              onTap: () {
                                Navigator.pushReplacementNamed(
                                  context,
                                  AppRoutes.register,
                                );
                              },
                              child: const Text(
                                "Đăng ký",
                                style: TextStyle(
                                  color: Colors.blue,
                                  fontWeight: FontWeight.bold,
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
          ],
        ),
      ),
    );
  }
}