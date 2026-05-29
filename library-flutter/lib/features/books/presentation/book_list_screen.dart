import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/responsive/breakpoints.dart';
import '../../../shared/widgets/async_value_widget.dart';
import '../../auth/providers/auth_provider.dart';
import '../providers/book_providers.dart';
import 'widgets/book_card.dart';

class BookListScreen extends ConsumerWidget {
  const BookListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final books = ref.watch(booksProvider);
    final auth = ref.watch(authProvider).value;
    final cols = Breakpoints.gridColumns(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Library'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            tooltip: 'Search Google Books',
            onPressed: () => context.go('/books/search'),
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh',
            onPressed: () => ref.invalidate(booksProvider),
          ),
          if (auth?.isAuthenticated ?? false)
            IconButton(
              icon: const Icon(Icons.account_circle),
              tooltip: 'Profile',
              onPressed: () => context.go('/profile'),
            )
          else
            TextButton(
              onPressed: () => context.go('/login'),
              child: const Text('Sign in'),
            ),
        ],
      ),
      body: AsyncValueWidget(
        value: books,
        data: (list) {
          if (list.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.menu_book, size: 96, color: Colors.grey),
                  const SizedBox(height: 16),
                  const Text('No books yet'),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: () => context.go('/books/search'),
                    icon: const Icon(Icons.search),
                    label: const Text('Search Google Books'),
                  ),
                ],
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async => ref.invalidate(booksProvider),
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                childAspectRatio: 0.55,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
              ),
              itemCount: list.length,
              itemBuilder: (_, i) => BookCard(
                book: list[i],
                onTap: () => context.go('/books/${list[i].id}'),
              ),
            ),
          );
        },
      ),
      floatingActionButton: (auth?.isAuthenticated ?? false)
          ? FloatingActionButton.extended(
              onPressed: () => context.go('/books/search'),
              icon: const Icon(Icons.add),
              label: const Text('Add book'),
            )
          : null,
    );
  }
}
