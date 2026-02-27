import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/services/shared_preferences_service.dart';

class LocalAuthApi {
  static const _tokenKey = "auth_token";

  final SharedPreferences prefs;

  LocalAuthApi(this.prefs);

  Future<void> saveToken(String token) async {
    await prefs.setString(_tokenKey, token);
  }

  String? getToken() {
    return prefs.getString(_tokenKey);
  }

  Future<void> clearToken() async {
    await prefs.remove(_tokenKey);
  }
}

final localAuthApiProvider = Provider<LocalAuthApi>((ref) {
  final prefs = ref.read(sharedPreferencesProvider);
  return LocalAuthApi(prefs);
});
