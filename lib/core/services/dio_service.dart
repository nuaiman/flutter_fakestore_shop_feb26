import 'package:dio/dio.dart';
import '../constants/base_urls.dart';

class DioService {
  static final DioService instance = DioService._internal();

  late final Dio dio;

  DioService._internal() {
    dio = Dio(
      BaseOptions(
        connectTimeout: Duration(seconds: 5),
        receiveTimeout: Duration(seconds: 5),
        baseUrl: baseUrlHTTP,
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(LogInterceptor(requestBody: true, responseBody: true));
  }

  static Dio get client => instance.dio;
}
