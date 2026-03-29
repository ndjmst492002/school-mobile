import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../data/services/parent_api.dart';
import '../../data/models/parent_models.dart';
import '../../routes/app_routes.dart';

class ParentController extends GetxController {
  final AuthApi _authApi = AuthApi();
  final ParentApi _parentApi = ParentApi();

  final children = <StudentChild>[].obs;
  final announcements = <ChildAnnouncement>[].obs;
  final isLoading = true.obs;
  final showChat = false.obs;

  AuthService get _auth => Get.find<AuthService>();
  String get userName => _auth.userFullName;

  @override
  void onInit() {
    super.onInit();
    loadData();
  }

  Future<void> loadData() async {
    isLoading.value = true;
    try {
      final results = await Future.wait([
        _parentApi.getChildren(),
        _parentApi.getAnnouncements(),
      ]);
      children.value = results[0] as List<StudentChild>;
      announcements.value = results[1] as List<ChildAnnouncement>;
    } catch (e) {
      // Handle error
    } finally {
      isLoading.value = false;
    }
  }

  void toggleChat() {
    showChat.value = !showChat.value;
  }

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
