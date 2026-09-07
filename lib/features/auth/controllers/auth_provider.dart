import 'package:flutter/material.dart';
import '../../../data/services/auth_api_service.dart';
import '../../../core/services/secure_storage_service.dart';
import '../../../core/network/api_exception.dart';

class AuthProvider with ChangeNotifier {
  final AuthApiService _apiService = AuthApiService();
  final SecureStorageService _storage = SecureStorageService();

  bool _isLoading = false;
  String? _errorMessage;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final data = await _apiService.login(email, password);
      
      final token = data['token'];
      final role = data['role'];
      final userId = data['userId']?.toString();
      final fullName = data['fullName'];
      final userEmail = data['email'];

      if (token != null) {
        await _storage.saveToken(token);
        if (role != null) await _storage.saveUserRole(role.toString());
        if (userId != null) await _storage.saveUserId(userId);
        if (fullName != null) await _storage.saveFullName(fullName);
        if (userEmail != null) await _storage.saveEmail(userEmail);
        
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _errorMessage = 'لم يتم استلام رمز التحقق من السيرفر';
        _isLoading = false;
        notifyListeners();
        return false;
      }
    } catch (e) {
      if (e is ApiException) {
        _errorMessage = e.message;
      } else {
        _errorMessage = 'حدث خطأ أثناء تسجيل الدخول: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _storage.clearAll();
    notifyListeners();
  }
}
