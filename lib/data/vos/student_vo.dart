class StudentVO {
  final int id;
  final String name;
  final String email;
  final String phone;
  final String dateOfBirth;
  final int classId;

  StudentVO({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.dateOfBirth,
    required this.classId,
  });

  factory StudentVO.fromJson(Map<String, dynamic> json) {
    return StudentVO(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      dateOfBirth: json['date_of_birth'],
      classId: json['class_id'],
    );
  }

  Map<String, dynamic> toJson() {
    return {'id': id, 'name': name, 'email': email, 'phone': phone, 'date_of_birth': dateOfBirth, 'class_id': classId};
  }
}
