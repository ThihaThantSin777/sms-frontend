import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sms_frontend/main.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';
import 'package:sms_frontend/utils/extensions/navigation_extensions.dart';
import 'package:sms_frontend/utils/extensions/snack_bar_extensions.dart';

class EditInfoPage extends StatefulWidget {
  const EditInfoPage({super.key});

  @override
  State<EditInfoPage> createState() => _EditInfoPageState();
}

class _EditInfoPageState extends State<EditInfoPage> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    final userData = await SchoolApiService().getLoginUser();
    if (userData != null) {
      _nameController.text = userData.name;
      _emailController.text = userData.email;
    }
  }

  Future<void> _saveUserData() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    final userData = await SchoolApiService().getLoginUser();
    if (userData == null) {
      setState(() => _isLoading = false);
      if (mounted) {
        context.showErrorSnackBar("User not found");
      }
      return;
    }

    final updatedPassword = {"id": userData.id.toString(), if (_passwordController.text.isNotEmpty) "password": _passwordController.text};

    final updatedData = {
      "id": userData.id.toString(),
      "name": _nameController.text,
      "email": _emailController.text,
      "phone": userData.phone,
      "role": userData.role,
      "status": userData.status,
      if (_passwordController.text.isNotEmpty) "password": _passwordController.text,
    };

    try {
      await SchoolApiService().updateUser(updatedPassword);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('user_id', updatedData["id"] ?? '');
      await prefs.setString('user_name', updatedData["name"] ?? '');
      await prefs.setString('user_email', updatedData["email"] ?? '');
      await prefs.setString('user_phone', updatedData["phone"] ?? '');
      await prefs.setString('user_role', updatedData["role"] ?? '');
      await prefs.setString('user_status', updatedData["status"] ?? '');

      if (mounted) {
        context.showSuccessSnackBar('Info updated successfully');
        context.navigateToNextPageWithRemoveUntil(MyApp.routeLogin);
      }
    } catch (e) {
      if (mounted) context.showErrorSnackBar(e.toString());
    }

    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Profile')),
      body:
          _isLoading
              ? const Center(child: CircularProgressIndicator())
              : Padding(
                padding: const EdgeInsets.all(16),
                child: Form(
                  key: _formKey,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'Name'),
                        validator: (value) => value!.isEmpty ? 'Name is required' : null,
                      ),
                      TextFormField(
                        controller: _emailController,
                        decoration: const InputDecoration(labelText: 'Email'),
                        validator: (value) => value!.isEmpty || !value.contains('@') ? 'Valid email is required' : null,
                      ),
                      TextFormField(
                        controller: _passwordController,
                        decoration: const InputDecoration(labelText: 'New Password (optional)'),
                        obscureText: true,
                        validator: (value) {
                          if (value != null && value.isNotEmpty && value.length < 8) {
                            return 'Password must be at least 8 characters';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 20),
                      ElevatedButton.icon(onPressed: _saveUserData, icon: const Icon(Icons.save), label: const Text('Save')),
                    ],
                  ),
                ),
              ),
    );
  }
}
