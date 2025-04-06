import 'package:flutter/material.dart';
import 'package:iconsax/iconsax.dart';
import 'package:share_plus/share_plus.dart';

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
      appBar: AppBar(
        title: const Text(
          "Chia sẻ",
          style: TextStyle(
            color: Colors.black,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Iconsax.arrow_left, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title ?? "Không có tiêu đề",
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              content ?? "Không có nội dung",
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 20),
            if (url != null) ...[
              const Text(
                "Liên kết:",
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                url!,
                style: const TextStyle(
                  fontSize: 14,
                  color: Colors.blue,
                  decoration: TextDecoration.underline,
                ),
              ),
              const SizedBox(height: 20),
            ],
            Center(
              child: ElevatedButton.icon(
                onPressed: () {
                  _shareContent();
                },
                icon: const Icon(Iconsax.share),
                label: const Text("Chia sẻ ngay"),
                style: ElevatedButton.styleFrom(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  backgroundColor: Colors.blue,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
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
