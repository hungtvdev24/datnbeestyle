import 'package:flutter/material.dart';
import '../../routes.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();
  final TextEditingController confirmPasswordController = TextEditingController();
  bool isResetPasswordMode = false; // Trạng thái: true nếu đang ở giai đoạn đặt lại mật khẩu
  bool isLoading = false;
  String? errorMessage;
  bool _obscureNewPassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    if (args != null && args['isFromOtp'] == true) {
      setState(() {
        isResetPasswordMode = true;
        emailController.text = args['email'] ?? '';
      });
    }
  }

  void _sendOtp() {
    if (emailController.text.isEmpty) {
      setState(() {
        errorMessage = "Vui lòng nhập địa chỉ Email";
      });
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Giả lập gửi OTP (thay bằng API thực tế)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
      Navigator.pushNamed(
        context,
        AppRoutes.otp,
        arguments: {'email': emailController.text},
      );
    });
  }

  void _resetPassword() {
    if (newPasswordController.text.isEmpty || confirmPasswordController.text.isEmpty) {
      setState(() {
        errorMessage = "Vui lòng nhập đầy đủ mật khẩu";
      });
      return;
    }
    if (newPasswordController.text != confirmPasswordController.text) {
      setState(() {
        errorMessage = "Mật khẩu xác nhận không khớp";
      });
      return;
    }
    setState(() {
      isLoading = true;
      errorMessage = null;
    });

    // Giả lập đặt lại mật khẩu (thay bằng API thực tế)
    Future.delayed(const Duration(seconds: 2), () {
      setState(() {
        isLoading = false;
      });
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            Container(
              height: 280,
              width: double.infinity,
              decoration: const BoxDecoration(
                color: Color(0xFFFCE4EC),
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
                      'assets/login_header.png',
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                    ),
                  ),
                ],
              ),
            ),
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
            Padding(
              padding: const EdgeInsets.only(top: 280),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isResetPasswordMode ? "Đặt lại mật khẩu" : "Quên mật khẩu",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 16),
                    Text(
                      isResetPasswordMode
                          ? "Vui lòng nhập mật khẩu mới để đặt lại."
                          : "Nhập email của bạn để nhận mã OTP.",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.grey,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 24),
                    if (!isResetPasswordMode) ...[
                      TextFormField(
                        controller: emailController,
                        keyboardType: TextInputType.emailAddress,
                        decoration: InputDecoration(
                          hintText: "Email",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                        ),
                        style: const TextStyle(fontFamily: 'Roboto'),
                      ),
                    ],
                    if (isResetPasswordMode) ...[
                      TextFormField(
                        controller: newPasswordController,
                        obscureText: _obscureNewPassword,
                        decoration: InputDecoration(
                          hintText: "Mật khẩu mới",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureNewPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureNewPassword = !_obscureNewPassword;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(fontFamily: 'Roboto'),
                      ),
                      const SizedBox(height: 16),
                      TextFormField(
                        controller: confirmPasswordController,
                        obscureText: _obscureConfirmPassword,
                        decoration: InputDecoration(
                          hintText: "Xác nhận mật khẩu mới",
                          filled: true,
                          fillColor: Colors.grey[100],
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(8),
                            borderSide: BorderSide.none,
                          ),
                          suffixIcon: IconButton(
                            icon: Icon(
                              _obscureConfirmPassword ? Icons.visibility_off : Icons.visibility,
                              color: Colors.grey,
                            ),
                            onPressed: () {
                              setState(() {
                                _obscureConfirmPassword = !_obscureConfirmPassword;
                              });
                            },
                          ),
                        ),
                        style: const TextStyle(fontFamily: 'Roboto'),
                      ),
                    ],
                    const SizedBox(height: 24),
                    if (errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8.0),
                        child: Text(
                          errorMessage!,
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 14,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(color: Colors.black),
                          ),
                          elevation: 0,
                        ),
                        onPressed: isLoading
                            ? null
                            : (isResetPasswordMode ? _resetPassword : _sendOtp),
                        child: isLoading
                            ? const CircularProgressIndicator(
                          color: Colors.black,
                        )
                            : Text(
                          isResetPasswordMode ? "Xác nhận" : "Gửi mã OTP",
                          style: const TextStyle(
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
          ],
        ),
      ),
    );
  }
}