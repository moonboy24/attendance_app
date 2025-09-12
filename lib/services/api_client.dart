import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ApiClient {
  final Dio _dio = Dio(BaseOptions(
    baseUrl: const String.fromEnvironment('API_BASE', defaultValue: 'https://attendance-app-699k.onrender.com'),
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 20),
    headers: { 'Content-Type': 'application/json' },
  ));

  ApiClient() {
    _dio.interceptors.add(InterceptorsWrapper(onRequest: (options, handler) async {
      final sp = await SharedPreferences.getInstance();
      final token = sp.getString('token');
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
      handler.next(options);
    }));
  }

  Dio get client => _dio;
}