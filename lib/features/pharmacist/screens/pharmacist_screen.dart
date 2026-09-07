import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../auth/controllers/auth_provider.dart';
import '../../auth/screens/login_screen.dart';
import '../../prescriptions/controllers/prescription_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../core/widgets/app_drawer.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';

class PharmacistScreen extends StatefulWidget {
  const PharmacistScreen({super.key});

  @override
  State<PharmacistScreen> createState() => _PharmacistScreenState();
}

class _PharmacistScreenState extends State<PharmacistScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _search() {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<PrescriptionProvider>().searchPrescriptions(query);
    }
  }

  Future<void> _dispense(int id) async {
    final provider = context.read<PrescriptionProvider>();
    final success = await provider.dispensePrescription(id);
    
    if (mounted) {
      if (success) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم صرف الوصفة بنجاح'), backgroundColor: AppColors.success),
        );
        _search(); // Refresh results
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'حدث خطأ'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppAppBar(
        title: 'لوحة الصيدلي',
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await context.read<AuthProvider>().logout();
              if (context.mounted) {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false,
                );
              }
            },
          ),
        ],
      ),
      drawer: const AppDrawer(),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildSearchBar(),
            const SizedBox(height: 24),
            Expanded(child: _buildSearchResults()),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchBar() {
    return Row(
      children: [
        Expanded(
          child: AppTextField(
            controller: _searchController,
            labelText: 'ابحث عن وصفة (رقم الوصفة أو اسم المريض)',
            prefixIcon: const Icon(Icons.search),
          ),
        ),
        const SizedBox(width: 12),
        SizedBox(
          width: 100,
          child: Consumer<PrescriptionProvider>(
            builder: (context, provider, child) {
              return AppButton(
                text: 'بحث',
                isLoading: provider.isLoading,
                onPressed: _search,
              );
            }
          ),
        ),
      ],
    );
  }

  Widget _buildSearchResults() {
    return Consumer<PrescriptionProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (provider.searchResults.isEmpty) {
          return const Center(
            child: Text('لا توجد نتائج مطابقة', style: TextStyle(color: AppColors.textSecondary)),
          );
        }

        return ListView.builder(
          itemCount: provider.searchResults.length,
          itemBuilder: (context, index) {
            final data = provider.searchResults[index];
            final id = data['id'];
            final status = data['status'];
            final isActive = status == 0;
            
            return Card(
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('وصفة رقم: $id', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: isActive ? AppColors.successLight : AppColors.errorLight,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            isActive ? 'قابلة للصرف' : 'مصروفة مسبقاً',
                            style: TextStyle(
                              color: isActive ? AppColors.success : AppColors.error,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text('الأدوية: ${data['medicationDetails']}'),
                    const SizedBox(height: 16),
                    if (isActive)
                      AppButton(
                        text: 'صرف الوصفة',
                        backgroundColor: AppColors.success,
                        onPressed: () => _dispense(id),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
