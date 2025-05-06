import 'package:flutter/material.dart';
import 'package:sms_frontend/data/vos/classes_vo.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';
import 'package:sms_frontend/utils/extensions/snack_bar_extensions.dart';

class StudentClassSchedulePage extends StatefulWidget {
  const StudentClassSchedulePage({super.key});

  @override
  State<StudentClassSchedulePage> createState() => _StudentClassSchedulePageState();
}

class _StudentClassSchedulePageState extends State<StudentClassSchedulePage> {
  final _api = SchoolApiService();
  List<ClassesVO> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadClassSchedules();
  }

  Future<void> _loadClassSchedules() async {
    setState(() => _isLoading = true);
    try {
      final allClasses = await _api.getClasses();
      setState(() {
        _classes = allClasses;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackBar('Failed to load class schedules: $e');
      }
    }
  }

  Widget _buildClassCard(ClassesVO cls) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        title: Text(cls.className, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Time: ${cls.startTime} - ${cls.endTime}"),
            Text("Level: ${cls.classLevel}"),
            Text("Duration: ${cls.durationMonths} months"),
          ],
        ),
        trailing: const Icon(Icons.calendar_today),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Class Schedule'), backgroundColor: Colors.lightBlue),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _classes.isEmpty
              ? const Center(child: Text('No class schedules found.'))
              : ListView.builder(itemCount: _classes.length, itemBuilder: (_, index) => _buildClassCard(_classes[index])),
    );
  }
}
