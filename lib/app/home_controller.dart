import 'package:get/get.dart';
import 'data/providers/api_provider.dart';
import 'routes/app_routes.dart';

class HomeController extends GetxController {
  AuthService get _auth => Get.find<AuthService>();

  void checkAuthAndRedirect() {
    if (!_auth.isAuthenticated) {
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    switch (_auth.role) {
      case 'ADMIN':
        Get.offAllNamed(AppRoutes.admin);
        break;
      case 'TEACHER':
        Get.offAllNamed(AppRoutes.teacher);
        break;
      case 'STUDENT':
        Get.offAllNamed(AppRoutes.student);
        break;
      case 'PARENT':
        Get.offAllNamed(AppRoutes.parent);
        break;
      default:
        Get.offAllNamed(AppRoutes.login);
    }
  }
}
