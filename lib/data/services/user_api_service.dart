import '../../core/network/api_client.dart';
import '../models/doctor.dart';
import '../models/patient.dart';

class UserApiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Doctor>> getDoctors() async {
    final response = await _apiClient.get('Doctors');
    if (response.data is List) {
      return (response.data as List).map((e) => Doctor.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<Patient>> getPatients() async {
    final response = await _apiClient.get('Patients');
    if (response.data is List) {
      return (response.data as List).map((e) => Patient.fromJson(e)).toList();
    }
    return [];
  }
}
