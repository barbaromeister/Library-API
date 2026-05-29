import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'models/auth_response.dart';
import 'models/login_request.dart';
import 'models/register_request.dart';
import 'models/user_response.dart';

class AuthRepository {
  final Dio _dio;
  AuthRepository(this._dio);

  Future<AuthResponse> login(LoginRequest req) async {
    final res = await _dio.post('/api/auth/login', data: req.toJson());
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<AuthResponse> register(RegisterRequest req) async {
    final res = await _dio.post('/api/auth/register', data: req.toJson());
    return AuthResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<UserResponse> me() async {
    final res = await _dio.get('/api/auth/me');
    return UserResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<void> logout() async {
    try {
      await _dio.post('/api/auth/logout');
    } catch (_) {
      // Stateless JWT — server-side logout is best-effort.
    }
  }
}

final authRepositoryProvider = Provider<AuthRepository>(
  (ref) => AuthRepository(ref.watch(dioProvider)),
);
