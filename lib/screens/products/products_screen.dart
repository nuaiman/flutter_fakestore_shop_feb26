import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../features/auth/notifiers/auth_notifier.dart';
import '../../features/products/notifiers/local_products_notifier.dart';
import '../../features/products/notifiers/remote_products_notifier.dart';
import '../auth/login_screen.dart';
import '../auth/profile_screen.dart';

class ProductsScreen extends ConsumerStatefulWidget {
  const ProductsScreen({super.key});

  @override
  ConsumerState<ProductsScreen> createState() => _ProductsScreenState();
}

class _ProductsScreenState extends ConsumerState<ProductsScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  late final ScrollController _scrollController;
  bool _showBackToTop = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _scrollController = ScrollController();
    _scrollController.addListener(() {
      if (_scrollController.offset > 100 && !_showBackToTop) {
        setState(() => _showBackToTop = true);
      } else if (_scrollController.offset <= 100 && _showBackToTop) {
        setState(() => _showBackToTop = false);
      }
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _onRefresh() async {
    await Future.wait([
      ref.read(remoteProductsNotifierProvider.notifier).fetchRemoteProducts(),
      ref.read(localProductsNotifierProvider.notifier).fetchLocalProducts(),
    ]);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final remoteAsync = ref.watch(remoteProductsNotifierProvider);
    final localAsync = ref.watch(localProductsNotifierProvider);

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: NestedScrollView(
        controller: _scrollController,
        headerSliverBuilder: (context, innerBoxIsScrolled) => [
          SliverAppBar(
            pinned: true,
            floating: true,
            snap: false,
            expandedHeight: 220,
            backgroundColor: Colors.white,
            surfaceTintColor: Colors.white,
            elevation: 0,
            centerTitle: false,
            title: const Text(
              "D'razi",
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black87,
              ),
            ),
            actions: [
              IconButton(
                onPressed: () {
                  final auth = ref.read(authNotifierProvider.notifier);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => auth.isAuthenticated
                          ? const ProfileScreen()
                          : const LoginScreen(),
                    ),
                  );
                },
                icon: const Icon(Icons.person_outline, color: Colors.black87),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              collapseMode: CollapseMode.pin,
              background: SafeArea(
                child: Column(
                  children: [
                    const SizedBox(height: 56),
                    _buildSearchBar(),
                    _buildCategoryChips(),
                  ],
                ),
              ),
            ),
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: theme.primaryColor,
              indicatorWeight: 3,
              labelColor: Colors.black,
              unselectedLabelColor: Colors.grey,
              indicatorSize: TabBarIndicatorSize.label,
              tabs: const [
                Tab(text: "Remote"),
                Tab(text: "Local"),
              ],
            ),
          ),
        ],
        body: TabBarView(
          controller: _tabController,
          children: [
            _buildProductGrid(remoteAsync, isRemote: true),
            _buildProductGrid(localAsync, isRemote: false),
          ],
        ),
      ),
      floatingActionButton: _showBackToTop
          ? FloatingActionButton(
              onPressed: () {
                _scrollController.animateTo(
                  0,
                  duration: const Duration(milliseconds: 500),
                  curve: Curves.easeOut,
                );
              },
              child: const Icon(Icons.arrow_upward),
            )
          : null,
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        controller: _searchController,
        onChanged: (val) {
          final query = val.isEmpty ? null : val;
          if (_tabController.index == 0) {
            ref
                .read(remoteProductsNotifierProvider.notifier)
                .setSearchQuery(query);
          } else {
            ref
                .read(localProductsNotifierProvider.notifier)
                .setSearchQuery(query);
          }
          setState(() {}); // needed to rebuild suffix icon visibility
        },
        decoration: InputDecoration(
          hintText: "Search products...",
          prefixIcon: const Icon(Icons.search, size: 20),
          suffixIcon: _searchController.text.isEmpty
              ? null
              : IconButton(
                  icon: const Icon(Icons.clear, size: 20),
                  onPressed: () {
                    _searchController.clear();
                    if (_tabController.index == 0) {
                      ref
                          .read(remoteProductsNotifierProvider.notifier)
                          .setSearchQuery(null);
                    } else {
                      ref
                          .read(localProductsNotifierProvider.notifier)
                          .setSearchQuery(null);
                    }
                    setState(() {}); // rebuild to hide clear button
                  },
                ),
          filled: true,
          fillColor: Colors.grey[100],
          contentPadding: EdgeInsets.zero,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: BorderSide.none,
          ),
        ),
      ),
    );
  }

  Widget _buildCategoryChips() {
    final categories = _tabController.index == 0
        ? ref.read(remoteProductsNotifierProvider.notifier).getCategories()
        : ref.read(localProductsNotifierProvider.notifier).getCategories();
    final selected = _tabController.index == 0
        ? ref
              .read(remoteProductsNotifierProvider.notifier)
              .getSelectedCategory()
        : ref
              .read(localProductsNotifierProvider.notifier)
              .getSelectedCategory();

    return SizedBox(
      height: 50,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: categories.length,
        itemBuilder: (_, index) {
          final cat = categories[index];
          final isSelected = cat == selected;
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: ChoiceChip(
              label: Text(cat),
              selected: isSelected,
              selectedColor: Colors.black87,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : Colors.black87,
                fontSize: 13,
              ),
              onSelected: (_) {
                _tabController.index == 0
                    ? ref
                          .read(remoteProductsNotifierProvider.notifier)
                          .setSelectedCategory(isSelected ? null : cat)
                    : ref
                          .read(localProductsNotifierProvider.notifier)
                          .setSelectedCategory(isSelected ? null : cat);
                setState(() {});
              },
            ),
          );
        },
      ),
    );
  }

  Widget _buildProductGrid(AsyncValue asyncState, {required bool isRemote}) {
    return RefreshIndicator(
      onRefresh: _onRefresh,
      child: asyncState.when(
        loading: () =>
            const Center(child: CircularProgressIndicator.adaptive()),
        error: (e, _) => Center(child: Text("Failed to load products: $e")),
        data: (_) {
          final products = isRemote
              ? ref
                    .read(remoteProductsNotifierProvider.notifier)
                    .getFilteredProducts()
              : ref
                    .read(localProductsNotifierProvider.notifier)
                    .getFilteredProducts();

          if (products.isEmpty) {
            return const Center(child: Text("No products found."));
          }

          return GridView.builder(
            padding: const EdgeInsets.all(16),
            // Bouncing physics makes the refresh indicator feel native
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              childAspectRatio: 0.75,
            ),
            itemCount: products.length,
            itemBuilder: (_, index) {
              final product = products[index];
              // Check if product is saved (if remote, check against local list)
              final isSaved =
                  !isRemote ||
                  (ref
                          .watch(localProductsNotifierProvider)
                          .value
                          ?.any((p) => p.id == product.id) ??
                      false);

              return _ProductCard(
                product: product,
                isSaved: isSaved,
                onFavorite: () => ref
                    .read(localProductsNotifierProvider.notifier)
                    .toggleSaved(product.id),
              );
            },
          );
        },
      ),
    );
  }
}

class _ProductCard extends StatelessWidget {
  final dynamic product;
  final bool isSaved;
  final VoidCallback onFavorite;

  const _ProductCard({
    required this.product,
    required this.isSaved,
    required this.onFavorite,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  child: Center(
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Image.network(
                        product.image,
                        fit: BoxFit.contain,
                        errorBuilder: (_, _, _) =>
                            const Icon(Icons.broken_image),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  top: 8,
                  right: 8,
                  child: IconButton.filledTonal(
                    onPressed: onFavorite,
                    icon: Icon(
                      isSaved ? Icons.favorite : Icons.favorite_border,
                      color: isSaved ? Colors.red : Colors.grey,
                      size: 20,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.title,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "\$${product.price}",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
