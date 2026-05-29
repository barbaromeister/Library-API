import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../auth/data/models/user_response.dart';
import '../data/admin_repository.dart';

final adminUsersProvider = FutureProvider<List<UserResponse>>((ref) async {
  return ref.watch(adminRepositoryProvider).allUsers();
});
