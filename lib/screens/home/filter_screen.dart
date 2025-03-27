import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/category_provider.dart';
import '../product/category_detail_screen.dart';

class FilterScreen extends StatelessWidget {
  const FilterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<CategoryProvider>(
      builder: (context, categoryProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white, // Nền trắng đồng bộ
          body: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ô tìm kiếm
                _buildSearchBar(context),

                const SizedBox(height: 10),

                // Tiêu đề
                const Text(
                  "Danh mục sản phẩm",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                // Danh sách danh mục
                Expanded(
                  child: categoryProvider.isLoading
                      ? const Center(child: CircularProgressIndicator())
                      : categoryProvider.hasError
                      ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          categoryProvider.errorMessage ?? "Lỗi không xác định",
                          style: const TextStyle(color: Colors.red, fontSize: 16),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => categoryProvider.refreshCategories(),
                          child: const Text("Thử lại"),
                        ),
                      ],
                    ),
                  )
                      : categoryProvider.categories.isEmpty
                      ? const Center(
                    child: Text(
                      "Không có danh mục nào",
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  )
                      : ListView.builder(
                    itemCount: categoryProvider.categories.length,
                    itemBuilder: (context, index) {
                      final category = categoryProvider.categories[index];
                      return _buildCategoryTile(
                        context,
                        category['tenDanhMuc'] ?? "Không có tên",
                        category['id_danhMuc'],
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget ô tìm kiếm
  Widget _buildSearchBar(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade100,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        children: [
          const Icon(Icons.search, color: Colors.grey),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              decoration: InputDecoration(
                hintText: "Tìm kiếm...",
                border: InputBorder.none,
                hintStyle: TextStyle(color: Colors.grey.shade500),
              ),
              onTap: () {
                // Điều hướng đến SearchScreen khi nhấn vào ô tìm kiếm
                Navigator.pushNamed(context, '/search');
              },
            ),
          ),
          const Icon(Icons.filter_list, color: Colors.grey),
        ],
      ),
    );
  }

  // Widget danh mục sản phẩm
  Widget _buildCategoryTile(BuildContext context, String title, int categoryId) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 6),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      elevation: 2, // Hiệu ứng đổ bóng nhẹ
      child: ExpansionTile(
        tilePadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        title: Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
        ),
        children: [
          ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 32),
            title: const Text("Xem tất cả", style: TextStyle(fontSize: 16)),
            onTap: () {
              // Điều hướng đến màn hình chi tiết danh mục
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CategoryDetailScreen(
                    categoryId: categoryId,
                    categoryName: title,
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}