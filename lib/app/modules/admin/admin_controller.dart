import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../routes/app_routes.dart';

class AdminController extends GetxController {
  final AuthApi _authApi = AuthApi();

  AuthService get _auth => Get.find<AuthService>();

  String get userName => _auth.userFullName;
  bool get isAdmin => _auth.role == 'ADMIN';

  Future<void> logout() async {
    try {
      await _authApi.logout();
    } catch (e) {
      // Continue even if logout fails
    }
    _auth.logout();
    Get.offAllNamed(AppRoutes.login);
  }
}
