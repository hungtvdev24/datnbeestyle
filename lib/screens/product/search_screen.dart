import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../providers/product_provider.dart';
import 'product_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  List<String> searchHistory = [];
  bool _hasSearched = false; // Biến để kiểm tra xem người dùng đã bấm tìm kiếm chưa

  @override
  void initState() {
    super.initState();
    _loadSearchHistory();
  }

  // Tải lịch sử tìm kiếm từ SharedPreferences
  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

  // Lưu lịch sử tìm kiếm vào SharedPreferences
  Future<void> _saveSearchHistory(String query) async {
    if (query.isEmpty) return;
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      if (!searchHistory.contains(query)) {
        searchHistory.insert(0, query);
        if (searchHistory.length > 10) {
          searchHistory = searchHistory.sublist(0, 10);
        }
        prefs.setStringList('searchHistory', searchHistory);
      }
    });
  }

  // Xóa một mục trong lịch sử tìm kiếm
  Future<void> _removeSearchHistoryItem(String query) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory.remove(query);
      prefs.setStringList('searchHistory', searchHistory);
    });
  }

  // Tìm kiếm sản phẩm
  Future<void> _filterSearchResults() async {
    String query = _searchController.text.trim();
    final productProvider = Provider.of<ProductProvider>(context, listen: false);
    await productProvider.searchProducts(query);
    if (query.isNotEmpty) {
      await _saveSearchHistory(query);
    }
    setState(() {
      _hasSearched = true; // Đánh dấu rằng người dùng đã bấm tìm kiếm
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    Provider.of<ProductProvider>(context, listen: false).clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: TextField(
              controller: _searchController,
              autofocus: true,
              decoration: const InputDecoration(
                hintText: "Tìm kiếm sản phẩm...",
                border: InputBorder.none,
              ),
              onSubmitted: (value) {
                // Cho phép tìm kiếm khi người dùng nhấn Enter trên bàn phím
                _filterSearchResults();
              },
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  _filterSearchResults(); // Gọi tìm kiếm khi nhấn nút kính lúp
                },
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () {
                  _searchController.clear();
                  productProvider.clearSearch();
                  setState(() {
                    _hasSearched = false; // Reset trạng thái tìm kiếm
                  });
                },
              ),
            ],
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Hiển thị lịch sử tìm kiếm
                if (searchHistory.isNotEmpty && _searchController.text.isEmpty && !_hasSearched)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Lịch sử tìm kiếm",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Wrap(
                          spacing: 8.0,
                          runSpacing: 8.0,
                          children: searchHistory.map((query) {
                            return GestureDetector(
                              onTap: () {
                                _searchController.text = query;
                                _filterSearchResults();
                              },
                              child: Chip(
                                label: Text(query),
                                deleteIcon: const Icon(Icons.close, size: 18),
                                onDeleted: () => _removeSearchHistoryItem(query),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                // Hiển thị kết quả tìm kiếm (chỉ khi đã bấm tìm kiếm)
                if (_hasSearched)
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Kết quả tìm kiếm",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                        const SizedBox(height: 10),
                        if (productProvider.isSearching)
                          const Center(child: CircularProgressIndicator())
                        else if (productProvider.hasSearchError)
                          Column(
                            children: [
                              Text(
                                productProvider.searchErrorMessage ?? "Lỗi không xác định",
                                style: const TextStyle(color: Colors.red, fontSize: 16),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _filterSearchResults(),
                                child: const Text("Thử lại"),
                              ),
                            ],
                          )
                        else if (productProvider.searchResults.isEmpty)
                            const Center(
                              child: Text(
                                "Không tìm thấy sản phẩm",
                                style: TextStyle(fontSize: 16, color: Colors.grey),
                              ),
                            )
                          else
                            GridView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: productProvider.searchResults.length,
                              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: 2,
                                crossAxisSpacing: 12,
                                mainAxisSpacing: 12,
                                childAspectRatio: 0.75,
                              ),
                              itemBuilder: (context, index) {
                                final product = productProvider.searchResults[index];
                                return _buildProductCard(context, product, isFavorite: false);
                              },
                            ),
                      ],
                    ),
                  ),

                // Hiển thị gợi ý sản phẩm (luôn hiển thị sau khi bấm tìm kiếm)
                if (_hasSearched)
                  _buildSuggestedProductsSection(productProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  // Widget hiển thị phần gợi ý sản phẩm
  Widget _buildSuggestedProductsSection(ProductProvider productProvider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Sản phẩm gợi ý",
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 10),
          if (productProvider.isLoading)
            const Center(child: CircularProgressIndicator())
          else if (productProvider.hasError)
            Column(
              children: [
                Text(
                  productProvider.errorMessage ?? "Lỗi không xác định",
                  style: const TextStyle(color: Colors.red, fontSize: 16),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => productProvider.loadProducts(),
                  child: const Text("Thử lại"),
                ),
              ],
            )
          else if (productProvider.products.isEmpty)
              const Text(
                "Không có sản phẩm gợi ý",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              )
            else
              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: productProvider.products.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 0.75,
                ),
                itemBuilder: (context, index) {
                  final product = productProvider.products[index];
                  return _buildProductCard(context, product, isFavorite: false);
                },
              ),
        ],
      ),
    );
  }

  // Widget hiển thị thẻ sản phẩm
  Widget _buildProductCard(BuildContext context, dynamic product, {required bool isFavorite}) {
    final formatCurrency = NumberFormat("#,###", "vi_VN");

    final imageUrl = product['urlHinhAnh']?.toString().startsWith('http') == true
        ? product['urlHinhAnh']
        : "https://72f7-104-28-254-73.ngrok-free.app/images/default.png";
    final thuongHieu = product['thuongHieu'] ?? "Không có thương hiệu";
    final tenSanPham = product['tenSanPham'] ?? "Không có tên";
    final double originalPrice = double.tryParse(product['gia'].toString()) ?? 0.0;

    const bool hasDiscount = true;
    const double discountPercent = 20;
    final double discountedPrice = originalPrice * (1 - discountPercent / 100);

    final discountedPriceText = "${formatCurrency.format(discountedPrice)} ₫";
    final originalPriceText = "${formatCurrency.format(originalPrice)} ₫";

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProductDetailScreen(product: product),
          ),
        );
      },
      child: Container(
        margin: const EdgeInsets.only(right: 16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(8),
                    topRight: Radius.circular(8),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      print("Error loading image for ${product['tenSanPham']}: $error");
                      return Container(
                        height: 120,
                        color: Colors.grey[300],
                        alignment: Alignment.center,
                        child: const Icon(Icons.error, size: 50),
                      );
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return const SizedBox(
                        height: 120,
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  ),
                ),
                if (hasDiscount)
                  Positioned(
                    top: 8,
                    left: 8,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.red,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        "$discountPercent% GIẢM",
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                if (isFavorite)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: const Icon(Icons.favorite, color: Colors.red, size: 24),
                  ),
              ],
            ),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(8.0),
                decoration: const BoxDecoration(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8),
                  ),
                  color: Colors.white,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      thuongHieu,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      tenSanPham,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const Spacer(),
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            discountedPriceText,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.bold,
                              color: Colors.black87,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (hasDiscount) ...[
                          const SizedBox(width: 6),
                          Flexible(
                            child: Text(
                              originalPriceText,
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey[600],
                                decoration: TextDecoration.lineThrough,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ],
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