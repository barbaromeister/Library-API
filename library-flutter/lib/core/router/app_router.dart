import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/admin/presentation/admin_dashboard_screen.dart';
import '../../features/auth/presentation/login_screen.dart';
import '../../features/auth/presentation/profile_screen.dart';
import '../../features/auth/presentation/register_screen.dart';
import '../../features/auth/providers/auth_provider.dart';
import '../../features/books/presentation/book_detail_screen.dart';
import '../../features/books/presentation/book_list_screen.dart';
import '../../features/books/presentation/book_search_screen.dart';

final appRouterProvider = Provider<GoRouter>((ref) {
  final refreshListenable = ref.watch(authRouterListenableProvider);

  return GoRouter(
    initialLocation: '/books',
    refreshListenable: refreshListenable,
    redirect: (context, state) {
      final auth = ref.read(authProvider).value;
      final isLoggedIn = auth?.isAuthenticated ?? false;
      final isAdmin = auth?.isAdmin ?? false;
      final loc = state.matchedLocation;

      final loggingIn = loc == '/login' || loc == '/register';
      final protectedUser = loc == '/profile';
      final protectedAdmin = loc.startsWith('/admin');

      if (!isLoggedIn && protectedUser) return '/login';
      if (!isAdmin && protectedAdmin) return isLoggedIn ? '/books' : '/login';
      if (isLoggedIn && loggingIn) return '/books';
      return null;
    },
    routes: [
      GoRoute(path: '/login', builder: (_, __) => const LoginScreen()),
      GoRoute(path: '/register', builder: (_, __) => const RegisterScreen()),
      GoRoute(path: '/books', builder: (_, __) => const BookListScreen()),
      GoRoute(
        path: '/books/search',
        builder: (_, __) => const BookSearchScreen(),
      ),
      GoRoute(
        path: '/books/:id',
        builder: (_, state) =>
            BookDetailScreen(id: int.parse(state.pathParameters['id']!)),
      ),
      GoRoute(path: '/profile', builder: (_, __) => const ProfileScreen()),
      GoRoute(path: '/admin', builder: (_, __) => const AdminDashboardScreen()),
    ],
  );
});
