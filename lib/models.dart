class DanhMuc {
  String id;
  String name;

  DanhMuc(this.id, this.name);
}

class SanPham {
  String id;
  String name;
  double originalPrice;
  double price;
  String img;
  String des;
  int eval;
  String idDanhMuc;
  int quan;

  SanPham(this.id, this.name, this.originalPrice, this.price, this.img,
      this.des, this.eval, this.idDanhMuc, this.quan);
}