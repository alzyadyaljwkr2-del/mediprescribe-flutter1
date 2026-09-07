import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_appbar.dart';
import '../../../data/models/patient.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../prescriptions/controllers/prescription_provider.dart';

class PatientDetailsScreen extends StatefulWidget {
  final Patient patient;

  const PatientDetailsScreen({super.key, required this.patient});

  @override
  State<PatientDetailsScreen> createState() => _PatientDetailsScreenState();
}

class _PatientDetailsScreenState extends State<PatientDetailsScreen> {
  final SecureStorageService _storage = SecureStorageService();
  String _currentUserId = '';

  @override
  void initState() {
    super.initState();
    _loadUserId();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<PrescriptionProvider>().fetchPrescriptions();
    });
  }

  Future<void> _loadUserId() async {
    final userId = await _storage.getUserId();
    if (mounted) {
      setState(() {
        _currentUserId = userId ?? '';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AppAppBar(
        title: 'بيانات المريض',
        showBackButton: true,
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildPatientInfo(),
          const Divider(height: 1),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text(
              'الوصفات الطبية الخاصة بالمريض',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
            ),
          ),
          Expanded(
            child: _buildPrescriptionsList(),
          ),
        ],
      ),
    );
  }

  Widget _buildPatientInfo() {
    return Container(
      padding: const EdgeInsets.all(20),
      color: AppColors.surface,
      child: Column(
        children: [
          const CircleAvatar(
            radius: 40,
            backgroundColor: AppColors.primaryLight,
            child: Icon(Icons.person, size: 40, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(
            widget.patient.name,
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildInfoRow(Icons.phone_outlined, widget.patient.phone),
          if (widget.patient.address != null && widget.patient.address!.isNotEmpty) ...[
            const SizedBox(height: 12),
            _buildInfoRow(Icons.location_on_outlined, widget.patient.address!),
          ],
        ],
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, color: AppColors.textHint, size: 20),
        const SizedBox(width: 8),
        Text(
          text,
          style: const TextStyle(fontSize: 16, color: AppColors.textSecondary),
        ),
      ],
    );
  }

  Widget _buildPrescriptionsList() {
    return Consumer<PrescriptionProvider>(
      builder: (context, provider, child) {
        if (_currentUserId.isEmpty || provider.isLoading) {
          return const Center(child: CircularProgressIndicator(color: AppColors.primary));
        }

        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(provider.errorMessage!, style: const TextStyle(color: AppColors.error)),
                TextButton(
                  onPressed: () => provider.fetchPrescriptions(),
                  child: const Text('إعادة المحاولة'),
                ),
              ],
            ),
          );
        }

        final doctorId = int.tryParse(_currentUserId) ?? 0;
        
        final patientPrescriptions = provider.prescriptions.where((p) {
          return p.patientId == widget.patient.id && p.doctorId == doctorId;
        }).toList();

        if (patientPrescriptions.isEmpty) {
          return const Center(
            child: Text(
              'لا توجد وصفات طبية قمت بصرفها لهذا المريض',
              style: TextStyle(color: AppColors.textHint),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: patientPrescriptions.length,
          itemBuilder: (context, index) {
            final prescription = patientPrescriptions[index];
            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                contentPadding: const EdgeInsets.all(16),
                leading: Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryLight,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: const Icon(Icons.receipt_long, color: AppColors.primary),
                ),
                title: Text(
                  'وصفة رقم #${prescription.id}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    prescription.medicationDetails,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }
}
