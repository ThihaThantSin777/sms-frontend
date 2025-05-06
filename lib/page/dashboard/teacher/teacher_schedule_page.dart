import 'package:flutter/material.dart';
import 'package:sms_frontend/data/vos/classes_vo.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';
import 'package:sms_frontend/utils/extensions/snack_bar_extensions.dart';

class TeachingSchedulePage extends StatefulWidget {
  const TeachingSchedulePage({super.key});

  @override
  State<TeachingSchedulePage> createState() => _TeachingSchedulePageState();
}

class _TeachingSchedulePageState extends State<TeachingSchedulePage> {
  final _api = SchoolApiService();
  List<ClassesVO> _myClasses = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadSchedule();
  }

  Future<void> _loadSchedule() async {
    setState(() => _isLoading = true);
    try {
      final user = await _api.getLoginUser();
      final classes = await _api.getClasses();
      final filtered = classes.where((cls) => cls.teacherId == user?.id).toList();
      setState(() {
        _myClasses = filtered;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackBar('Failed to load schedule: $e');
      }
    }
  }

  Widget _buildClassCard(ClassesVO cls) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: ListTile(
        leading: const Icon(Icons.class_, color: Colors.blue),
        title: Text(cls.className, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Time: ${cls.startTime} - ${cls.endTime}"),
            Text("Level: ${cls.classLevel}"),
            Text("Duration: ${cls.durationMonths} months"),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teaching Schedule'), backgroundColor: Colors.lightBlue),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _myClasses.isEmpty
              ? const Center(child: Text('No teaching schedule available.'))
              : ListView.builder(itemCount: _myClasses.length, itemBuilder: (_, index) => _buildClassCard(_myClasses[index])),
    );
  }
}
