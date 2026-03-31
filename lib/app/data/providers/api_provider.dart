import 'package:dio/dio.dart' as dio_pkg;
import 'package:get/get.dart';

class ApiProvider extends GetxService {
  late final dio_pkg.Dio _dio;
  String? _sessionCookie;

  // Update this to match your backend URL
  //Android Device (with your ip address)
  static const String baseUrl = 'http://192.168.1.5:8000/api';
  //Chrome(Web)
  //static const String baseUrl = 'http://localhost:8000/api';

  Future<ApiProvider> init() async {
    _dio = dio_pkg.Dio(
      dio_pkg.BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    _dio.interceptors.add(
      dio_pkg.InterceptorsWrapper(
        onRequest: (options, handler) {
          // Add cookie to request if we have one
          if (_sessionCookie != null) {
            options.headers['Cookie'] = _sessionCookie;
          }
          return handler.next(options);
        },
        onResponse: (response, handler) {
          // Extract cookie from Set-Cookie header
          final cookies = response.headers['set-cookie'];
          if (cookies != null && cookies.isNotEmpty) {
            _sessionCookie = _extractSessionCookie(cookies);
          }
          return handler.next(response);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            Get.find<AuthService>().logout();
          }
          return handler.next(error);
        },
      ),
    );

    return this;
  }

  String? _extractSessionCookie(List<String> cookies) {
    // Look for sessionid cookie first
    for (final cookie in cookies) {
      if (cookie.contains('sessionid')) {
        final parts = cookie.split(';');
        return parts[0];
      }
    }
    // Fall back to first cookie
    if (cookies.isNotEmpty) {
      final parts = cookies.first.split(';');
      return parts[0];
    }
    return null;
  }

  dio_pkg.Dio get dio => _dio;

  Future<dio_pkg.Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.get(
        path,
        queryParameters: queryParameters,
        options: _getOptionsWithCredentials(),
      );
    } on dio_pkg.DioException {
      rethrow;
    }
  }

  Future<dio_pkg.Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _getOptionsWithCredentials(),
      );
    } on dio_pkg.DioException {
      rethrow;
    }
  }

  Future<dio_pkg.Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.patch(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _getOptionsWithCredentials(),
      );
    } on dio_pkg.DioException {
      rethrow;
    }
  }

  Future<dio_pkg.Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      return await _dio.delete(
        path,
        data: data,
        queryParameters: queryParameters,
        options: _getOptionsWithCredentials(),
      );
    } on dio_pkg.DioException {
      rethrow;
    }
  }

  Future<dio_pkg.Response> uploadFile(
    String path, {
    required dio_pkg.FormData data,
  }) async {
    try {
      return await _dio.post(
        path,
        data: data,
        options: dio_pkg.Options(
          contentType: 'multipart/form-data',
          extra: {'withCredentials': true},
        ),
      );
    } on dio_pkg.DioException {
      rethrow;
    }
  }

  Future<void> downloadFile(String url, String filename) async {
    try {
      await _dio.download(
        url,
        filename,
        options: dio_pkg.Options(extra: {'withCredentials': true}),
      );
    } catch (e) {
      rethrow;
    }
  }

  dio_pkg.Options _getOptionsWithCredentials() {
    return dio_pkg.Options(extra: {'withCredentials': true});
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
