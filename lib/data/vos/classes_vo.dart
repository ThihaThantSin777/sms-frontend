class ClassesVO {
  final int id;
  final String className;
  final String classDescription;
  final String startTime;
  final String endTime;
  final int durationMonths;
  final int maxStudents;
  final String classLevel;
  final int teacherId;
  final String status;

  ClassesVO({
    required this.id,
    required this.className,
    required this.classDescription,
    required this.startTime,
    required this.endTime,
    required this.durationMonths,
    required this.maxStudents,
    required this.classLevel,
    required this.teacherId,
    required this.status,
  });

  factory ClassesVO.fromJson(Map<String, dynamic> json) {
    return ClassesVO(
      id: json['id'],
      className: json['class_name'],
      classDescription: json['class_description'],
      startTime: json['start_time'],
      endTime: json['end_time'],
      durationMonths: json['duration_months'],
      maxStudents: json['max_students'],
      classLevel: json['class_level'],
      teacherId: json['teacher_id'],
      status: json['status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'class_name': className,
      'class_description': classDescription,
      'start_time': startTime,
      'end_time': endTime,
      'duration_months': durationMonths,
      'max_students': maxStudents,
      'class_level': classLevel,
      'teacher_id': teacherId,
      'status': status,
    };
  }
}
