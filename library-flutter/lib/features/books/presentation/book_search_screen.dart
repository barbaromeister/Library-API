import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/api/api_exceptions.dart';
import '../../auth/providers/auth_provider.dart';
import '../data/book_repository.dart';
import '../data/models/google_book_result.dart';
import '../providers/book_providers.dart';

class BookSearchScreen extends ConsumerStatefulWidget {
  const BookSearchScreen({super.key});

  @override
  ConsumerState<BookSearchScreen> createState() => _BookSearchScreenState();
}

class _BookSearchScreenState extends ConsumerState<BookSearchScreen> {
  final _ctrl = TextEditingController();
  String _query = '';
  Timer? _debounce;
  final Set<String> _adding = {};

  @override
  void dispose() {
    _debounce?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  void _onChanged(String value) {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      if (mounted) setState(() => _query = value.trim());
    });
  }

  Future<void> _add(GoogleBookResult r) async {
    setState(() => _adding.add(r.googleId));
    try {
      await ref.read(bookRepositoryProvider).addToCollection(r.googleId);
      ref.invalidate(booksProvider);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Added: ${r.title ?? "book"}')),
      );
    } on DioException catch (e) {
      if (!mounted) return;
      final msg = e.error is ApiException
          ? (e.error as ApiException).message
          : 'Failed to add book';
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(msg), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _adding.remove(r.googleId));
    }
  }

  @override
  Widget build(BuildContext context) {
    final auth = ref.watch(authProvider).value;
    final isLoggedIn = auth?.isAuthenticated ?? false;
    final search = ref.watch(googleSearchProvider(_query));

    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Google Books'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.go('/books'),
        ),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _ctrl,
              autofocus: true,
              decoration: InputDecoration(
                hintText: 'Title, author, ISBN…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _ctrl.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _ctrl.clear();
                          setState(() => _query = '');
                        },
                      )
                    : null,
              ),
              onChanged: _onChanged,
            ),
          ),
          if (!isLoggedIn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline),
                    const SizedBox(width: 8),
                    const Expanded(
                      child: Text('Sign in to add books to your collection.'),
                    ),
                    TextButton(
                      onPressed: () => context.go('/login'),
                      child: const Text('Sign in'),
                    ),
                  ],
                ),
              ),
            ),
          Expanded(
            child: _query.length < 3
                ? const Center(
                    child: Text('Type at least 3 characters to search'),
                  )
                : search.when(
                    loading: () => const Center(child: CircularProgressIndicator()),
                    error: (e, _) => Center(child: Text('Error: $e')),
                    data: (res) {
                      if (res.results.isEmpty) {
                        return const Center(child: Text('No results'));
                      }
                      return ListView.separated(
                        padding: const EdgeInsets.all(16),
                        itemCount: res.results.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 12),
                        itemBuilder: (_, i) {
                          final r = res.results[i];
                          final cover = r.bestCover;
                          final adding = _adding.contains(r.googleId);
                          return Card(
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: 64,
                                    height: 96,
                                    child: cover != null && cover.isNotEmpty
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(4),
                                            child: CachedNetworkImage(
                                              imageUrl: cover.replaceFirst('http://', 'https://'),
                                              fit: BoxFit.cover,
                                              errorWidget: (_, __, ___) =>
                                                  const Icon(Icons.menu_book),
                                            ),
                                          )
                                        : const Icon(Icons.menu_book, size: 48),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(r.title ?? '—',
                                            style:
                                                Theme.of(context).textTheme.titleSmall,
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis),
                                        if (r.authors != null) ...[
                                          const SizedBox(height: 4),
                                          Text(r.authors!,
                                              style: Theme.of(context).textTheme.bodySmall,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                        if (r.publisher != null) ...[
                                          const SizedBox(height: 4),
                                          Text(r.publisher!,
                                              style: Theme.of(context).textTheme.bodySmall,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  if (isLoggedIn)
                                    IconButton(
                                      onPressed: adding ? null : () => _add(r),
                                      icon: adding
                                          ? const SizedBox(
                                              height: 18,
                                              width: 18,
                                              child:
                                                  CircularProgressIndicator(strokeWidth: 2),
                                            )
                                          : const Icon(Icons.add_circle_outline),
                                      tooltip: 'Add to collection',
                                    ),
                                ],
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
