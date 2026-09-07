import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../core/widgets/app_drawer.dart';
import 'dashboard_tab.dart';
import '../../prescriptions/screens/prescriptions_tab.dart';
import '../../profile/screens/profile_tab.dart';
import '../../doctors/screens/doctors_tab.dart';
import '../../patients/screens/patients_tab.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;
  String _role = '';
  final SecureStorageService _storage = SecureStorageService();
  bool _isLoading = true;

  List<Widget> _tabs = [];
  List<BottomNavigationBarItem> _navItems = [];

  @override
  void initState() {
    super.initState();
    _initRoleAndTabs();
  }

  Future<void> _initRoleAndTabs() async {
    final role = await _storage.getUserRole() ?? '';
    if (!mounted) return;
    
    setState(() {
      _role = role;
      
      if (_role == '1' || _role == 'Doctor') {
        _tabs = [
          const DashboardTab(),
          const DoctorsTab(),
          const PatientsTab(),
          const PrescriptionsTab(),
          const ProfileTab(),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.medical_services_outlined),
            activeIcon: Icon(Icons.medical_services),
            label: 'الأطباء',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.people_outline),
            activeIcon: Icon(Icons.people),
            label: 'المرضى',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'الوصفات',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'ملفي',
          ),
        ];
      } else {
        // Patient
        _tabs = [
          const DashboardTab(),
          const PrescriptionsTab(),
          const ProfileTab(),
        ];
        _navItems = const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(Icons.home),
            label: 'الرئيسية',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.receipt_long_outlined),
            activeIcon: Icon(Icons.receipt_long),
            label: 'وصفاتي',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person),
            label: 'ملفي',
          ),
        ];
      }
      _isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: AppColors.primary)),
      );
    }

    return Scaffold(
      appBar: const AppAppBar(title: 'MediPrescribe'),
      drawer: const AppDrawer(),
      body: _tabs[_currentIndex],
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: AppColors.cardShadow,
              blurRadius: 10,
              offset: Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: AppColors.surface,
          selectedItemColor: AppColors.primary,
          unselectedItemColor: AppColors.textHint,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.normal, fontSize: 12),
          elevation: 0,
          items: _navItems,
        ),
      ),
    );
  }
}
