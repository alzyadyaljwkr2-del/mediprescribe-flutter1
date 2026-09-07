import 'package:flutter/material.dart';
import 'package:dio/dio.dart';
import '../../../core/network/api_exception.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../data/services/prescription_api_service.dart';
import '../../../data/models/prescription.dart';
import '../../../data/models/doctor.dart';
import '../../../data/models/patient.dart';
import '../../../data/services/user_api_service.dart';

class PrescriptionProvider with ChangeNotifier {
  final PrescriptionApiService _apiService = PrescriptionApiService();
  final UserApiService _userApiService = UserApiService();

  List<Prescription> _prescriptions = [];
  List<Prescription> get prescriptions => _prescriptions;

  List<dynamic> _searchResults = [];
  List<dynamic> get searchResults => _searchResults;

  List<Doctor> _doctors = [];
  List<Patient> _patients = [];
  List<Patient> get patients => _patients;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  Future<void> fetchPrescriptions() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final storage = SecureStorageService();
      final role = await storage.getUserRole();

      if (role == '1' || role == 'Doctor' || role == '0' || role == 'Admin') {
        final results = await Future.wait([
          _apiService.getPrescriptions(),
          _userApiService.getDoctors(),
          _userApiService.getPatients(),
        ]);

        _prescriptions = results[0] as List<Prescription>;
        _doctors = results[1] as List<Doctor>;
        _patients = results[2] as List<Patient>;
      } else {
        // Patient role: only fetch prescriptions
        _prescriptions = await _apiService.getMyPrescriptions();
      }
      
    } catch (e) {
      if (e is DioException && e.error is ApiException) {
        _errorMessage = (e.error as ApiException).message;
      } else {
        _errorMessage = 'حدث خطأ أثناء جلب الوصفات الطبية: $e';
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> searchPrescriptions(String query) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _searchResults = await _apiService.searchPrescriptions(query);
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء البحث عن الوصفة';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> dispensePrescription(int id) async {
    try {
      await _apiService.dispensePrescription(id);
      return true;
    } catch (e) {
      _errorMessage = 'تعذر صرف الوصفة';
      notifyListeners();
      return false;
    }
  }

  Future<bool> createPrescription(Map<String, dynamic> data) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _apiService.createPrescription(data);
      await fetchPrescriptions();
      return true;
    } catch (e) {
      _errorMessage = 'حدث خطأ أثناء حفظ الوصفة';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Doctor? getDoctorById(int id) {
    try {
      return _doctors.firstWhere((d) => d.id == id);
    } catch (_) {
      return null;
    }
  }
  
  Patient? getPatientById(int id) {
    try {
      return _patients.firstWhere((p) => p.id == id);
    } catch (_) {
      return null;
    }
  }

  List<String> parseMedications(String details) {
    if (details.isEmpty) return [];
    if (details.contains('\n')) {
      return details.split('\n').where((s) => s.trim().isNotEmpty).toList();
    } else if (details.contains(',')) {
      return details.split(',').where((s) => s.trim().isNotEmpty).toList();
    }
    return [details];
  }
}
