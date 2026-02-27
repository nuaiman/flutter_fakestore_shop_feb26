import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../apis/remote_products_api.dart';
import '../../../models/product.dart';

class RemoteProductsNotifier extends AsyncNotifier<List<Product>> {
  late final RemoteProductsApi _remoteApi;

  String? _selectedCategory;
  String? _searchQuery;

  @override
  Future<List<Product>> build() async {
    _remoteApi = ref.read(remoteProductsApiProvider);
    return await fetchRemoteProducts();
  }

  /// Fetch remote products
  Future<List<Product>> fetchRemoteProducts() async {
    state = const AsyncValue.loading();
    final products = await _remoteApi.fetchProducts();
    state = AsyncValue.data(products);
    return products;
  }

  /// Returns all unique categories
  List<String> getCategories() {
    final products = state.value ?? [];
    final categories = products.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }

  void setSelectedCategory(String? category) => _selectedCategory = category;
  String? getSelectedCategory() => _selectedCategory;

  void setSearchQuery(String? query) => _searchQuery = query;

  /// Filter products based on category & search query
  List<Product> getFilteredProducts() {
    final products = state.value ?? [];
    return products.where((p) {
      final matchesCategory =
          _selectedCategory == null || p.category == _selectedCategory;
      final matchesSearch =
          _searchQuery == null ||
          p.title.toLowerCase().contains(_searchQuery!.toLowerCase());
      return matchesCategory && matchesSearch;
    }).toList();
  }
}

final remoteProductsNotifierProvider =
    AsyncNotifierProvider<RemoteProductsNotifier, List<Product>>(
      RemoteProductsNotifier.new,
    );
