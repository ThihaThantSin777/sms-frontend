import 'package:flutter/material.dart';
import 'package:sms_frontend/data/vos/student_vo.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';

class StudentSearchPage extends StatefulWidget {
  const StudentSearchPage({super.key});

  @override
  State<StudentSearchPage> createState() => _StudentSearchPageState();
}

class _StudentSearchPageState extends State<StudentSearchPage> {
  final _api = SchoolApiService();
  List<StudentVO> _students = [];
  List<StudentVO> _filteredStudents = [];
  bool _isLoading = true;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadStudents();
  }

  Future<void> _loadStudents() async {
    setState(() => _isLoading = true);
    try {
      final students = await _api.getStudents();
      setState(() {
        _students = students;
        _filteredStudents = students;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      _showError(e.toString());
    }
  }

  void _search(String query) {
    setState(() {
      _filteredStudents = _students.where((s) => s.name?.toLowerCase().contains(query.toLowerCase()) ?? false).toList();
    });
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), backgroundColor: Colors.red));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Search Students'), backgroundColor: Colors.lightBlue),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search by name...',
                        prefixIcon: const Icon(Icons.search),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      onChanged: _search,
                    ),
                  ),
                  Expanded(
                    child:
                        _filteredStudents.isEmpty
                            ? const Center(child: Text('No students found'))
                            : ListView.separated(
                              itemCount: _filteredStudents.length,
                              separatorBuilder: (_, __) => const Divider(),
                              itemBuilder: (_, index) {
                                final student = _filteredStudents[index];
                                return ListTile(
                                  leading: CircleAvatar(child: Text(student.name?[0].toUpperCase() ?? '')),
                                  title: Text(student.name ?? ''),
                                  subtitle: Text('${student.email} | ${student.phone}'),
                                );
                              },
                            ),
                  ),
                ],
              ),
    );
  }
}
