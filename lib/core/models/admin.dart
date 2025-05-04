class Admin {
  final int id;
  final String userNameAD;

  Admin({
    required this.id,
    required this.userNameAD,
  });

  factory Admin.fromJson(Map<String, dynamic> json) {
    return Admin(
      id: json['id'] ?? 0,
      userNameAD: json['userNameAD'] ?? 'Admin',
    );
  }
}