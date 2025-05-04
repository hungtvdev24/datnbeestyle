import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/voucher_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/models/voucher.dart';

class VoucherListScreen extends StatefulWidget {
  const VoucherListScreen({Key? key}) : super(key: key);

  @override
  State<VoucherListScreen> createState() => _VoucherListScreenState();
}

class _VoucherListScreenState extends State<VoucherListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final voucherProvider = Provider.of<VoucherProvider>(context, listen: false);
      final token = userProvider.token;
      print('Token in VoucherListScreen: $token'); // Log token
      if (token != null) {
        voucherProvider.fetchVouchers(token);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để xem danh sách voucher!')),
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<VoucherProvider>(
      builder: (context, voucherProvider, child) {
        final vouchers = voucherProvider.vouchers;
        print('isLoading: ${voucherProvider.isLoading}'); // Log trạng thái loading
        print('errorMessage: ${voucherProvider.errorMessage}'); // Log lỗi
        print('Vouchers length: ${vouchers.length}'); // Log số lượng voucher

        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            title: const Text(
              "Danh sách Voucher",
              style: TextStyle(
                color: Colors.black,
                fontWeight: FontWeight.bold,
                fontSize: 20,
                fontFamily: 'Roboto',
              ),
            ),
            backgroundColor: Colors.white,
            elevation: 0,
            iconTheme: const IconThemeData(color: Colors.black),
            centerTitle: true,
          ),
          body: voucherProvider.isLoading
              ? const Center(
            child: CircularProgressIndicator(
              color: Colors.black,
            ),
          )
              : voucherProvider.errorMessage != null
              ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.error_outline,
                    size: 60,
                    color: Colors.red,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    voucherProvider.errorMessage!,
                    style: const TextStyle(
                      color: Colors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                      fontFamily: 'Roboto',
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      final userProvider = Provider.of<UserProvider>(context, listen: false);
                      final token = userProvider.token;
                      if (token != null) {
                        voucherProvider.fetchVouchers(token);
                      }
                    },
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
              ),
            ),
          )
              : Padding(
            padding: const EdgeInsets.all(16.0),
            child: vouchers.isEmpty
                ? Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.discount_outlined,
                    size: 80,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    "Chưa có voucher nào",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    "Hãy kiểm tra lại sau nhé!",
                    style: TextStyle(
                      color: Colors.grey,
                      fontSize: 16,
                      fontFamily: 'Roboto',
                    ),
                  ),
                ],
              ),
            )
                : ListView.builder(
              itemCount: vouchers.length,
              itemBuilder: (context, index) {
                final voucher = vouchers[index];
                return VoucherCard(voucher: voucher);
              },
            ),
          ),
        );
      },
    );
  }
}

class VoucherCard extends StatelessWidget {
  final Voucher voucher;

  const VoucherCard({Key? key, required this.voucher}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(
              Icons.discount,
              color: Colors.pink,
              size: 30,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        voucher.code,
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.black87,
                          fontFamily: 'Roboto',
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: voucher.isUsed ? Colors.grey : Colors.green,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          voucher.isUsed ? 'Đã sử dụng' : 'Khả dụng',
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontFamily: 'Roboto',
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Giảm: ${voucher.getFormattedDiscount()}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Đơn tối thiểu: ${voucher.getFormattedMinOrderValue()}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Hạn sử dụng: ${voucher.getFormattedDateRange()}',
                    style: TextStyle(
                      color: Colors.grey[700],
                      fontSize: 14,
                      fontFamily: 'Roboto',
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