import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:sms_frontend/data/vos/user_vo.dart';
import 'package:sms_frontend/main.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';
import 'package:sms_frontend/utils/extensions/navigation_extensions.dart';
import 'package:sms_frontend/widgets/responsive_layout.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final _api = SchoolApiService();
  UserVO? _currentUser;
  int userCount = 0;
  int studentCount = 0;
  int teacherCount = 0;
  int classCount = 0;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final user = await _api.getLoginUser();
      final users = await _api.getUsers();
      final students = await _api.getStudents();
      final teachers = await _api.getTeachers();
      final classes = await _api.getClasses();

      setState(() {
        _currentUser = user;
        userCount = users.length;
        studentCount = students.length;
        teacherCount = teachers.length;
        classCount = classes.length;
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _logout() async {
    await _api.logout();
    if (mounted) {
      Navigator.of(context).pushReplacementNamed(MyApp.routeLogin);
    }
  }

  List<PieChartSectionData> _generatePieSections() {
    final sections = <PieChartSectionData>[];
    if (classCount > 0) sections.add(PieChartSectionData(value: classCount.toDouble(), title: 'Classes', color: Colors.blue.shade300));
    if (studentCount > 0) {
      sections.add(PieChartSectionData(value: studentCount.toDouble(), title: 'Students', color: Colors.green.shade400));
    }
    if (teacherCount > 0) {
      sections.add(PieChartSectionData(value: teacherCount.toDouble(), title: 'Teachers', color: Colors.orange.shade400));
    }
    if (_currentUser?.role == 'admin' && userCount > 0) {
      sections.add(PieChartSectionData(value: userCount.toDouble(), title: 'Users', color: Colors.purple.shade400));
    }
    return sections;
  }

  Widget _buildTopBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: Colors.lightBlue.shade100,
      child: Row(
        children: [
          Image.asset('assets/logo.jpeg', height: 20),
          const SizedBox(width: 20),
          Text("Dashboard", style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold)),
          Spacer(),
          Row(
            children: [
              if (_currentUser != null)
                Row(
                  children: [
                    CircleAvatar(child: Text(_currentUser!.name[0])),
                    const SizedBox(width: 12),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(_currentUser!.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        Text(_currentUser!.role, style: const TextStyle(color: Colors.grey)),
                      ],
                    ),
                    const SizedBox(width: 20),
                    TextButton.icon(
                      onPressed: () {
                        context.navigateToNextPage(MyApp.routeEditInfo);
                      },
                      icon: const Icon(Icons.edit, size: 16),
                      label: const Text("Edit Info"),
                    ),
                  ],
                ),
              const SizedBox(width: 20),
              ElevatedButton.icon(
                onPressed: _logout,
                icon: const Icon(Icons.logout),
                label: const Text("Logout"),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, IconData icon, int count, Color color) {
    return Card(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      color: color,
      margin: const EdgeInsets.all(8),
      child: Container(
        padding: const EdgeInsets.all(16),
        width: 180,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, size: 32, color: Colors.white),
            const SizedBox(height: 12),
            Text(title, style: const TextStyle(color: Colors.white70, fontSize: 14)),
            Text('$count', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 24)),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCardsRow() {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [
          if (_currentUser?.role == 'admin')
            _buildStatCard(_currentUser?.role == 'admin' ? "Admin" : "Staff", Icons.supervisor_account, userCount, Colors.purple.shade400),
          if (_currentUser?.role == 'admin') _buildStatCard("Teachers", Icons.school, teacherCount, Colors.orange.shade400),
          if (_currentUser?.role == 'admin') _buildStatCard("Students", Icons.group, studentCount, Colors.green.shade400),
          if (_currentUser?.role == 'admin') _buildStatCard("Classes", Icons.class_, classCount, Colors.blue.shade300),
        ],
      ),
    );
  }

  Widget _buildPieChart() {
    final pieSections = _generatePieSections();
    return pieSections.isEmpty
        ? const SizedBox.shrink()
        : Card(
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          margin: const EdgeInsets.all(16),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text("System Overview", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                const SizedBox(height: 12),
                SizedBox(
                  width: 300,
                  height: 300,
                  child: PieChart(PieChartData(sections: pieSections, sectionsSpace: 4, centerSpaceRadius: 40)),
                ),
              ],
            ),
          ),
        );
  }

  Widget _buildNavCard(String label, IconData icon, VoidCallback onTap) {
    return Card(
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: Icon(icon, color: Colors.lightBlue.shade600),
        title: Text(label, style: const TextStyle(fontWeight: FontWeight.w600)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDashboardContent(double width) {
    return Column(
      children: [
        _buildTopBar(),
        Expanded(
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : ListView(
                    children: [
                      const SizedBox(height: 8),
                      _buildStatCardsRow(),
                      _buildPieChart(),
                      if (_currentUser?.role == 'admin')
                        _buildNavCard("Manage Staff", Icons.supervisor_account, () {
                          context.navigateToNextPage(MyApp.routeManageUser);
                        }),
                      if (_currentUser?.role == 'admin')
                        _buildNavCard("Manage Teachers", Icons.school, () {
                          context.navigateToNextPage(MyApp.routeManageTeachers);
                        }),
                      if (_currentUser?.role == 'teacher')
                        _buildNavCard("Search Students", Icons.search, () {
                          context.navigateToNextPage(MyApp.routeStudentSearch);
                        }),
                      if (_currentUser?.role == 'teacher')
                        _buildNavCard("Teaching Schedule", Icons.schedule, () {
                          context.navigateToNextPage(MyApp.routeTeacherSchedule);
                        }),
                      if (_currentUser?.role == 'student')
                        _buildNavCard("My Class", Icons.class_, () {
                          context.navigateToNextPage(MyApp.routeStudentAttendClass);
                        }),
                      if (_currentUser?.role == 'student')
                        _buildNavCard("Class Schedule", Icons.event, () {
                          context.navigateToNextPage(MyApp.routeStudentClassSchedule);
                        }),
                      if (_currentUser?.role == 'student')
                        _buildNavCard("Available Classes", Icons.list_alt, () {
                          context.navigateToNextPage(MyApp.routeStudentApplyClass);
                        }),
                      if (_currentUser?.role == 'admin' || _currentUser?.role == 'staff')
                        _buildNavCard("Manage Students", Icons.group, () {
                          context.navigateToNextPage(MyApp.routeManageStudents);
                        }),
                      if (_currentUser?.role == 'admin' || _currentUser?.role == 'staff')
                        _buildNavCard("Manage Classes", Icons.class_, () {
                          context.navigateToNextPage(MyApp.routeManageClasses);
                        }),
                    ],
                  ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.lightBlue.shade50,
      body: ResponsiveLayout(
        mobile: _buildDashboardContent(MediaQuery.of(context).size.width),
        tablet: _buildDashboardContent(700),
        desktop: _buildDashboardContent(1000),
      ),
    );
  }
}
