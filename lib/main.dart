import 'package:flutter/material.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';
import 'package:sms_frontend/page/auth/login_page.dart';
import 'package:sms_frontend/page/auth/register_page.dart';
import 'package:sms_frontend/page/dashboard/dashboard_page.dart';
import 'package:sms_frontend/page/dashboard/edit_info_page.dart';
import 'package:sms_frontend/page/dashboard/manage_classes_page.dart';
import 'package:sms_frontend/page/dashboard/manage_students_page.dart';
import 'package:sms_frontend/page/dashboard/manage_teachers_page.dart';
import 'package:sms_frontend/page/dashboard/manage_user_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  static const String routeLogin = '/login';
  static const String routeRegister = '/register';
  static const String routeDashboard = '/dashboard';
  static const String routeManageUser = '/manage-user';
  static const String routeManageTeachers = '/manage-teachers';
  static const String routeManageStudents = '/manage-students';
  static const String routeManageClasses = '/manage-classes';
  static const String routeEditInfo = '/edit-info';

  Future<bool> _isLoggedIn() async {
    final user = await SchoolApiService().getLoginUser();
    return user != null;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'School Management System',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue), useMaterial3: true),
      routes: {
        routeLogin: (_) => const LoginPage(),
        routeRegister: (_) => const RegisterPage(),
        routeDashboard: (_) => const DashboardPage(),
        routeManageUser: (_) => const ManageUserPage(),
        routeManageTeachers: (_) => const ManageTeachersPage(),
        routeManageStudents: (_) => const ManageStudentsPage(),
        routeManageClasses: (_) => const ManageClassesPage(),
        routeEditInfo: (_) => const EditInfoPage(),
      },
      home: FutureBuilder<bool>(
        future: _isLoggedIn(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          }
          return snapshot.data! ? const DashboardPage() : const LoginPage();
        },
      ),
    );
  }
}
