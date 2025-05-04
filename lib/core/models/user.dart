class User {
  final int id;
  final String name;
  final String email;
  final String? phone;
  final int? tuoi;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.phone,
    this.tuoi,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      phone: json['phone'],
      tuoi: json['tuoi'],
    );
  }
}