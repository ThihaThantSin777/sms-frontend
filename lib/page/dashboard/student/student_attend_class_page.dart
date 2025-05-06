import 'package:flutter/material.dart';
import 'package:sms_frontend/data/vos/classes_vo.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';
import 'package:sms_frontend/utils/extensions/snack_bar_extensions.dart';

class StudentAttendClassPage extends StatefulWidget {
  const StudentAttendClassPage({super.key});

  @override
  State<StudentAttendClassPage> createState() => _StudentAttendClassPageState();
}

class _StudentAttendClassPageState extends State<StudentAttendClassPage> {
  final _api = SchoolApiService();
  ClassesVO? _attendingClass;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAttendClass();
  }

  Future<void> _loadAttendClass() async {
    setState(() => _isLoading = true);
    try {
      final user = await _api.getLoginUser();
      final students = await _api.getStudents();
      final currentStudent = students.firstWhere((s) => s.userId == user?.id);
      final allClasses = await _api.getClasses();
      final attendClass = allClasses.firstWhere((cls) => cls.id == currentStudent.classId);

      setState(() {
        _attendingClass = attendClass;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackBar('Failed to load attending class: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Current Attending Class'), backgroundColor: Colors.lightBlue),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _attendingClass == null
              ? const Center(child: Text('No attending class found.'))
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Class Name: ${_attendingClass!.className}",
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        Text("Time: ${_attendingClass!.startTime} - ${_attendingClass!.endTime}"),
                        Text("Level: ${_attendingClass!.classLevel}"),
                        Text("Duration: ${_attendingClass!.durationMonths} months"),
                        Text("Description: ${_attendingClass!.classDescription}"),
                      ],
                    ),
                  ),
                ),
              ),
    );
  }
}
