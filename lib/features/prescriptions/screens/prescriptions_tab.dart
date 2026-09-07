import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../controllers/prescription_provider.dart';
import 'prescription_details_screen.dart';
import 'create_prescription_modal.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/empty_state.dart';

class PrescriptionsTab extends StatefulWidget {
  const PrescriptionsTab({super.key});

  @override
  State<PrescriptionsTab> createState() => _PrescriptionsTabState();
}

class _PrescriptionsTabState extends State<PrescriptionsTab> {
  String _role = '';
  final SecureStorageService _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _loadRole();
  }

  Future<void> _loadRole() async {
    final role = await _storage.getUserRole();
    if (mounted) {
      setState(() {
        _role = role ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          Expanded(
            child: Consumer<PrescriptionProvider>(
              builder: (context, provider, child) {
                if (provider.isLoading && provider.prescriptions.isEmpty) {
                  return const Center(child: CircularProgressIndicator(color: AppColors.primary));
                }

                if (provider.errorMessage != null && provider.prescriptions.isEmpty) {
                  return Center(
                    child: Text(
                      provider.errorMessage!,
                      style: const TextStyle(color: AppColors.error),
                    ),
                  );
                }

                if (provider.prescriptions.isEmpty) {
                  return const EmptyState(message: 'لا توجد وصفات طبية حتى الآن', icon: Icons.receipt_long);
                }

                return ListView.builder(
                  padding: const EdgeInsets.all(20),
                  itemCount: provider.prescriptions.length,
                  itemBuilder: (context, index) {
                    final prescription = provider.prescriptions[index];
                    final doctor = provider.getDoctorById(prescription.doctorId);
                    final medicines = provider.parseMedications(prescription.medicationDetails);

                    final isActive = prescription.status == 0;
                    
                    return GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => PrescriptionDetailsScreen(
                              prescription: prescription,
                              doctor: doctor,
                              medicines: medicines,
                              isActive: isActive,
                            ),
                          ),
                        );
                      },
                      child: _buildPrescriptionCard(
                        'RX-00${prescription.id}',
                        doctor?.name ?? 'طبيب غير معروف',
                        doctor?.specialization ?? 'تخصص غير معروف',
                        medicines,
                        isActive,
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: (_role == '1' || _role == 'Doctor')
          ? FloatingActionButton(
              onPressed: () {
                showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  backgroundColor: Colors.transparent,
                  builder: (context) => const CreatePrescriptionModal(),
                );
              },
              backgroundColor: AppColors.primary,
              child: const Icon(Icons.add, color: Colors.white),
            )
          : null,
    );
  }

  Widget _buildHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, left: 20, right: 20, bottom: 30),
      decoration: const BoxDecoration(
        color: AppColors.primaryDark,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(30),
          bottomRight: Radius.circular(30),
        ),
      ),
      child: const Text(
        'وصفاتي الطبية',
        style: TextStyle(
          color: Colors.white,
          fontSize: 24,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildPrescriptionCard(String id, String doctor, String clinic, List<String> medicines, bool isActive) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.border),
        boxShadow: const [
          BoxShadow(
            color: AppColors.cardShadow,
            blurRadius: 8,
            offset: Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                decoration: BoxDecoration(
                  color: isActive ? AppColors.successLight : AppColors.errorLight,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  isActive ? 'نشطة' : 'مصروفة',
                  style: TextStyle(
                    color: isActive ? AppColors.success : AppColors.error,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Row(
                children: [
                  Text(id, style: const TextStyle(color: AppColors.primary, fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.primaryLight,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.receipt_long, color: AppColors.primary, size: 18),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(doctor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
          const SizedBox(height: 4),
          Text(clinic, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
          const SizedBox(height: 16),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: medicines.map((med) => _buildMedicineChip(med)).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildMedicineChip(String name) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surface,
        border: Border.all(color: AppColors.border),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.medication, size: 14, color: AppColors.textHint),
          const SizedBox(width: 6),
          Text(name, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
