import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/user_provider.dart';
import '../../core/models/address.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({Key? key}) : super(key: key);

  @override
  State<AddressListScreen> createState() => _AddressListScreenState();
}

class _AddressListScreenState extends State<AddressListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final token = userProvider.token;
      if (token != null) {
        addressProvider.fetchAddresses(token);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Vui lòng đăng nhập để xem địa chỉ!')),
        );
      }
    });
  }

  void _showDeleteConfirmationDialog(BuildContext context, Address addr, String token) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Text(
            "Xác nhận xóa",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black87,
              fontFamily: 'Roboto',
            ),
          ),
          content: const Text(
            "Bạn có chắc muốn xóa địa chỉ này không?",
            style: TextStyle(fontFamily: 'Roboto'),
          ),
          actions: [
            TextButton(
              child: const Text(
                "Hủy",
                style: TextStyle(color: Colors.grey, fontFamily: 'Roboto'),
              ),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: const Text(
                "Xóa",
                style: TextStyle(color: Colors.red, fontFamily: 'Roboto'),
              ),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await Provider.of<AddressProvider>(context, listen: false)
                      .removeAddress(token, addr.idDiaChi);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Xóa địa chỉ thành công!'),
                      backgroundColor: Colors.green,
                    ),
                  );
                } catch (e) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Lỗi khi xóa địa chỉ: $e'),
                      backgroundColor: Colors.red,
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final addressProvider = Provider.of<AddressProvider>(context);
    final addresses = addressProvider.addresses;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text(
          "Địa chỉ giao hàng",
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
      body: addressProvider.isLoading
          ? const Center(
        child: CircularProgressIndicator(
          color: Colors.black,
        ),
      )
          : addressProvider.errorMessage != null
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
                addressProvider.errorMessage!,
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
                    addressProvider.fetchAddresses(token);
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
        child: Column(
          children: [
            Expanded(
              child: addresses.isEmpty
                  ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(
                      Icons.location_off,
                      size: 80,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      "Chưa có địa chỉ nào",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Hãy thêm địa chỉ để bắt đầu mua sắm!",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 16,
                        fontFamily: 'Roboto',
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AddAddressScreen(),
                          ),
                        );
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
                        "Thêm địa chỉ ngay",
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
              )
                  : ListView.builder(
                itemCount: addresses.length,
                itemBuilder: (context, index) {
                  final addr = addresses[index];
                  final userProvider = Provider.of<UserProvider>(context, listen: false);
                  final token = userProvider.token;
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
                            Icons.location_on,
                            color: Colors.pink,
                            size: 30,
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  addr.tenNguoiNhan ?? '',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 18,
                                    color: Colors.black87,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "${addr.tenNha ?? ''}, ${addr.xa ?? ''}, ${addr.huyen ?? ''}, ${addr.tinh ?? ''}",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  "SDT: ${addr.sdtNhanHang ?? ''}",
                                  style: TextStyle(
                                    color: Colors.grey[700],
                                    fontSize: 14,
                                    fontFamily: 'Roboto',
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Column(
                            children: [
                              IconButton(
                                icon: const Icon(Icons.edit, color: Colors.pink),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => AddAddressScreen(address: addr),
                                    ),
                                  );
                                },
                              ),
                              IconButton(
                                icon: const Icon(Icons.delete, color: Colors.red),
                                onPressed: token != null
                                    ? () => _showDeleteConfirmationDialog(context, addr, token)
                                    : null,
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const AddAddressScreen()),
                  );
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
                  "Thêm Địa Chỉ Mới",
                  style: TextStyle(
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
    );
  }
}

class AddAddressScreen extends StatefulWidget {
  final Address? address;
  const AddAddressScreen({Key? key, this.address}) : super(key: key);

  @override
  State<AddAddressScreen> createState() => _AddAddressScreenState();
}

class _AddAddressScreenState extends State<AddAddressScreen> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _sdtController;
  late final TextEditingController _tenNguoiNhanController;
  late final TextEditingController _tenNhaController;
  late final TextEditingController _tinhController;
  late final TextEditingController _huyenController;
  late final TextEditingController _xaController;

  @override
  void initState() {
    super.initState();
    _sdtController = TextEditingController(text: widget.address?.sdtNhanHang ?? '');
    _tenNguoiNhanController = TextEditingController(text: widget.address?.tenNguoiNhan ?? '');
    _tenNhaController = TextEditingController(text: widget.address?.tenNha ?? '');
    _tinhController = TextEditingController(text: widget.address?.tinh ?? '');
    _huyenController = TextEditingController(text: widget.address?.huyen ?? '');
    _xaController = TextEditingController(text: widget.address?.xa ?? '');
  }

  @override
  void dispose() {
    _sdtController.dispose();
    _tenNguoiNhanController.dispose();
    _tenNhaController.dispose();
    _tinhController.dispose();
    _huyenController.dispose();
    _xaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          widget.address == null ? "Thêm địa chỉ" : "Sửa địa chỉ",
          style: const TextStyle(
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          elevation: 3,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Thông tin địa chỉ",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                      fontFamily: 'Roboto',
                    ),
                  ),
                  const SizedBox(height: 16),
                  _buildTextField(_tenNguoiNhanController, "Tên người nhận"),
                  _buildTextField(_sdtController, "Số điện thoại nhận hàng"),
                  _buildTextField(_tenNhaController, "Số nhà / Tên nhà"),
                  _buildTextField(_tinhController, "Tỉnh"),
                  _buildTextField(_huyenController, "Huyện"),
                  _buildTextField(_xaController, "Xã / Phường"),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => _onSubmit(context),
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
                      child: Text(
                        widget.address == null ? "Lưu" : "Cập nhật",
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
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextFormField(
        controller: controller,
        decoration: InputDecoration(
          hintText: label,
          filled: true,
          fillColor: Colors.grey[100],
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(fontFamily: 'Roboto'),
        validator: (value) {
          if (value == null || value.trim().isEmpty) {
            return "Vui lòng nhập $label";
          }
          return null;
        },
      ),
    );
  }

  void _onSubmit(BuildContext context) {
    if (_formKey.currentState!.validate()) {
      final address = Address(
        idDiaChi: widget.address?.idDiaChi ?? 0,
        sdtNhanHang: _sdtController.text.trim(),
        tenNguoiNhan: _tenNguoiNhanController.text.trim(),
        tenNha: _tenNhaController.text.trim(),
        tinh: _tinhController.text.trim(),
        huyen: _huyenController.text.trim(),
        xa: _xaController.text.trim(),
      );

      final userProvider = Provider.of<UserProvider>(context, listen: false);
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      final token = userProvider.token;

      if (token != null) {
        if (widget.address == null) {
          addressProvider.addAddress(token, address).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Thêm địa chỉ thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi thêm địa chỉ: $error'),
                backgroundColor: Colors.red,
              ),
            );
          });
        } else {
          addressProvider.updateAddress(token, address).then((_) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Cập nhật địa chỉ thành công!'),
                backgroundColor: Colors.green,
              ),
            );
            Navigator.pop(context);
          }).catchError((error) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Lỗi khi cập nhật địa chỉ: $error'),
                backgroundColor: Colors.red,
              ),
            );
          });
        }
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Vui lòng đăng nhập để thực hiện thao tác!'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}