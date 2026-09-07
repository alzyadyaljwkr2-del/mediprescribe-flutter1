import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/doctor_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

class DoctorsTab extends StatefulWidget {
  const DoctorsTab({super.key});

  @override
  State<DoctorsTab> createState() => _DoctorsTabState();
}

class _DoctorsTabState extends State<DoctorsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DoctorProvider>().fetchDoctors();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DoctorProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.doctors.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (provider.errorMessage != null && provider.doctors.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchDoctors(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (provider.doctors.isEmpty) {
          return const EmptyState(message: 'لا يوجد أطباء متاحين', icon: Icons.people_outline);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.doctors.length,
          itemBuilder: (context, index) {
            final doctor = provider.doctors[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.primaryLight,
                  child: Icon(Icons.person, color: AppColors.primary),
                ),
                title: Text(doctor.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(doctor.specialization),
                trailing: doctor.email != null 
                    ? const Icon(Icons.email_outlined, color: AppColors.textHint) 
                    : null,
              ),
            );
          },
        );
      },
    );
  }
}
