import '../../core/network/api_client.dart';
import '../models/prescription.dart';

class PrescriptionApiService {
  final ApiClient _apiClient = ApiClient();

  Future<List<Prescription>> getPrescriptions() async {
    final response = await _apiClient.get('Prescriptions');
    if (response.data is List) {
      return (response.data as List).map((e) => Prescription.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<Prescription>> getMyPrescriptions() async {
    final response = await _apiClient.get('Prescriptions/my');
    if (response.data is List) {
      return (response.data as List).map((e) => Prescription.fromJson(e)).toList();
    }
    return [];
  }

  Future<List<dynamic>> searchPrescriptions(String query) async {
    final response = await _apiClient.get('Prescriptions/search?query=$query');
    return response.data;
  }

  Future<void> createPrescription(Map<String, dynamic> data) async {
    await _apiClient.post('Prescriptions', data: data);
  }

  Future<Map<String, dynamic>> dispensePrescription(int id) async {
    final response = await _apiClient.post('Prescriptions/$id/dispense');
    return response.data;
  }
}
