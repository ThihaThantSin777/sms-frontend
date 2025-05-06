import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_frontend/data/vos/classes_vo.dart';
import 'package:sms_frontend/data/vos/student_vo.dart';
import 'package:sms_frontend/data/vos/teacher_vo.dart';
import 'package:sms_frontend/data/vos/user_vo.dart';
import 'package:sms_frontend/network/response/base_response.dart';
import 'package:sms_frontend/network/response/error_response.dart';

class SchoolApiService {
  final Dio _dio = Dio(BaseOptions(baseUrl: 'http://192.168.1.37/sms-backend'));

  Future<UserVO> login(Map<String, dynamic> payload) async {
    try {
      final response = await _dio.post('/login.php', data: FormData.fromMap(payload));
      final data = response.data;

      if (data['status'] != 'success') {
        throw Exception(data['message'] ?? 'Login failed');
      }

      // Parse user VO
      final user = UserVO.fromJson(data['data']);
      // Save to SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', user.id.toString());
      await prefs.setString('user_name', user.name);
      await prefs.setString('user_email', user.email);
      await prefs.setString('user_phone', user.phone);
      await prefs.setString('user_role', user.role);
      await prefs.setString('user_create_at', user.createdAt);
      await prefs.setString('user_status', user.status);

      return user;
    } catch (e) {
      _handleError(e);
      rethrow;
    }
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_id');
    await prefs.remove('user_name');
    await prefs.remove('user_phone');
    await prefs.remove('user_email');
    await prefs.remove('user_role');
    await prefs.remove('user_create_at');
    await prefs.remove('user_status');
  }

  // -------------------- USERS --------------------

  Future<List<UserVO>> getUsers() async {
    try {
      final response = await _dio.get('/users/read_user.php');
      return BaseResponse<List<UserVO>>.fromJson(response.data, (json) => (json as List).map((e) => UserVO.fromJson(e)).toList()).data ??
          [];
    } catch (e) {
      _handleError(e);
    }
    return [];
  }

  Future<UserVO?> getLoginUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final id = prefs.getString('user_id');
      final name = prefs.getString('user_name');
      final phone = prefs.getString('user_phone');
      final email = prefs.getString('user_email');
      final role = prefs.getString('user_role');
      final createdAt = prefs.getString('user_create_at');
      final status = prefs.getString('user_status');

      if (id != null && name != null && email != null && role != null) {
        return UserVO(
          id: int.tryParse(id) ?? 0,
          name: name,
          email: email,
          phone: phone ?? '',
          role: role,
          createdAt: createdAt ?? "",
          status: status ?? '',
        );
      }

      return null;
    } catch (error) {
      _handleError(error);
      rethrow;
    }
  }

  Future<void> createUser(Map<String, dynamic> payload) async {
    await _postWithErrorHandling('/users/create_user.php', payload);
  }

  Future<void> updateUser(Map<String, dynamic> payload) async {
    await _postWithErrorHandling('/users/update_user.php', payload);
  }

  Future<void> deleteUser(int id) async {
    await _postWithErrorHandling('/users/delete_user.php', {'id': id});
  }

  // -------------------- STUDENTS --------------------

  Future<List<StudentVO>> getStudents() async {
    try {
      final response = await _dio.get('/students/read_student.php');
      return BaseResponse<List<StudentVO>>.fromJson(
            response.data,
            (json) =>
                (json as List).map((e) {
                  return StudentVO.fromJson(e);
                }).toList(),
          ).data ??
          [];
    } catch (e) {
      _handleError(e);
    }
    return [];
  }

  Future<void> createStudent(Map<String, dynamic> payload) async {
    await _postWithErrorHandling('/students/create_student.php', payload);
  }

  Future<void> updateStudent(Map<String, dynamic> payload) async {
    await _postWithErrorHandling('/students/update_student.php', payload);
  }

  Future<void> deleteStudent(int id) async {
    await _postWithErrorHandling('students/delete_student.php', {'id': id});
  }

  // -------------------- TEACHERS --------------------

  Future<List<TeachersVO>> getTeachers() async {
    try {
      final response = await _dio.get('/teachers/read_teacher.php');
      return BaseResponse<List<TeachersVO>>.fromJson(
            response.data,
            (json) =>
                (json as List).map((e) {
                  return TeachersVO.fromJson(e);
                }).toList(),
          ).data ??
          [];
    } catch (e) {
      _handleError(e);
    }
    return [];
  }

  Future<void> createTeacher(Map<String, dynamic> payload) async {
    await _postWithErrorHandling('/teachers/create_teacher.php', payload);
  }

  Future<void> updateTeacher(Map<String, dynamic> payload) async {
    await _postWithErrorHandling('/teachers/update_teacher.php', payload);
  }

  Future<void> deleteTeacher(int id) async {
    await _postWithErrorHandling('/teachers/delete_teacher.php', {'id': id});
  }

  // -------------------- CLASSES --------------------

  Future<List<ClassesVO>> getClasses() async {
    try {
      final response = await _dio.get('/classes/read_class.php');
      return BaseResponse<List<ClassesVO>>.fromJson(
            response.data,
            (json) => (json as List).map((e) => ClassesVO.fromJson(e)).toList(),
          ).data ??
          [];
    } catch (e) {
      _handleError(e);
    }
    return [];
  }

  Future<void> createClass(Map<String, dynamic> payload) async {
    await _postWithErrorHandling('/classes/create_class.php', payload);
  }

  Future<void> updateClass(Map<String, dynamic> payload) async {
    await _postWithErrorHandling('/classes/update_class.php', payload);
  }

  Future<void> deleteClass(int id) async {
    await _postWithErrorHandling('/classes/delete_class.php', {'id': id});
  }

  // -------------------- UTILITIES --------------------

  Future<void> _postWithErrorHandling(String endpoint, Map<String, dynamic> payload) async {
    try {
      await _dio.post(endpoint, data: FormData.fromMap(payload));
    } catch (e) {
      _handleError(e);
    }
  }

  void _handleError(Object e) {
    if (e is DioException && e.response != null && e.response!.data is Map<String, dynamic>) {
      final error = ErrorResponse.fromJson(e.response!.data);
      throw Exception(error.message);
    } else {
      throw Exception("Unexpected error: ${e.toString()}");
    }
  }
}
