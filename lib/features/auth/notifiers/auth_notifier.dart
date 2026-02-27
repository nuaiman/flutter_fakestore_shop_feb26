import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../models/user.dart';
import '../apis/local_auth_api.dart';
import '../apis/remote_auth_api.dart';

class AuthNotifier extends AsyncNotifier<User?> {
  late final RemoteAuthApi _remoteApi;
  late final LocalAuthApi _localApi;

  @override
  Future<User?> build() async {
    _remoteApi = ref.read(remoteAuthApiProvider);
    _localApi = ref.read(localAuthApiProvider);

    final token = _localApi.getToken();
    if (token == null) return null;

    try {
      final userMap = await _remoteApi.fetchUser(1);
      return User.fromMap(userMap);
    } catch (_) {
      await _localApi.clearToken();
      return null;
    }
  }

  bool get isAuthenticated => _localApi.getToken() != null;

  Future<void> login(String username, String password) async {
    state = const AsyncValue.loading();

    try {
      final token = await _remoteApi.login(
        username: username,
        password: password,
      );

      await _localApi.saveToken(token);

      final userMap = await _remoteApi.fetchUser(1);
      final user = User.fromMap(userMap);

      state = AsyncValue.data(user);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<void> logout() async {
    await _localApi.clearToken();
    state = const AsyncValue.data(null);
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, User?>(
  AuthNotifier.new,
);
