class UserVO {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String role;
  final String status;
  final String createdAt;

  UserVO({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    required this.status,
    required this.createdAt,
  });

  factory UserVO.fromJson(Map<String, dynamic> json) {
    return UserVO(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      status: json['status'],
      createdAt: json['created_at'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'phone': phone, 'role': role, 'created_at': createdAt};
  }

  @override
  String toString() {
    return 'UserVO{id: $id, name: $name, email: $email, phone: $phone, role: $role, createdAt: $createdAt}';
  }
}
