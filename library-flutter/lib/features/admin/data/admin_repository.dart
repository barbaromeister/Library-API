import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import '../../auth/data/models/user_response.dart';

class AdminRepository {
  final Dio _dio;
  AdminRepository(this._dio);

  Future<List<UserResponse>> allUsers() async {
    final res = await _dio.get('/api/admin/users');
    return (res.data as List)
        .map((e) => UserResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }
}

final adminRepositoryProvider = Provider<AdminRepository>(
  (ref) => AdminRepository(ref.watch(dioProvider)),
);
