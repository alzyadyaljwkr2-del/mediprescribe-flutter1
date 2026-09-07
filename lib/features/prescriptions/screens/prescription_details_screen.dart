import 'package:flutter/material.dart';
import '../../../data/models/prescription.dart';
import '../../../data/models/doctor.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_appbar.dart';

class PrescriptionDetailsScreen extends StatelessWidget {
  final Prescription prescription;
  final Doctor? doctor;
  final List<String> medicines;
  final bool isActive;

  const PrescriptionDetailsScreen({
    super.key,
    required this.prescription,
    this.doctor,
    required this.medicines,
    required this.isActive,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: const AppAppBar(
        title: 'تفاصيل الوصفة',
        showBackButton: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildStatusHeader(),
            const SizedBox(height: 24),
            _buildInfoCard(),
            const SizedBox(height: 24),
            _buildMedicinesList(),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusHeader() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isActive ? AppColors.successLight : AppColors.errorLight,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: isActive ? AppColors.success.withValues(alpha: 0.3) : AppColors.error.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isActive ? Icons.check_circle_outline : Icons.cancel_outlined,
            size: 48,
            color: isActive ? AppColors.success : AppColors.error,
          ),
          const SizedBox(height: 12),
          Text(
            isActive ? 'وصفة نشطة وقابلة للصرف' : 'وصفة مصروفة أو منتهية',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: isActive ? AppColors.success : AppColors.error,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard() {
    return Container(
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
            children: [
              const Icon(Icons.info_outline, color: AppColors.primary),
              const SizedBox(width: 8),
              const Text('معلومات الوصفة', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const Divider(height: 30),
          _buildInfoRow('رقم الوصفة', 'RX-00${prescription.id}'),
          const SizedBox(height: 16),
          _buildInfoRow('الطبيب المعالج', doctor?.name ?? 'غير معروف'),
          const SizedBox(height: 16),
          _buildInfoRow('التخصص', doctor?.specialization ?? 'غير محدد'),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 100,
          child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 14)),
        ),
        Expanded(
          child: Text(value, style: const TextStyle(color: AppColors.textPrimary, fontSize: 14, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _buildMedicinesList() {
    return Container(
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
            children: [
              const Icon(Icons.medication, color: AppColors.secondary),
              const SizedBox(width: 8),
              const Text('الأدوية والجرعات', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary)),
            ],
          ),
          const Divider(height: 30),
          ...medicines.map((med) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('💊', style: TextStyle(fontSize: 20)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(med, style: const TextStyle(fontSize: 16, color: AppColors.textPrimary, fontWeight: FontWeight.w500)),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
