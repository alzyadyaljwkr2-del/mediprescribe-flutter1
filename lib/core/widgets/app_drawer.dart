import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../features/auth/screens/login_screen.dart';
import '../../features/auth/controllers/auth_provider.dart';
import '../services/secure_storage_service.dart';
import '../theme/app_colors.dart';

class AppDrawer extends StatefulWidget {
  const AppDrawer({super.key});

  @override
  State<AppDrawer> createState() => _AppDrawerState();
}

class _AppDrawerState extends State<AppDrawer> {
  final SecureStorageService _storage = SecureStorageService();
  String _role = '';
  String _fullName = '';
  String _email = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final role = await _storage.getUserRole();
    final fullName = await _storage.getFullName();
    final email = await _storage.getEmail();
    if (mounted) {
      setState(() {
        _role = role ?? '';
        _fullName = fullName ?? 'المستخدم';
        _email = email ?? _getRoleName(_role);
      });
    }
  }

  Future<void> _logout(BuildContext context) async {
    await context.read<AuthProvider>().logout();
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppColors.background,
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: const BoxDecoration(color: AppColors.primaryDark),
            accountName: Text(_fullName, style: const TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: Text(_email.isNotEmpty && _email != _getRoleName(_role) ? '$_email - ${_getRoleName(_role)}' : _getRoleName(_role)),
            currentAccountPicture: const CircleAvatar(
              backgroundColor: Colors.white,
              child: Icon(Icons.person, color: AppColors.primary, size: 40),
            ),
          ),
          ListTile(
            leading: const Icon(Icons.dashboard, color: AppColors.primary),
            title: const Text('لوحة التحكم', style: TextStyle(fontWeight: FontWeight.bold)),
            onTap: () {
              Navigator.pop(context);
            },
          ),
          const Spacer(),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.logout, color: AppColors.error),
            title: const Text('تسجيل الخروج', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold)),
            onTap: () => _logout(context),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }

  String _getRoleName(String role) {
    switch (role) {
      case '0':
      case 'Admin':
        return 'مدير النظام';
      case '1':
      case 'Doctor':
        return 'طبيب';
      case '2':
      case 'Patient':
        return 'مريض';
      case '3':
      case 'Pharmacist':
        return 'صيدلي';
      default:
        return 'غير محدد';
    }
  }
}
