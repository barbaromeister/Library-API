import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../data/auth_repository.dart';
import '../data/models/login_request.dart';
import '../data/models/register_request.dart';
import '../data/models/user_response.dart';

class AuthState {
  final String? token;
  final UserResponse? user;
  const AuthState({this.token, this.user});

  bool get isAuthenticated => token != null && user != null;
  bool get isAdmin => user?.isAdmin ?? false;
}

class AuthNotifier extends AsyncNotifier<AuthState> {
  @override
  Future<AuthState> build() async {
    final storage = ref.watch(secureTokenStorageProvider);
    final token = await storage.read();
    if (token == null || token.isEmpty) return const AuthState();

    final repo = ref.watch(authRepositoryProvider);
    try {
      final user = await repo.me();
      return AuthState(token: token, user: user);
    } catch (_) {
      await storage.clear();
      return const AuthState();
    }
  }

  Future<void> login(LoginRequest req) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final auth = await ref.read(authRepositoryProvider).login(req);
      await ref.read(secureTokenStorageProvider).write(auth.token);
      return AuthState(token: auth.token, user: auth.user);
    });
  }

  Future<void> register(RegisterRequest req) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final auth = await ref.read(authRepositoryProvider).register(req);
      await ref.read(secureTokenStorageProvider).write(auth.token);
      return AuthState(token: auth.token, user: auth.user);
    });
  }

  Future<void> logout() async {
    await ref.read(authRepositoryProvider).logout();
    await ref.read(secureTokenStorageProvider).clear();
    state = const AsyncValue.data(AuthState());
  }
}

final authProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);

/// Helper Listenable for go_router so it refreshes on auth changes.
class AuthRouterListenable extends ChangeNotifier {
  AuthRouterListenable(Ref ref) {
    ref.listen<AsyncValue<AuthState>>(authProvider, (_, __) => notifyListeners());
  }
}

final authRouterListenableProvider = Provider<AuthRouterListenable>(
  (ref) => AuthRouterListenable(ref),
);
