import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../apis/local_products_api.dart';
import '../../../models/product.dart';
import 'remote_products_notifier.dart';

class LocalProductsNotifier extends AsyncNotifier<List<Product>> {
  late final LocalProductsApi _localApi;
  late final RemoteProductsNotifier _remoteNotifier;

  String? _selectedCategory;
  String? _searchQuery;

  @override
  Future<List<Product>> build() async {
    _localApi = ref.read(localProductsApiProvider);
    _remoteNotifier = ref.read(remoteProductsNotifierProvider.notifier);

    ref.listen<AsyncValue<List<Product>>>(remoteProductsNotifierProvider, (
      _,
      _,
    ) {
      fetchLocalProducts();
    });

    return await fetchLocalProducts();
  }

  /// Fetch saved products by combining local IDs with remote products
  Future<List<Product>> fetchLocalProducts() async {
    final savedIds = _localApi.getSavedIds();

    if (savedIds.isEmpty) {
      state = const AsyncValue.data([]);
      return [];
    }

    final remoteProducts = _remoteNotifier.state.value ?? [];

    final savedProducts = remoteProducts
        .where((p) => savedIds.contains(p.id))
        .toList();

    state = AsyncValue.data(savedProducts);
    return savedProducts;
  }

  /// Returns all unique categories from saved products
  List<String> getCategories() {
    final products = state.value ?? [];
    final categories = products.map((p) => p.category).toSet().toList();
    categories.sort();
    return categories;
  }

  void setSelectedCategory(String? category) => _selectedCategory = category;
  String? getSelectedCategory() => _selectedCategory;

  void setSearchQuery(String? query) => _searchQuery = query;

  /// Filter saved products based on category & search query
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

  /// Toggle saved status of a product
  Future<void> toggleSaved(int productId) async {
    final currentProducts = state.value ?? [];
    final currentIds = currentProducts.map((p) => p.id).toSet();
    final updatedIds = {...currentIds};

    if (updatedIds.contains(productId)) {
      updatedIds.remove(productId);
    } else {
      updatedIds.add(productId);
    }

    await _localApi.saveIds(updatedIds);

    final remoteProducts = _remoteNotifier.state.value ?? [];
    final updatedProducts = remoteProducts
        .where((p) => updatedIds.contains(p.id))
        .toList();

    state = AsyncValue.data(updatedProducts);
  }
}

final localProductsNotifierProvider =
    AsyncNotifierProvider<LocalProductsNotifier, List<Product>>(
      LocalProductsNotifier.new,
    );
