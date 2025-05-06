import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:sms_frontend/data/vos/classes_vo.dart';
import 'package:sms_frontend/data/vos/student_vo.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';
import 'package:sms_frontend/utils/extensions/navigation_extensions.dart';

class ManageStudentsPage extends StatefulWidget {
  const ManageStudentsPage({super.key});

  @override
  State<ManageStudentsPage> createState() => _ManageStudentsPageState();
}

class _ManageStudentsPageState extends State<ManageStudentsPage> {
  final _api = SchoolApiService();
  List<StudentVO> _students = [];
  List<ClassesVO> _classes = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _api.getStudents();
      final classes = await _api.getClasses();
      setState(() {
        _students = students;
        _classes = classes;
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

  void _showClassSelectorDialog(Function(int, String) onSelected) {
    final searchController = TextEditingController();
    List<ClassesVO> filteredClasses = List.from(_classes);

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Select Class'),
                  content: SizedBox(
                    width: 400,
                    height: 400,
                    child: Column(
                      children: [
                        TextField(
                          controller: searchController,
                          decoration: const InputDecoration(hintText: 'Search class name...', prefixIcon: Icon(Icons.search)),
                          onChanged: (query) {
                            setState(() {
                              filteredClasses = _classes.where((c) => c.className.toLowerCase().contains(query.toLowerCase())).toList();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child:
                              filteredClasses.isEmpty
                                  ? const Center(child: Text('No classes found.'))
                                  : ListView.builder(
                                    itemCount: filteredClasses.length,
                                    itemBuilder: (_, index) {
                                      final cls = filteredClasses[index];
                                      return ListTile(
                                        leading: CircleAvatar(child: Text(cls.className[0].toUpperCase())),
                                        title: Text(cls.className),
                                        subtitle: Text(cls.classDescription),
                                        onTap: () {
                                          Navigator.pop(context);
                                          onSelected(cls.id, cls.className);
                                        },
                                      );
                                    },
                                  ),
                        ),
                      ],
                    ),
                  ),
                  actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel'))],
                ),
          ),
    );
  }

  void _showStudentFormDialog({StudentVO? student}) {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: student?.name ?? '');
    final emailController = TextEditingController(text: student?.email ?? '');
    final phoneController = TextEditingController(text: student?.phone ?? '');
    final addressController = TextEditingController(text: student?.address ?? '');
    final guardianNameController = TextEditingController(text: student?.guardianName ?? '');
    final dateOfBirthController = TextEditingController(text: student?.dateOfBirth ?? DateFormat('yyyy-MM-dd').format(DateTime.now()));
    final passwordController = TextEditingController(); // only for new student
    String gender = student?.gender ?? 'Male';

    int? selectedClassId = student?.classId;
    String selectedClassName =
        _classes
            .firstWhere(
              (cls) => cls.id == selectedClassId,
              orElse:
                  () => ClassesVO(
                    id: 0,
                    className: '',
                    classDescription: '',
                    startTime: '',
                    endTime: '',
                    durationMonths: 0,
                    maxStudents: 0,
                    classLevel: '',
                    teacherId: 0,
                  ),
            )
            .className;

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: Text(student == null ? 'Add Student' : 'Edit Student'),
                  content: SizedBox(
                    width: 400,
                    child: Form(
                      key: formKey,
                      child: SingleChildScrollView(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(labelText: 'Name'),
                              validator: (val) => val == null || val.isEmpty ? 'Name is required' : null,
                            ),
                            TextFormField(
                              controller: emailController,
                              decoration: const InputDecoration(labelText: 'Email'),
                              validator: (val) => val == null || val.isEmpty ? 'Email is required' : null,
                            ),
                            TextFormField(
                              controller: phoneController,
                              decoration: const InputDecoration(labelText: 'Phone'),
                              validator: (val) => val == null || val.isEmpty ? 'Phone is required' : null,
                            ),
                            if (student == null)
                              TextFormField(
                                controller: passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(labelText: 'Password'),
                                validator: (val) => val == null || val.isEmpty ? 'Password is required' : null,
                              ),
                            TextFormField(
                              controller: dateOfBirthController,
                              readOnly: true,
                              decoration: const InputDecoration(labelText: 'Date of Birth'),
                              validator: (val) => val == null || val.isEmpty ? 'Date of Birth is required' : null,
                              onTap: () async {
                                final picked = await showDatePicker(
                                  context: context,
                                  initialDate: DateTime.now(),
                                  firstDate: DateTime(1990),
                                  lastDate: DateTime(2100),
                                );
                                if (picked != null) {
                                  dateOfBirthController.text = DateFormat('yyyy-MM-dd').format(picked);
                                }
                              },
                            ),
                            Row(
                              children: [
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Male'),
                                    value: 'Male',
                                    groupValue: gender,
                                    onChanged: (val) => setState(() => gender = val!),
                                  ),
                                ),
                                Expanded(
                                  child: RadioListTile<String>(
                                    title: const Text('Female'),
                                    value: 'Female',
                                    groupValue: gender,
                                    onChanged: (val) => setState(() => gender = val!),
                                  ),
                                ),
                              ],
                            ),
                            TextFormField(
                              controller: addressController,
                              decoration: const InputDecoration(labelText: 'Address'),
                              validator: (val) => val == null || val.isEmpty ? 'Address is required' : null,
                            ),
                            TextFormField(
                              controller: guardianNameController,
                              decoration: const InputDecoration(labelText: 'Guardian Name'),
                              validator: (val) => val == null || val.isEmpty ? 'Guardian Name is required' : null,
                            ),
                            SizedBox(
                              width: double.infinity,
                              child: TextButton.icon(
                                icon: const Icon(Icons.class_),
                                label: Text(
                                  selectedClassId != null && selectedClassName.isNotEmpty ? selectedClassName : 'Select Class *',
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onPressed:
                                    () => _showClassSelectorDialog((id, name) {
                                      setState(() {
                                        selectedClassId = id;
                                        selectedClassName = name;
                                      });
                                    }),
                              ),
                            ),
                            if (selectedClassId == null)
                              const Align(
                                alignment: Alignment.centerLeft,
                                child: Padding(
                                  padding: EdgeInsets.only(top: 4),
                                  child: Text('You need to select a class', style: TextStyle(color: Colors.red, fontSize: 12)),
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  actions: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () async {
                        if ((formKey.currentState?.validate() ?? false) && selectedClassId != null) {
                          try {
                            final data = {
                              'name': nameController.text,
                              'email': emailController.text,
                              'phone': phoneController.text,
                              if (student == null) 'password': passwordController.text,
                              'date_of_birth': dateOfBirthController.text,
                              'class_id': selectedClassId.toString(),
                              'gender': gender,
                              'address': addressController.text,
                              'guardian_name': guardianNameController.text,
                            };

                            if (student == null) {
                              await _api.createStudent(data);
                            } else {
                              await _api.updateStudent(data);
                            }

                            if (context.mounted) {
                              context.navigateBack();
                              _loadStudents();
                            }
                          } catch (e) {
                            _showError(e.toString());
                          }
                        }
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
          ),
    );
  }

  void _deleteStudent(int id) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this student?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _api.deleteStudent(id);
        _loadStudents();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Widget _buildStudentList() {
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
                const Text("Students", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton.icon(
                  icon: const Icon(Icons.add),
                  label: const Text("Add Student"),
                  onPressed: () => _showStudentFormDialog(),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          _students.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Text('No students to display'))
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _students.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final student = _students[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(student.name?[0].toUpperCase() ?? '')),
                    title: Text(student.name ?? ''),
                    subtitle: Text("${student.email} | ${student.phone}"),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _showStudentFormDialog(student: student)),
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteStudent(student.id)),
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
    return _isLoading ? const Center(child: CircularProgressIndicator()) : _buildStudentList();
  }
}
