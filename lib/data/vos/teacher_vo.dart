class TeachersVO {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String specialization;
  final String joinedDate;

  TeachersVO({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.specialization,
    required this.joinedDate,
  });

  factory TeachersVO.fromJson(Map<String, dynamic> json) {
    return TeachersVO(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      specialization: json['specialization'],
      joinedDate: json['joined_date'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'phone': phone, 'specialization': specialization, 'joined_date': joinedDate};
  }
}
