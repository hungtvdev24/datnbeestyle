class Address {
  final int idDiaChi;
  final String sdtNhanHang;
  final String tenNguoiNhan;
  final String tenNha;
  final String tinh;
  final String huyen;
  final String xa;

  Address({
    required this.idDiaChi,
    required this.sdtNhanHang,
    required this.tenNguoiNhan,
    required this.tenNha,
    required this.tinh,
    required this.huyen,
    required this.xa,
  });

  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      idDiaChi: json['id_diaChi'],
      sdtNhanHang: json['sdt_nhanHang'],
      tenNguoiNhan: json['ten_nguoiNhan'],
      tenNha: json['ten_nha'],
      tinh: json['tinh'],
      huyen: json['huyen'],
      xa: json['xa'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_diaChi': idDiaChi,
      'sdt_nhanHang': sdtNhanHang,
      'ten_nguoiNhan': tenNguoiNhan,
      'ten_nha': tenNha,
      'tinh': tinh,
      'huyen': huyen,
      'xa': xa,
    };
  }
}
