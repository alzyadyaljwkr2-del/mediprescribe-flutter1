import '../../core/network/api_client.dart';
import '../../core/network/api_constants.dart';
import '../models/doctor.dart';
import '../models/patient.dart';
import '../models/prescription.dart';

class ApiRepository {
  final ApiClient _apiClient;

  ApiRepository({ApiClient? apiClient}) : _apiClient = apiClient ?? ApiClient();

  // Doctors
  Future<List<Doctor>> getDoctors() async {
    final response = await _apiClient.get(ApiConstants.doctors);
    return (response.data as List).map((json) => Doctor.fromJson(json)).toList();
  }

  Future<Doctor> getDoctor(int id) async {
    final response = await _apiClient.get('${ApiConstants.doctors}/$id');
    return Doctor.fromJson(response.data);
  }

  // Patients
  Future<List<Patient>> getPatients() async {
    final response = await _apiClient.get(ApiConstants.patients);
    return (response.data as List).map((json) => Patient.fromJson(json)).toList();
  }

  Future<Patient> getPatient(int id) async {
    final response = await _apiClient.get('${ApiConstants.patients}/$id');
    return Patient.fromJson(response.data);
  }

  // Prescriptions
  Future<List<Prescription>> getPrescriptions() async {
    final response = await _apiClient.get(ApiConstants.prescriptions);
    return (response.data as List).map((json) => Prescription.fromJson(json)).toList();
  }

  Future<Prescription> getPrescription(int id) async {
    final response = await _apiClient.get('${ApiConstants.prescriptions}/$id');
    return Prescription.fromJson(response.data);
  }

  Future<Prescription> createPrescription(Prescription prescription) async {
    final response = await _apiClient.post(
      ApiConstants.prescriptions, 
      data: prescription.toJson(),
    );
    return Prescription.fromJson(response.data);
  }
}
