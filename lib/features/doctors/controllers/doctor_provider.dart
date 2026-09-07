import 'package:flutter/material.dart';
import '../../../data/services/user_api_service.dart';
import '../../../data/models/doctor.dart';

class DoctorProvider with ChangeNotifier {
  final UserApiService _apiService = UserApiService();

  List<Doctor> _doctors = [];
  List<Doctor> get doctors => _doctors;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchDoctors() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _doctors = await _apiService.getDoctors();
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء جلب قائمة الأطباء';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
