class ClassesVO {
  final int id;
  final String className;
  final String classDescription;
  final String classDuration;
  final int teacherId;
  final String roomNumber;
  final String remark;

  ClassesVO({
    required this.id,
    required this.className,
    required this.classDescription,
    required this.classDuration,
    required this.teacherId,
    required this.roomNumber,
    required this.remark,
  });

  factory ClassesVO.fromJson(Map<String, dynamic> json) {
    return ClassesVO(
      id: json['id'],
      className: json['class_name'],
      classDescription: json['class_description'],
      classDuration: json['class_duration'],
      teacherId: json['teacher_id'],
      roomNumber: json['room_number'],
      remark: json['remark'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_name': className,
      'class_description': classDescription,
      'class_duration': classDuration,
      'teacher_id': teacherId,
      'room_number': roomNumber,
      'remark': remark,
    };
  }
}
