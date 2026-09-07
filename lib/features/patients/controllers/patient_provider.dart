import 'package:flutter/material.dart';
import '../../../data/services/user_api_service.dart';
import '../../../data/models/patient.dart';

class PatientProvider with ChangeNotifier {
  final UserApiService _apiService = UserApiService();

  List<Patient> _patients = [];
  List<Patient> get patients => _patients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPatients() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _patients = await _apiService.getPatients();
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء جلب قائمة المرضى';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
