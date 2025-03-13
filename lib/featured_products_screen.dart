import 'package:datnbeestyle/models.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'BeeStyle App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  final List<SanPham> sampleList = [
    SanPham('sp01', 'Váy L&C', 300.000, 200.000, '',
        'Thiết kế của Abc mang đẳng...', 0, 'dm00', 70000000000),
    SanPham('sp01', 'Váy L&C', 300.000, 200.000, '',
        'Thiết kế của Abc mang đẳng...', 0, 'dm00', 70000000000),
    SanPham('sp01', 'Váy L&C', 300.000, 200.000, '',
        'Thiết kế của Abc mang đẳng...', 0, 'dm00', 70000000000),
    SanPham('sp01', 'Váy L&C', 300.000, 200.000, '',
        'Thiết kế của Abc mang đẳng...', 0, 'dm00', 70000000000),
    SanPham('sp01', 'Váy L&C', 300.000, 200.000, '',
        'Thiết kế của Abc mang đẳng...', 0, 'dm00', 70000000000),
    SanPham('sp01', 'Váy L&C', 300.000, 200.000, '',
        'Thiết kế của Abc mang đẳng...', 0, 'dm00', 70000000000),
    // Add more products here...
  ];

  HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('BeeStyle'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              // TODO: Implement search functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.notifications),
            onPressed: () {
              // TODO: Implement notification functionality
            },
          ),
          IconButton(
            icon: Icon(Icons.tune),
            onPressed: () {
              // TODO: Implement filter functionality
            },
          ),
        ],
      ),
      body: GridView.count(
        crossAxisCount: 2,
        childAspectRatio: 2 / 3.5,
        padding: EdgeInsets.all(16.0),
        children:
            sampleList.map((product) => ProductCard(sp: product)).toList(),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.dry_cleaning),
            label: 'Clothes',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.grid_view),
            label: 'Categories',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bookmark_border),
            label: 'Bookmark',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.shopping_bag),
            label: 'Cart',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: 0, // You can set this dynamically
        selectedItemColor: Colors.grey,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: (index) {
          // TODO: Implement navigation based on index
        },
      ),
    );
  }
}

class ProductCard extends StatelessWidget {
  final SanPham sp;

  const ProductCard({super.key, required this.sp});

  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AspectRatio(
            aspectRatio: 18 / 11,
            child: Image.network(
              sp.img,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(16.0, 12.0, 16.0, 8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  sp.name,
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8.0),
                Text(
                  sp.des,
                  style: TextStyle(color: Colors.grey[600]),
                ),
                SizedBox(height: 8.0),
                Row(
                  children: [
                    Text(
                      sp.price.toString(),
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                    SizedBox(width: 8.0),
                    Text(
                      sp.originalPrice.toString(),
                      style: TextStyle(
                        decoration: TextDecoration.lineThrough,
                        color: Colors.grey,
                        fontSize: 12.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
