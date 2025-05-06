import 'package:flutter/material.dart';
import 'package:sms_frontend/data/vos/user_vo.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';
import 'package:sms_frontend/utils/extensions/navigation_extensions.dart';

class ManageUserPage extends StatefulWidget {
  const ManageUserPage({super.key});

  @override
  State<ManageUserPage> createState() => _ManageUserPageState();
}

class _ManageUserPageState extends State<ManageUserPage> {
  final _api = SchoolApiService();
  List<UserVO> _users = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  Future<void> _loadUsers() async {
    setState(() => _isLoading = true);
    try {
      final currentUser = await _api.getLoginUser();
      final users = await _api.getUsers();
      setState(() {
        _users = users.where((u) => u.id != currentUser?.id).toList();
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

  void _showUserFormDialog({UserVO? user}) {
    final formKey = GlobalKey<FormState>();

    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final phoneController = TextEditingController(text: user?.phone ?? '');
    final passwordController = TextEditingController();
    String role = user?.role ?? 'staff';
    String status = user?.status ?? 'active';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(user == null ? 'Add User' : 'Edit User'),
            content: SizedBox(
              width: 400,
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: const InputDecoration(labelText: 'Name'),
                      validator: (value) => value == null || value.isEmpty ? 'Name is required' : null,
                    ),
                    TextFormField(
                      controller: emailController,
                      decoration: const InputDecoration(labelText: 'Email'),
                      validator: (value) => value == null || value.isEmpty ? 'Email is required' : null,
                    ),
                    TextFormField(
                      controller: phoneController,
                      decoration: const InputDecoration(labelText: 'Phone'),
                      validator: (value) => value == null || value.isEmpty ? 'Phone is required' : null,
                    ),
                    if (user == null)
                      TextFormField(
                        controller: passwordController,
                        obscureText: true,
                        decoration: const InputDecoration(labelText: 'Password'),
                        validator: (value) => value == null || value.isEmpty ? 'Password is required' : null,
                      ),
                    DropdownButtonFormField<String>(
                      value: role,
                      decoration: const InputDecoration(labelText: 'Role'),
                      items: const [
                        DropdownMenuItem(value: 'admin', child: Text('Admin')),
                        DropdownMenuItem(value: 'staff', child: Text('Staff')),
                        DropdownMenuItem(value: 'teacher', child: Text('Teacher')),
                        DropdownMenuItem(value: 'student', child: Text('Student')),
                      ],
                      onChanged: (value) => role = value!,
                      validator: (value) => value == null || value.isEmpty ? 'Role is required' : null,
                    ),
                    DropdownButtonFormField<String>(
                      value: status,
                      decoration: const InputDecoration(labelText: 'Status'),
                      items: const [
                        DropdownMenuItem(value: 'active', child: Text('Active')),
                        DropdownMenuItem(value: 'inactive', child: Text('Inactive')),
                      ],
                      onChanged: (value) => status = value!,
                      validator: (value) => value == null || value.isEmpty ? 'Status is required' : null,
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  if (formKey.currentState?.validate() ?? false) {
                    try {
                      final data = {
                        'id': user?.id,
                        'name': nameController.text,
                        'email': emailController.text,
                        'phone': phoneController.text,
                        if (user == null) 'password': passwordController.text,
                        'role': role,
                        'status': status,
                      }..removeWhere((key, value) => value == null);

                      if (user == null) {
                        await _api.createUser(data);
                      } else {
                        await _api.updateUser(data);
                      }

                      if (mounted) {
                        context.navigateBack();
                      }
                      _loadUsers();
                    } catch (e) {
                      _showError(e.toString());
                    }
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
    );
  }

  void _toggleUserStatus(UserVO user) async {
    final isActive = user.status.toLowerCase() == 'active';
    final newStatus = isActive ? 'inactive' : 'active';
    final actionLabel = isActive ? 'Deactivate' : 'Activate';

    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text('Confirm $actionLabel'),
            content: Text('Are you sure you want to $actionLabel this user?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text(actionLabel)),
            ],
          ),
    );

    if (confirm == true) {
      try {
        final data = {'id': user.id, 'name': user.name, 'email': user.email, 'phone': user.phone, 'role': user.role, 'status': newStatus};

        await _api.updateUser(data);
        _loadUsers();
      } catch (e) {
        _showError(e.toString());
      }
    }
  }

  Widget _buildUserList() {
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
                const Text("Users", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                ElevatedButton.icon(icon: const Icon(Icons.add), label: const Text("Add User"), onPressed: () => _showUserFormDialog()),
              ],
            ),
          ),
          const Divider(height: 1),
          _users.isEmpty
              ? const Padding(padding: EdgeInsets.all(20), child: Text('No users to display'))
              : ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _users.length,
                separatorBuilder: (_, __) => const Divider(height: 1),
                itemBuilder: (_, index) {
                  final user = _users[index];
                  return ListTile(
                    leading: CircleAvatar(child: Text(user.name[0].toUpperCase())),
                    title: Text(user.name),
                    subtitle: Text(user.email),
                    trailing: Wrap(
                      spacing: 8,
                      children: [
                        IconButton(icon: const Icon(Icons.edit), onPressed: () => _showUserFormDialog(user: user)),
                        IconButton(
                          icon: Icon(
                            user.status.toLowerCase() == 'active' ? Icons.block : Icons.check_circle,
                            color: user.status.toLowerCase() == 'active' ? Colors.red : Colors.green,
                          ),
                          tooltip: user.status.toLowerCase() == 'active' ? 'Deactivate' : 'Activate',
                          onPressed: () => _toggleUserStatus(user),
                        ),
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
    return _isLoading ? const Center(child: CircularProgressIndicator()) : _buildUserList();
  }
}
