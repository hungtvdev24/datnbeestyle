import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../core/models/address.dart';
import '../../providers/address_provider.dart';
import '../../providers/user_provider.dart';

class AddressListScreen extends StatefulWidget {
  const AddressListScreen({super.key});

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
          title: const Text("Xác nhận xóa"),
          content: const Text("Bạn có chắc muốn xóa địa chỉ này không?"),
          actions: [
            TextButton(
              child: const Text("Hủy", style: TextStyle(color: Colors.grey)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Xóa", style: TextStyle(color: Colors.red)),
              onPressed: () async {
                Navigator.of(context).pop();
                try {
                  await Provider.of<AddressProvider>(context, listen: false).removeAddress(token, addr.idDiaChi);
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
          style: TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: addressProvider.isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.blue))
          : addressProvider.errorMessage != null
          ? Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                addressProvider.errorMessage!,
                style: const TextStyle(color: Colors.red, fontSize: 16),
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
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Thử lại",
                  style: TextStyle(fontSize: 16, color: Colors.white),
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
                      style: TextStyle(color: Colors.grey, fontSize: 18),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Hãy thêm địa chỉ để bắt đầu mua sắm!",
                      style: TextStyle(color: Colors.grey, fontSize: 14),
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
                  return RadioListTile(
                    value: addr,
                    groupValue: null,
                    onChanged: (value) {},
                    title: Text(
                      addr.tenNguoiNhan,
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${addr.tenNha}, ${addr.xa}, ${addr.huyen}, ${addr.tinh}",
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                        Text(
                          "SDT: ${addr.sdtNhanHang}",
                          style: TextStyle(color: Colors.grey[700], fontSize: 14),
                        ),
                      ],
                    ),
                    secondary: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.edit, color: Colors.blue),
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
                    activeColor: Colors.blue,
                    controlAffinity: ListTileControlAffinity.leading,
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
                  backgroundColor: Colors.blue,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
                child: const Text(
                  "Thêm Địa Chỉ Mới",
                  style: TextStyle(fontSize: 16, color: Colors.white),
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
  const AddAddressScreen({super.key, this.address});

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
          style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildTextField(_sdtController, "Số điện thoại nhận hàng"),
              _buildTextField(_tenNguoiNhanController, "Tên người nhận"),
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
                    backgroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    widget.address == null ? "Lưu" : "Cập nhật",
                    style: const TextStyle(fontSize: 16, color: Colors.white),
                  ),
                ),
              ),
            ],
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
          labelText: label,
          labelStyle: const TextStyle(color: Colors.grey),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: Colors.grey[300]!),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: const BorderSide(color: Colors.blue),
          ),
          filled: true,
          fillColor: Colors.grey[50],
        ),
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