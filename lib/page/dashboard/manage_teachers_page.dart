import 'package:flutter/material.dart';
import 'package:sms_frontend/data/vos/teacher_vo.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';

class ManageTeachersPage extends StatefulWidget {
  const ManageTeachersPage({super.key});

  @override
  State<ManageTeachersPage> createState() => _ManageTeachersPageState();
}

class _ManageTeachersPageState extends State<ManageTeachersPage> {
  final _api = SchoolApiService();
  List<TeachersVO> _teachers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadTeachers();
  }

  Future<void> _loadTeachers() async {
    setState(() => _isLoading = true);
    try {
      final teachers = await _api.getTeachers();
      setState(() {
        _teachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  void _showTeacherFormDialog({TeachersVO? teacher}) {
    final now = DateTime.now();
    final initialDate = teacher?.joinedDate ?? "${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}";

    final nameController = TextEditingController(text: teacher?.name ?? '');
    final emailController = TextEditingController(text: teacher?.email ?? '');
    final phoneController = TextEditingController(text: teacher?.phone ?? '');
    final specializationController = TextEditingController(text: teacher?.specialization ?? '');
    final joinedDateController = TextEditingController(text: initialDate);

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(teacher == null ? 'Add Teacher' : 'Edit Teacher'),
            content: SizedBox(
              width: 400,
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                    TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                    TextField(controller: phoneController, decoration: const InputDecoration(labelText: 'Phone')),
                    TextField(controller: specializationController, decoration: const InputDecoration(labelText: 'Specialization')),
                    TextField(
                      controller: joinedDateController,
                      readOnly: true,
                      decoration: const InputDecoration(labelText: 'Joined Date'),
                      onTap: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: now,
                          firstDate: DateTime(2000),
                          lastDate: DateTime(2100),
                        );
                        if (picked != null) {
                          joinedDateController.text =
                              "${picked.year}-${picked.month.toString().padLeft(2, '0')}-${picked.day.toString().padLeft(2, '0')}";
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final data = {
                      'id': teacher?.id,
                      'name': nameController.text,
                      'email': emailController.text,
                      'phone': phoneController.text,
                      'specialization': specializationController.text,
                      'joined_date': joinedDateController.text,
                    }..removeWhere((key, value) => value == null);

                    if (teacher == null) {
                      await _api.createTeacher(data);
                    } else {
                      await _api.updateTeacher(data);
                    }

                    Navigator.pop(context);
                    _loadTeachers();
                  } catch (e) {
                    _showError(e.toString());
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _deleteTeacher(int id) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this teacher?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _api.deleteTeacher(id);
        _loadTeachers();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Widget _buildTeacherList() {
    return Card(
      margin: const EdgeInsets.all(16),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.lightBlue.shade100,
              borderRadius: const BorderRadius.vertical(top: Radius.circular(12)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Teachers", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Teacher"),
                  onPressed: () => _showTeacherFormDialog(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _teachers.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Text('No teachers to display'))
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _teachers.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final teacher = _teachers[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(teacher.name[0].toUpperCase())),
                    title: Text(teacher.name),
                    subtitle: Text("${teacher.specialization} | ${teacher.email}"),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _showTeacherFormDialog(teacher: teacher)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteTeacher(teacher.id)),
                      ],
                    ),
                  );
                },
              ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading ? const Center(child: CircularProgressIndicator()) : _buildTeacherList();
  }
}
