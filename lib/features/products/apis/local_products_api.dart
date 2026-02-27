import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/shared_preferences_service.dart';

class LocalProductsApi {
  static const _key = 'saved_product_ids';
  final SharedPreferences prefs;

  LocalProductsApi(this.prefs);

  Set<int> getSavedIds() {
    final ids = prefs.getStringList(_key) ?? [];
    return ids.map(int.parse).toSet();
  }

  Future<void> saveIds(Set<int> ids) async {
    await prefs.setStringList(_key, ids.map((e) => e.toString()).toList());
  }
}

final localProductsApiProvider = Provider<LocalProductsApi>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return LocalProductsApi(prefs);
});
