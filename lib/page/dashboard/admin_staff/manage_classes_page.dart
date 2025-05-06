import 'package:flutter/material.dart';
import 'package:sms_frontend/data/vos/classes_vo.dart';
import 'package:sms_frontend/data/vos/teacher_vo.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';
import 'package:sms_frontend/utils/extensions/navigation_extensions.dart';
import 'package:sms_frontend/utils/extensions/snack_bar_extensions.dart';

class ManageClassesPage extends StatefulWidget {
  const ManageClassesPage({super.key});

  @override
  State<ManageClassesPage> createState() => _ManageClassesPageState();
}

class _ManageClassesPageState extends State<ManageClassesPage> {
  final _api = SchoolApiService();
  List<ClassesVO> _classes = [];
  List<TeachersVO> _teachers = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    setState(() => _isLoading = true);
    try {
      final classes = await _api.getClasses();
      final teachers = await _api.getTeachers();
      setState(() {
        _classes = classes;
        _teachers = teachers;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackBar(e.toString());
      }
    }
  }

  void _showTeacherSelectorDialog(Function(int, String) onSelected) {
    final searchController = TextEditingController();
    List<TeachersVO> filteredTeachers = List.from(_teachers);

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder:
                (context, setState) => AlertDialog(
                  title: const Text('Select Teacher'),
                  content: SizedBox(
                    width: 400,
                    height: 400,
                    child: Column(
                      children: [
                        TextField(
                          controller: searchController,
                          decoration: const InputDecoration(hintText: 'Search by name...', prefixIcon: Icon(Icons.search)),
                          onChanged: (query) {
                            setState(() {
                              filteredTeachers = _teachers.where((t) => t.name.toLowerCase().contains(query.toLowerCase())).toList();
                            });
                          },
                        ),
                        const SizedBox(height: 10),
                        Expanded(
                          child:
                              filteredTeachers.isEmpty
                                  ? const Center(child: Text('No teachers found.'))
                                  : ListView.builder(
                                    itemCount: filteredTeachers.length,
                                    itemBuilder: (_, index) {
                                      final teacher = filteredTeachers[index];
                                      return ListTile(
                                        leading: CircleAvatar(child: Text(teacher.name[0])),
                                        title: Text(teacher.name),
                                        subtitle: Text(teacher.specialization),
                                        onTap: () {
                                          Navigator.pop(context);
                                          onSelected(teacher.id, teacher.name);
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

  void _showClassFormDialog({ClassesVO? classVO}) {
    final formKey = GlobalKey<FormState>();
    final nameController = TextEditingController(text: classVO?.className ?? '');
    final descriptionController = TextEditingController(text: classVO?.classDescription ?? '');
    final durationController = TextEditingController(text: classVO?.durationMonths.toString() ?? '');
    final maxStudentsController = TextEditingController(text: classVO?.maxStudents.toString() ?? '');
    String classLevel = classVO?.classLevel ?? 'Beginner';
    String status = classVO?.status.toLowerCase() ?? 'active';

    TimeOfDay? localStartTime;
    TimeOfDay? localEndTime;
    int? selectedTeacherId = classVO?.teacherId;
    String selectedTeacherName = '';

    if (classVO?.startTime != null && classVO?.endTime != null) {
      final startParts = classVO!.startTime.split(':');
      final endParts = classVO.endTime.split(':');
      localStartTime = TimeOfDay(hour: int.parse(startParts[0]), minute: int.parse(startParts[1]));
      localEndTime = TimeOfDay(hour: int.parse(endParts[0]), minute: int.parse(endParts[1]));
    }

    showDialog(
      context: context,
      builder:
          (_) => StatefulBuilder(
            builder: (context, setState) {
              String formatTime(TimeOfDay? time) => time?.format(context) ?? '';

              Future<void> pickTime(bool isStart) async {
                final picked = await showTimePicker(context: context, initialTime: TimeOfDay.now());
                if (picked != null) {
                  setState(() {
                    if (isStart) {
                      localStartTime = picked;
                    } else {
                      localEndTime = picked;
                    }
                  });
                }
              }

              return AlertDialog(
                title: Text(classVO == null ? 'Add Class' : 'Edit Class'),
                content: SizedBox(
                  width: 400,
                  child: Form(
                    key: formKey,
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          TextFormField(
                            controller: nameController,
                            decoration: const InputDecoration(labelText: 'Class Name *'),
                            validator: (val) => val == null || val.isEmpty ? 'Class name is required' : null,
                          ),
                          TextFormField(
                            controller: descriptionController,
                            decoration: const InputDecoration(labelText: 'Description *'),
                            maxLines: 3,
                            validator: (val) => val == null || val.isEmpty ? 'Description is required' : null,
                          ),
                          Row(
                            children: [
                              Expanded(
                                child: TextButton.icon(
                                  icon: const Icon(Icons.access_time),
                                  label: Text(formatTime(localStartTime).isNotEmpty ? formatTime(localStartTime) : 'Start Time *'),
                                  onPressed: () => pickTime(true),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: TextButton.icon(
                                  icon: const Icon(Icons.access_time_outlined),
                                  label: Text(formatTime(localEndTime).isNotEmpty ? formatTime(localEndTime) : 'End Time *'),
                                  onPressed: () => pickTime(false),
                                ),
                              ),
                            ],
                          ),
                          if (localStartTime == null || localEndTime == null)
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text("Start and End time are required", style: TextStyle(color: Colors.red, fontSize: 12)),
                            ),
                          TextFormField(
                            controller: durationController,
                            decoration: const InputDecoration(labelText: 'Duration (months) *'),
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? 'Duration is required' : null,
                          ),
                          TextFormField(
                            controller: maxStudentsController,
                            decoration: const InputDecoration(labelText: 'Max Students *'),
                            keyboardType: TextInputType.number,
                            validator: (val) => val == null || val.isEmpty ? 'Max students is required' : null,
                          ),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Class Level *'),
                            value: classLevel,
                            items:
                                [
                                  'Beginner',
                                  'Intermediate',
                                  'Advanced',
                                ].map((level) => DropdownMenuItem(value: level, child: Text(level))).toList(),
                            onChanged: (val) => setState(() => classLevel = val ?? 'Beginner'),
                          ),
                          DropdownButtonFormField<String>(
                            decoration: const InputDecoration(labelText: 'Status *'),
                            value: status,
                            items: ['active', 'inactive'].map((s) => DropdownMenuItem(value: s, child: Text(s))).toList(),
                            onChanged: (val) => setState(() => status = val ?? 'active'),
                          ),
                          SizedBox(
                            width: double.infinity,
                            child: TextButton.icon(
                              icon: const Icon(Icons.person_search),
                              label: Text(
                                selectedTeacherId != null
                                    ? selectedTeacherName.isNotEmpty
                                        ? selectedTeacherName
                                        : (_teachers
                                            .firstWhere(
                                              (t) => t.id == selectedTeacherId,
                                              orElse:
                                                  () => TeachersVO(
                                                    id: 0,
                                                    name: '',
                                                    email: '',
                                                    phone: '',
                                                    specialization: '',
                                                    joinedDate: '',
                                                    experienceYears: 0,
                                                    qualification: '',
                                                    status: '',
                                                  ),
                                            )
                                            .name)
                                    : 'Select Teacher *',
                                overflow: TextOverflow.ellipsis,
                              ),
                              onPressed: () {
                                _showTeacherSelectorDialog((id, name) {
                                  setState(() {
                                    selectedTeacherId = id;
                                    selectedTeacherName = name;
                                  });
                                });
                              },
                            ),
                          ),
                          if (selectedTeacherId == null)
                            const Align(
                              alignment: Alignment.centerLeft,
                              child: Text("You need to select a teacher.", style: TextStyle(color: Colors.red, fontSize: 12)),
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
                      if ((formKey.currentState?.validate() ?? false) &&
                          localStartTime != null &&
                          localEndTime != null &&
                          selectedTeacherId != null) {
                        try {
                          final data = {
                            'id': classVO?.id,
                            'class_name': nameController.text,
                            'class_description': descriptionController.text,
                            'start_time':
                                "${localStartTime?.hour.toString().padLeft(2, '0')}:${localStartTime?.minute.toString().padLeft(2, '0')}",
                            'end_time':
                                "${localEndTime?.hour.toString().padLeft(2, '0')}:${localEndTime?.minute.toString().padLeft(2, '0')}",
                            'duration_months': durationController.text,
                            'max_students': maxStudentsController.text,
                            'class_level': classLevel,
                            'teacher_id': selectedTeacherId.toString(),
                            'status': status,
                          }..removeWhere((k, v) => v == null || v.toString().isEmpty);

                          if (classVO == null) {
                            await _api.createClass(data);
                          } else {
                            await _api.updateClass(data);
                          }

                          if (context.mounted) {
                            context.navigateBack();
                            _loadData();
                          }
                        } catch (e) {
                          if (context.mounted) context.showErrorSnackBar(e.toString());
                        }
                      }
                    },
                    child: const Text('Save'),
                  ),
                ],
              );
            },
          ),
    );
  }

  void _deactivateClass(ClassesVO classes) async {
    final isCurrentlyActive = classes.status.toLowerCase() == 'active';
    final newStatus = isCurrentlyActive ? 'inactive' : 'active';
    final actionLabel = isCurrentlyActive ? 'Deactivate' : 'Activate';

    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Confirm $actionLabel'),
            content: Text('Are you sure you want to $actionLabel this class?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(actionLabel)),
            ],
          ),
    );

    if (confirm == true) {
      try {
        final data = {
          'id': classes.id,
          'class_name': classes.className,
          'class_description': classes.classDescription,
          'start_time': classes.startTime,
          'end_time': classes.endTime,
          'duration_months': classes.durationMonths,
          'max_students': classes.maxStudents,
          'class_level': classes.classLevel,
          'teacher_id': classes.teacherId,
          'status': newStatus,
        }..removeWhere((k, v) => v.toString().isEmpty);

        await _api.updateClass(data);
        _loadData();
      } catch (e) {
        if (mounted) {
          context.showErrorSnackBar(e.toString());
        }
      }
    }
  }

  Widget _buildClassList() {
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
                const Text("Classes", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text("Add Class"), onPressed: () => _showClassFormDialog()),
              ],
            ),
          ),
          const Divider(height: 1),
          _classes.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Text('No classes to display'))
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _classes.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final classVO = _classes[index];
                  final isInactive = classVO.status.toLowerCase() == 'inactive';

                  return Container(
                    color: isInactive ? Colors.grey.shade100 : null,
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: isInactive ? Colors.grey : Colors.blue,
                        child: Text(classVO.className[0].toUpperCase(), style: TextStyle(color: Colors.white)),
                      ),
                      title: Text(
                        classVO.className,
                        style: TextStyle(
                          color: isInactive ? Colors.grey : Colors.black,
                          fontStyle: isInactive ? FontStyle.italic : FontStyle.normal,
                        ),
                      ),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("${classVO.classDescription} | Duration: ${classVO.durationMonths} month(s)"),
                          if (isInactive)
                            const Text('INACTIVE', style: TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                        ],
                      ),
                      trailing: Wrap(
                        spacing: 8,
                        children: [
                          IconButton(icon: const Icon(Icons.edit), onPressed: () => _showClassFormDialog(classVO: classVO)),
                          IconButton(
                            icon: Icon(
                              classVO.status.toLowerCase() == 'inactive' ? Icons.check_circle : Icons.block,
                              color: classVO.status.toLowerCase() == 'inactive' ? Colors.green : Colors.red,
                            ),
                            tooltip: classVO.status.toLowerCase() == 'inactive' ? 'Activate' : 'Deactivate',
                            onPressed: () => _deactivateClass(classVO),
                          ),
                        ],
                      ),
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
    return _isLoading ? const Center(child: CircularProgressIndicator()) : _buildClassList();
  }
}
