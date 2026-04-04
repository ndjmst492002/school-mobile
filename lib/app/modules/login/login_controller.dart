import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:dio/dio.dart' as dio;
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
      debugPrint('Attempting login to http://127.0.0.1:8000/api/users/login/');

      final response = await _authApi.login(
        emailController.text,
        passwordController.text,
      );

      debugPrint('Login response: $response');

      if (response.containsKey('user') && response.containsKey('role')) {
        final role = response['role'] as String;
        _auth.setUser(response['user'], role: role);
        _auth.setLoading(false);

        debugPrint('Login successful, navigating to $role dashboard');

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
      } else {
        error.value = 'Invalid response from server';
      }
    } on dio.DioException catch (e) {
      debugPrint('DioException: ${e.message}');
      debugPrint('Type: ${e.type}');
      debugPrint('Response: ${e.response?.data}');

      if (e.type == dio.DioExceptionType.connectionTimeout) {
        error.value =
            'Connection timeout - is the backend running on port 8000?';
      } else if (e.type == dio.DioExceptionType.connectionError) {
        error.value = 'Cannot connect to server - check if backend is running';
      } else if (e.response?.statusCode == 401) {
        error.value = 'Invalid email or password';
      } else {
        error.value = 'Login failed (${e.response?.statusCode ?? "unknown"})';
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
