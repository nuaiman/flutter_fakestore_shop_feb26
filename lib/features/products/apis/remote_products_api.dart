import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/services/dio_service.dart';
import '../../../models/product.dart';

class RemoteProductsApi {
  final Dio _dio = DioService.client;

  Future<List<Product>> fetchProducts() async {
    final response = await _dio.get('/products');

    if (response.statusCode != 200) {
      throw Exception('Failed to fetch products: ${response.statusCode}');
    }

    final data = response.data;
    if (data is! List) throw Exception('Invalid API response');

    return data
        .map<Product>((json) => Product.fromMap(json as Map<String, dynamic>))
        .toList();
  }
}

// -----------------------------------------------------------------------------
final remoteProductsApiProvider = Provider((ref) {
  return RemoteProductsApi();
});
