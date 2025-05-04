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
  bool _hasSearched = false;
  late ProductProvider _productProvider;

  @override
  void initState() {
    super.initState();
    _productProvider = Provider.of<ProductProvider>(context, listen: false);
    _loadSearchHistory();
  }

  Future<void> _loadSearchHistory() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory = prefs.getStringList('searchHistory') ?? [];
    });
  }

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

  Future<void> _removeSearchHistoryItem(String query) async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      searchHistory.remove(query);
      prefs.setStringList('searchHistory', searchHistory);
    });
  }

  Future<void> _filterSearchResults() async {
    String query = _searchController.text.trim();
    await _productProvider.searchProducts(query);
    if (query.isNotEmpty) {
      await _saveSearchHistory(query);
    }
    setState(() {
      _hasSearched = true;
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _productProvider.clearSearch();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ProductProvider>(
      builder: (context, productProvider, child) {
        return Scaffold(
          backgroundColor: Colors.grey[100],
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            title: Container(
              margin: const EdgeInsets.symmetric(vertical: 8.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey[400]!, width: 1),
              ),
              child: TextField(
                controller: _searchController,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: "Tìm kiếm sản phẩm...",
                  hintStyle: TextStyle(color: Colors.grey[600], fontFamily: 'Roboto'),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  prefixIcon: Icon(Icons.search, color: Colors.grey[600], size: 24),
                ),
                style: const TextStyle(fontFamily: 'Roboto', color: Colors.black),
                onSubmitted: (value) {
                  _filterSearchResults();
                },
              ),
            ),
            actions: [
              IconButton(
                icon: Icon(Icons.close, color: Colors.grey[600]),
                onPressed: () {
                  _searchController.clear();
                  productProvider.clearSearch();
                  setState(() {
                    _hasSearched = false;
                  });
                },
              ),
            ],
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: Colors.grey[600]),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          body: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (searchHistory.isNotEmpty && _searchController.text.isEmpty && !_hasSearched)
                  Container(
                    color: Colors.white,
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
                            fontFamily: 'Roboto',
                          ),
                        ),
                        const SizedBox(height: 10),
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: searchHistory.length,
                          itemBuilder: (context, index) {
                            final query = searchHistory[index];
                            return Container(
                              margin: const EdgeInsets.symmetric(vertical: 4.0),
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: GestureDetector(
                                      onTap: () {
                                        _searchController.text = query;
                                        _filterSearchResults();
                                      },
                                      child: Text(
                                        query,
                                        style: const TextStyle(
                                          fontSize: 16,
                                          color: Colors.black87,
                                          fontFamily: 'Roboto',
                                        ),
                                      ),
                                    ),
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.close, size: 20, color: Colors.grey[600]),
                                    onPressed: () => _removeSearchHistoryItem(query),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                if (_hasSearched)
                  Container(
                    color: Colors.white,
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
                            fontFamily: 'Roboto',
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
                                style: const TextStyle(
                                  color: Colors.red,
                                  fontSize: 16,
                                  fontFamily: 'Roboto',
                                ),
                              ),
                              const SizedBox(height: 20),
                              ElevatedButton(
                                onPressed: () => _filterSearchResults(),
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
                                child: const Text(
                                  "Thử lại",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.black,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ),
                            ],
                          )
                        else if (productProvider.searchResults.isEmpty)
                            const Center(
                              child: Text(
                                "Không tìm thấy sản phẩm",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey,
                                  fontFamily: 'Roboto',
                                ),
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
                if (_hasSearched) _buildSuggestedProductsSection(productProvider),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildSuggestedProductsSection(ProductProvider productProvider) {
    return Container(
      color: Colors.white,
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
              fontFamily: 'Roboto',
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
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 16,
                    fontFamily: 'Roboto',
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => productProvider.loadProducts(),
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
                  child: const Text(
                    "Thử lại",
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      color: Colors.black,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ),
              ],
            )
          else if (productProvider.products.isEmpty)
              const Text(
                "Không có sản phẩm gợi ý",
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                  fontFamily: 'Roboto',
                ),
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

  Widget _buildProductCard(BuildContext context, dynamic product, {required bool isFavorite}) {
    final formatCurrency = NumberFormat("#,###", "vi_VN");

    // Lấy URL hình ảnh từ variations nếu có, nếu không thì dùng urlHinhAnh
    final imageUrl = product['variations'] != null &&
        product['variations'].isNotEmpty &&
        product['variations'][0]['images'] != null &&
        product['variations'][0]['images'].isNotEmpty
        ? product['variations'][0]['images'][0]['image_url']?.toString() ?? "https://via.placeholder.com/150"
        : product['urlHinhAnh']?.toString() ?? "https://via.placeholder.com/150";

    // Lấy size từ variations (nếu có)
    String? size;
    if (product['variations'] != null &&
        product['variations'].isNotEmpty &&
        product['variations'][0]['size'] != null) {
      size = product['variations'][0]['size'].toString();
    }

    // Lấy giá từ variation nếu có, nếu không thì lấy từ product['gia']
    final double price = product['variations'] != null &&
        product['variations'].isNotEmpty &&
        product['variations'][0]['price'] != null
        ? (double.tryParse(product['variations'][0]['price'].toString()) ?? 0.0)
        : (double.tryParse(product['gia'].toString()) ?? 0.0);

    final priceText = "${formatCurrency.format(price)} VNĐ";

    final thuongHieu = product['thuongHieu'] ?? "Không có thương hiệu";
    final tenSanPham = product['tenSanPham'] ?? "Không có tên";

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
        decoration: BoxDecoration(
          border: Border.all(
            color: Colors.black.withOpacity(0.2),
            width: 1,
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(12),
                    topRight: Radius.circular(12),
                  ),
                  child: Image.network(
                    imageUrl,
                    height: 120,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
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
                Positioned(
                  top: 8,
                  left: 8,
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: const Color(0xFFFCE4EC),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Text(
                      "Like",
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
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
                    bottomLeft: Radius.circular(12),
                    bottomRight: Radius.circular(12),
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
                        fontFamily: 'Roboto',
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
                        fontFamily: 'Roboto',
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (size != null) ...[
                      const SizedBox(height: 4),
                      Text(
                        "Size: $size",
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.grey,
                          fontFamily: 'Roboto',
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const Spacer(),
                    Text(
                      priceText,
                      style: const TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                        fontFamily: 'Roboto',
                      ),
                      overflow: TextOverflow.ellipsis,
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