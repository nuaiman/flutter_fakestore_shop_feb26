import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/dio_service.dart';

class RemoteAuthApi {
  final Dio _dio = DioService.client;

  Future<String> login({
    required String username,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {"username": username, "password": password},
    );

    if (response.statusCode != 201) {
      throw Exception("Login failed");
    }

    return response.data["token"];
  }

  Future<Map<String, dynamic>> fetchUser(int id) async {
    final response = await _dio.get('/users/$id');

    if (response.statusCode != 200) {
      throw Exception("Failed to fetch user");
    }

    return response.data;
  }
}

final remoteAuthApiProvider = Provider<RemoteAuthApi>((ref) {
  return RemoteAuthApi();
});
