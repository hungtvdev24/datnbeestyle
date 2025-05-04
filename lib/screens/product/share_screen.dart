import 'package:flutter/material.dart';
import 'package:share_plus/share_plus.dart';
import 'package:iconsax/iconsax.dart';

class ShareScreen extends StatelessWidget {
  final String? title;
  final String? content;
  final String? url;

  const ShareScreen({
    super.key,
    this.title,
    this.content,
    this.url,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Stack(
          children: [
            // Phần trên (nền hồng, chứa hình minh họa)
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
                      'assets/login_header.png', // Thay bằng hình ảnh phù hợp
                      height: 280,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                      const Icon(Icons.error),
                    ),
                  ),
                ],
              ),
            ),
            // Nút quay lại
            Positioned(
              top: 16,
              left: 16,
              child: IconButton(
                icon: const Icon(Iconsax.arrow_left, color: Colors.black),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            // Phần nội dung
            Padding(
              padding: const EdgeInsets.only(top: 280),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tiêu đề
                    Text(
                      "Chia sẻ",
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Tiêu đề thông báo
                    Text(
                      title ?? "Không có tiêu đề",
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 10),
                    // Nội dung thông báo
                    Text(
                      content ?? "Không có nội dung",
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey.shade600,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 20),
                    // URL (nếu có)
                    if (url != null) ...[
                      const Text(
                        "Liên kết:",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        url!,
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.pink,
                          decoration: TextDecoration.underline,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      const SizedBox(height: 20),
                    ],
                    // Nút chia sẻ
                    Center(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          _shareContent();
                        },
                        icon: const Icon(Iconsax.share, color: Colors.black),
                        label: const Text(
                          "Chia sẻ ngay",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.black,
                            fontFamily: 'Roboto',
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: Colors.black,
                          padding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(24),
                            side: const BorderSide(color: Colors.black),
                          ),
                          elevation: 0,
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

  void _shareContent() {
    String shareText = "$title\n\n$content";
    if (url != null) {
      shareText += "\n\nXem chi tiết tại: $url";
    }
    Share.share(shareText, subject: title);
  }
}