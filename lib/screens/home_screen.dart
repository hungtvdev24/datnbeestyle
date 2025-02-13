import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:datnbeestyle/screens/product_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> with SingleTickerProviderStateMixin {
  late PageController _bannerController;
  late PageController _flashSaleController;
  int _bannerIndex = 0;
  int _flashSaleIndex = 0;

  // Trạng thái mục chọn trong danh mục
  int _selectedCategoryIndex = 0;

  // Danh sách danh mục
  final List<String> _categories = ["Tất cả", "Sale", "Nữ", "Nam", "Trẻ em"];

  @override
  void initState() {
    super.initState();

    // Banner quảng cáo tự động chuyển ảnh
    _bannerController = PageController();
    _flashSaleController = PageController();

    // Auto chuyển banner
    Future.delayed(Duration.zero, () {
      _autoScrollBanner();
      _autoScrollFlashSale();
    });
  }

  void _autoScrollBanner() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_bannerController.hasClients) {
        setState(() {
          _bannerIndex = (_bannerIndex + 1) % 3;
          _bannerController.animateToPage(
            _bannerIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
        _autoScrollBanner();
      }
    });
  }

  void _autoScrollFlashSale() {
    Future.delayed(const Duration(seconds: 3), () {
      if (_flashSaleController.hasClients) {
        setState(() {
          _flashSaleIndex = (_flashSaleIndex + 1) % 3;
          _flashSaleController.animateToPage(
            _flashSaleIndex,
            duration: const Duration(milliseconds: 500),
            curve: Curves.easeInOut,
          );
        });
        _autoScrollFlashSale();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'BeeStyle',
          style: GoogleFonts.pacifico(color: Colors.purple),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.search, color: Colors.purple),
            onPressed: () {},
          ),
          IconButton(
            icon: const Icon(Icons.notifications_none, color: Colors.purple),
            onPressed: () {},
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Banner quảng cáo
            SizedBox(
              height: 200,
              child: PageView(
                controller: _bannerController,
                children: [
                  Image.network('https://static.vecteezy.com/system/resources/previews/008/174/590/non_2x/fashion-advertising-web-banner-illustration-vector.jpg', fit: BoxFit.cover),
                  Image.network('https://img.pikbest.com/origin/09/30/65/27hpIkbEsTzdI.jpg!sw800', fit: BoxFit.cover),
                  Image.network('https://static.vecteezy.com/system/resources/previews/008/174/590/non_2x/fashion-advertising-web-banner-illustration-vector.jpg', fit: BoxFit.cover),
                ],
              ),
            ),
            const SizedBox(height: 10),

            // Danh mục
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Danh mục',
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: List<Widget>.generate(_categories.length, (int index) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4.0),
                    child: ChoiceChip(
                      label: Text(
                        _categories[index],
                        style: TextStyle(
                          color: _selectedCategoryIndex == index ? Colors.white : Colors.purple,
                        ),
                      ),
                      selected: _selectedCategoryIndex == index,
                      selectedColor: Colors.purple,
                      backgroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: const BorderSide(color: Colors.purple),
                      ),
                      onSelected: (bool selected) {
                        setState(() {
                          _selectedCategoryIndex = selected ? index : 0;
                        });
                      },
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),


// Sản phẩm nổi bật
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                'Nổi bật',
                style: GoogleFonts.roboto(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            SizedBox(
              height: 250,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: List.generate(4, (index) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProductDetailScreen(
                            imageUrl: 'https://product.hstatic.net/200000388559/product/24e41e9c-5f36-4656-9464-e86cba29c96d_7a423adc352040f3bb54d36fe37c28e1_master.jpg',
                            productName: 'Váy L&C',
                            productDescription: 'Thiết kế của Abc với chất liệu cao cấp.',
                            currentPrice: '200.000đ',
                            oldPrice: '300.000đ',
                          ),
                        ),
                      );
                    },
                    child: Container(
                      width: 150,
                      margin: const EdgeInsets.symmetric(horizontal: 8),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(color: Colors.grey.shade300, blurRadius: 5, spreadRadius: 2),
                        ],
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          ClipRRect(
                            borderRadius: const BorderRadius.only(
                              topLeft: Radius.circular(10),
                              topRight: Radius.circular(10),
                            ),
                            child: Image.network(
                              'https://product.hstatic.net/200000388559/product/24e41e9c-5f36-4656-9464-e86cba29c96d_7a423adc352040f3bb54d36fe37c28e1_master.jpg',
                              fit: BoxFit.cover,
                              height: 100,
                              width: double.infinity,
                              loadingBuilder: (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(child: CircularProgressIndicator());
                              },
                              errorBuilder: (context, error, stackTrace) {
                                return const Center(
                                  child: Icon(Icons.broken_image, color: Colors.red),
                                );
                              },
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: const [
                                Text("Váy L&C", style: TextStyle(fontWeight: FontWeight.bold)),
                                Text("Thiết kế của Abc"),
                                Text("200.000đ", style: TextStyle(color: Colors.red)),
                                Text("300.000đ", style: TextStyle(decoration: TextDecoration.lineThrough)),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }),
              ),
            ),
            const SizedBox(height: 10),



            // Flash Sale
            SizedBox(
              height: 200,
              child: PageView(
                controller: _flashSaleController,
                children: [
                  Image.network('https://blog.dktcdn.net/files/flash-sale-la-gi.jpg', fit: BoxFit.cover),
                  Image.network('https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcTjwqbC-g5aXFAv8XqGesxB5v9n3dGRZ7KfjQ&s', fit: BoxFit.cover),
                  Image.network('https://blog.dktcdn.net/files/flash-sale-la-gi.jpg', fit: BoxFit.cover),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        selectedItemColor: Colors.purple,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.store), label: 'Shop'),
          BottomNavigationBarItem(icon: Icon(Icons.grid_view), label: 'Danh mục'),
          BottomNavigationBarItem(icon: Icon(Icons.shopping_cart), label: 'Giỏ hàng'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Tài khoản'),
        ],
      ),
    );
  }
}
