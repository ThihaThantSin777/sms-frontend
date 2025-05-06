class StudentVO {
  final int id;
  final int classId;
  final String dateOfBirth;
  final String gender;
  final String address;
  final String guardianName;
  final int userId;

  String? name;
  String? email;
  String? phone;

  StudentVO({
    required this.id,
    required this.classId,
    required this.dateOfBirth,
    required this.gender,
    required this.address,
    required this.guardianName,
    required this.userId,
    this.name,
    this.email,
    this.phone,
  });

  factory StudentVO.fromJson(Map<String, dynamic> json) {
    return StudentVO(
      id: json['id'],
      classId: json['class_id'],
      dateOfBirth: json['date_of_birth'],
      gender: json['gender'],
      address: json['address'],
      guardianName: json['guardian_name'],
      userId: json['user_id'],
      email: json['email'],
      name: json['name'],
      phone: json['phone'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_id': classId,
      'date_of_birth': dateOfBirth,
      'gender': gender,
      'address': address,
      'guardian_name': guardianName,
      'user_id': userId,
    };
  }
}
