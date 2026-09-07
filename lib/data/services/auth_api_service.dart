import '../../core/network/api_client.dart';

class AuthApiService {
  final ApiClient _apiClient = ApiClient();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _apiClient.post(
      'Auth/login',
      data: {
        'email': email,
        'password': password,
      },
    );
    return response.data;
  }
}
