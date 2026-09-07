import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../data/models/patient.dart';
import '../controllers/prescription_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text_field.dart';
import '../../../core/services/secure_storage_service.dart';

class CreatePrescriptionModal extends StatefulWidget {
  const CreatePrescriptionModal({super.key});

  @override
  State<CreatePrescriptionModal> createState() => _CreatePrescriptionModalState();
}

class _CreatePrescriptionModalState extends State<CreatePrescriptionModal> {
  final _formKey = GlobalKey<FormState>();
  final _medicationsController = TextEditingController();
  
  int? _selectedPatientId;
  String _doctorId = '';
  final SecureStorageService _storage = SecureStorageService();

  @override
  void initState() {
    super.initState();
    _loadDoctorId();
  }

  Future<void> _loadDoctorId() async {
    final id = await _storage.getUserId();
    if (id != null) {
      setState(() {
        _doctorId = id;
      });
    }
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate() || _selectedPatientId == null) {
      if (_selectedPatientId == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الرجاء اختيار المريض'), backgroundColor: AppColors.error),
        );
      }
      return;
    }

    final provider = context.read<PrescriptionProvider>();
    final data = {
      'doctorId': int.tryParse(_doctorId) ?? 0,
      'patientId': _selectedPatientId!,
      'medicationDetails': _medicationsController.text,
      'imageUrl': '',
    };

    final success = await provider.createPrescription(data);
    
    if (mounted) {
      if (success) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('تم إنشاء الوصفة بنجاح'), backgroundColor: AppColors.success),
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(provider.errorMessage ?? 'حدث خطأ'), backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  void dispose() {
    _medicationsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 20,
        right: 20,
        top: 20,
      ),
      decoration: const BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(30),
          topRight: Radius.circular(30),
        ),
      ),
      child: SafeArea(
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: AppColors.border,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'إنشاء وصفة طبية جديدة',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                ),
                const SizedBox(height: 20),
                Consumer<PrescriptionProvider>(
                  builder: (context, provider, child) {
                    // Extracting patients directly from provider state
                    // In a more robust system, we would fetch them when opening the sheet
                    // but we can assume provider has them loaded.
                    // If not, we fall back to an empty list.
                    return DropdownButtonFormField<int>(
                      decoration: InputDecoration(
                        labelText: 'اختر المريض',
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                      ),
                      initialValue: _selectedPatientId,
                      items: provider.isLoading && provider.patients.isEmpty
                        ? []
                        : provider.patients.map((patient) {
                            return DropdownMenuItem<int>(
                              value: patient.id,
                              child: Text(patient.name),
                            );
                          }).toList(),
                      onChanged: (val) {
                        setState(() {
                          _selectedPatientId = val;
                        });
                      },
                      validator: (value) => value == null ? 'مطلوب' : null,
                    );
                  }
                ),
                const SizedBox(height: 16),
                AppTextField(
                  controller: _medicationsController,
                  maxLines: 4,
                  labelText: 'الأدوية والتعليمات (مفصولة بفاصلة)',
                  hintText: 'مثال: بنادول كل 8 ساعات, اموكسيسيلين',
                  validator: (value) => value == null || value.isEmpty ? 'مطلوب' : null,
                ),
                const SizedBox(height: 24),
                Consumer<PrescriptionProvider>(
                  builder: (context, provider, child) {
                    return AppButton(
                      text: 'حفظ الوصفة',
                      isLoading: provider.isLoading,
                      onPressed: _submit,
                    );
                  }
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
