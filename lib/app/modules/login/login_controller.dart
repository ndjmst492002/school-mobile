import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../data/providers/api_provider.dart';
import '../../data/services/auth_api.dart';
import '../../routes/app_routes.dart';

class LoginController extends GetxController {
  final AuthApi _authApi = AuthApi();

  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  final showPassword = false.obs;
  final isLoading = false.obs;
  final error = Rxn<String>();

  AuthService get _auth => Get.find<AuthService>();

  void toggleShowPassword() {
    showPassword.value = !showPassword.value;
  }

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      error.value = 'Please enter email and password';
      return;
    }

    isLoading.value = true;
    error.value = null;

    try {
      final response = await _authApi.login(
        emailController.text,
        passwordController.text,
      );

      final role = response['role'] as String;
      _auth.setUser(response['user'], role: role);
      _auth.setLoading(false);
      switch (role) {
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
          Get.offAllNamed(AppRoutes.home);
      }
    } catch (e) {
      debugPrint('Login error: $e');
      error.value = 'Login failed';
    } finally {
      isLoading.value = false;
    }
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }
}
