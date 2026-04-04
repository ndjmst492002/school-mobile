import 'package:dio/dio.dart' as dio_pkg;
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

class ApiProvider extends GetxService {
  late final dio_pkg.Dio _dio;

  static const String baseUrl = 'http://192.168.1.4:8000/api';

  Future<ApiProvider> init() async {
    _dio = dio_pkg.Dio(
      dio_pkg.BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 30),
        receiveTimeout: const Duration(seconds: 30),
        validateStatus: (status) => true,
      ),
    );

    var cookieJar = CookieJar();
    _dio.interceptors.add(CookieManager(cookieJar));

    _dio.interceptors.add(
      dio_pkg.InterceptorsWrapper(
        onRequest: (options, handler) {
          debugPrint('REQUEST: ${options.method} ${options.uri}');
          return handler.next(options);
        },
        onResponse: (response, handler) {
          debugPrint(
            'RESPONSE: ${response.statusCode} ${response.requestOptions.uri}',
          );
          return handler.next(response);
        },
        onError: (error, handler) async {
          debugPrint(
            'ERROR: ${error.response?.statusCode} ${error.requestOptions.uri}',
          );
          if (error.response?.statusCode == 401) {
            Get.find<AuthService>().logout();
          }
          return handler.next(error);
        },
      ),
    );

    return this;
  }

  dio_pkg.Dio get dio => _dio;

  Future<dio_pkg.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<dio_pkg.Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.post(path, data: data, queryParameters: queryParameters);
  }

  Future<dio_pkg.Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.patch(path, data: data, queryParameters: queryParameters);
  }

  Future<dio_pkg.Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
    );
  }

  Future<dio_pkg.Response> uploadFile(
    String path, {
    required dio_pkg.FormData data,
  }) async {
    return await _dio.post(
      path,
      data: data,
      options: dio_pkg.Options(contentType: 'multipart/form-data'),
    );
  }

  Future<void> downloadFile(String url, String filename) async {
    await _dio.download(url, filename);
  }
}

class AuthService extends GetxService {
  final _isAuthenticated = false.obs;
  final _user = Rxn<Map<String, dynamic>>();
  final _role = 'STUDENT'.obs;
  final _isLoading = false.obs;
  final _error = Rxn<String>();

  bool get isAuthenticated => _isAuthenticated.value;
  Map<String, dynamic>? get user => _user.value;
  bool get isLoading => _isLoading.value;
  String? get error => _error.value;
  String get role => _role.value;
  int get userId => _user.value?['id'] ?? 0;
  String get userEmail => _user.value?['email'] ?? '';
  String get userFullName =>
      _user.value?['full_name'] ?? _user.value?['email'] ?? '';

  void setUser(Map<String, dynamic>? userData, {String? role}) {
    _user.value = userData;
    _isAuthenticated.value = userData != null;
    if (role != null) {
      _role.value = role;
    }
  }

  void setLoading(bool loading) {
    _isLoading.value = loading;
  }

  void setError(String? error) {
    _error.value = error;
  }

  void clearError() {
    _error.value = null;
  }

  void logout() {
    _user.value = null;
    _isAuthenticated.value = false;
  }
}
