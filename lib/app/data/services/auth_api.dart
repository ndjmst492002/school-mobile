import 'package:get/get.dart';
import '../providers/api_provider.dart';

class AuthApi {
  final ApiProvider _api = Get.find<ApiProvider>();

  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await _api.post(
      '/users/login/',
      data: {'email': email, 'password': password},
    );
    return response.data;
  }

  Future<void> logout() async {
    try {
      await _api.post('/users/logout/');
    } catch (e) {
      // Continue even if logout fails on server
    }
  }

  Future<Map<String, dynamic>> getCurrentUser() async {
    final response = await _api.get('/users/me/');
    return response.data;
  }

  Future<String> getWsTicket() async {
    final response = await _api.post('/users/ws-ticket/');
    return response.data['ticket'];
  }
}
