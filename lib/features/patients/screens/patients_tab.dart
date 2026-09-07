import 'patient_details_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/patient_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

class PatientsTab extends StatefulWidget {
  const PatientsTab({super.key});

  @override
  State<PatientsTab> createState() => _PatientsTabState();
}

class _PatientsTabState extends State<PatientsTab> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PatientProvider>().fetchPatients();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PatientProvider>(
      builder: (context, provider, child) {
        if (provider.isLoading && provider.patients.isEmpty) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (provider.errorMessage != null && provider.patients.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => provider.fetchPatients(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        if (provider.patients.isEmpty) {
          return const EmptyState(message: 'لا يوجد مرضى متاحين', icon: Icons.people_outline);
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: provider.patients.length,
          itemBuilder: (context, index) {
            final patient = provider.patients[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: AppColors.successLight,
                  child: Icon(Icons.person_outline, color: AppColors.success),
                ),
                title: Text(patient.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(patient.phone),
                trailing: const Icon(Icons.chevron_left, color: AppColors.textHint),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => PatientDetailsScreen(patient: patient),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
