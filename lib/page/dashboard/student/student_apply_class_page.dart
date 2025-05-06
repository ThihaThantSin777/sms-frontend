import 'package:flutter/material.dart';
import 'package:sms_frontend/data/vos/classes_vo.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';

class StudentApplyClassesPage extends StatefulWidget {
  const StudentApplyClassesPage({super.key});

  @override
  State<StudentApplyClassesPage> createState() => _StudentApplyClassesPageState();
}

class _StudentApplyClassesPageState extends State<StudentApplyClassesPage> {
  final _api = SchoolApiService();
  List<ClassesVO> _classes = [];
  bool _isLoading = true;
  final Set<int> _appliedClassIds = {};

  @override
  void initState() {
    super.initState();
    _loadClasses();
  }

  Future<void> _loadClasses() async {
    setState(() => _isLoading = true);
    try {
      final classes = await _api.getClasses();
      setState(() {
        _classes = classes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Failed to load classes: $e")));
    }
  }

  void _applyToClass(int classId) {
    setState(() {
      _appliedClassIds.add(classId);
    });

    // Optionally: call an API to save application to backend.
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Applied to class ID: $classId")));
  }

  Widget _buildClassCard(ClassesVO cls) {
    final isApplied = _appliedClassIds.contains(cls.id);
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      elevation: 3,
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
        trailing: ElevatedButton(
          onPressed: isApplied ? null : () => _applyToClass(cls.id),
          style: ElevatedButton.styleFrom(backgroundColor: isApplied ? Colors.grey : Colors.blue),
          child: Text(isApplied ? 'Applied' : 'Apply'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Apply for Classes'), backgroundColor: Colors.lightBlue),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : _classes.isEmpty
              ? const Center(child: Text('No classes available to apply.'))
              : ListView.builder(itemCount: _classes.length, itemBuilder: (_, index) => _buildClassCard(_classes[index])),
    );
  }
}
