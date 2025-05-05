import 'package:flutter/material.dart';
import 'package:sms_frontend/data/vos/user_vo.dart';
import 'package:sms_frontend/network/service/school_api_service.dart';

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
    final nameController = TextEditingController(text: user?.name ?? '');
    final emailController = TextEditingController(text: user?.email ?? '');
    final passwordController = TextEditingController();
    String role = user?.role ?? 'staff';

    showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: Text(user == null ? 'Add User' : 'Edit User'),
            content: SizedBox(
              width: 400,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(controller: nameController, decoration: const InputDecoration(labelText: 'Name')),
                  TextField(controller: emailController, decoration: const InputDecoration(labelText: 'Email')),
                  if (user == null)
                    TextField(controller: passwordController, decoration: const InputDecoration(labelText: 'Password'), obscureText: true),
                  DropdownButtonFormField<String>(
                    value: role,
                    items: const [
                      DropdownMenuItem(value: 'admin', child: Text('Admin')),
                      DropdownMenuItem(value: 'staff', child: Text('Staff')),
                    ],
                    onChanged: (value) => role = value!,
                    decoration: const InputDecoration(labelText: 'Role'),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
              ElevatedButton(
                onPressed: () async {
                  try {
                    final data = {
                      'id': user?.id,
                      'name': nameController.text,
                      'email': emailController.text,
                      if (user == null) 'password': passwordController.text,
                      'role': role,
                    }..removeWhere((key, value) => value == null);

                    if (user == null) {
                      await _api.createUser(data);
                    } else {
                      await _api.updateUser(data);
                    }

                    Navigator.pop(context);
                    _loadUsers();
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

  void _deleteUser(int id) async {
    final confirm = await showDialog(
      context: context,
      builder:
          (_) => AlertDialog(
            title: const Text('Confirm Delete'),
            content: const Text('Are you sure you want to delete this user?'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
              ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Delete')),
            ],
          ),
    );

    if (confirm == true) {
      try {
        await _api.deleteUser(id);
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
                        IconButton(icon: const Icon(Icons.delete), onPressed: () => _deleteUser(user.id)),
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
