import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/review_provider.dart';
import '../../providers/user_provider.dart';

class ReviewScreen extends StatefulWidget {
  final int orderId;
  final int productId;

  const ReviewScreen({Key? key, required this.orderId, required this.productId}) : super(key: key);

  @override
  _ReviewScreenState createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  int _rating = 0;
  final TextEditingController _commentController = TextEditingController();
  String? _imageUrl;

  @override
  Widget build(BuildContext context) {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        return Scaffold(
          appBar: AppBar(
            title: const Text("Đánh giá sản phẩm"),
            backgroundColor: Colors.grey[200],
            elevation: 0,
            titleTextStyle: const TextStyle(color: Colors.black87, fontSize: 20, fontWeight: FontWeight.bold),
            iconTheme: const IconThemeData(color: Colors.black87),
          ),
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Chọn số sao:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: List.generate(5, (index) {
                      return IconButton(
                        icon: Icon(
                          index < _rating ? Icons.star : Icons.star_border,
                          color: Colors.yellow[700],
                          size: 40,
                        ),
                        onPressed: () {
                          setState(() {
                            _rating = index + 1;
                          });
                        },
                      );
                    }),
                  ),
                  const SizedBox(height: 16),
                  const Text("Bình luận:", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    controller: _commentController,
                    maxLines: 4,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Nhập bình luận của bạn (không bắt buộc)",
                    ),
                  ),
                  const SizedBox(height: 16),
                  // Tạm thời dùng TextField để nhập URL hình ảnh, có thể nâng cấp thành upload ảnh sau
                  const Text("Hình ảnh (không bắt buộc):", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  TextField(
                    onChanged: (value) => _imageUrl = value,
                    decoration: const InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: "Dán URL hình ảnh (nếu có)",
                    ),
                  ),
                  const SizedBox(height: 20),
                  reviewProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : ElevatedButton(
                    onPressed: () async {
                      if (_rating == 0) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Vui lòng chọn số sao!")));
                        return;
                      }

                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final success = await reviewProvider.submitReview(
                        userProvider.token!,
                        widget.orderId,
                        widget.productId,
                        _rating,
                        _commentController.text,
                        _imageUrl,
                      );

                      if (success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Đánh giá đã được gửi thành công!")));
                        Navigator.pop(context);
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content: Text(reviewProvider.errorMessage ?? "Lỗi khi gửi đánh giá")));
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[300],
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text("Gửi đánh giá", style: TextStyle(color: Colors.white)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}