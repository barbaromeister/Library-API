import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/book_repository.dart';
import '../data/models/book_response.dart';
import '../data/models/search_response.dart';

final booksProvider = FutureProvider<List<BookResponse>>((ref) async {
  return ref.watch(bookRepositoryProvider).all();
});

final bookByIdProvider = FutureProvider.family<BookResponse, int>((ref, id) async {
  return ref.watch(bookRepositoryProvider).byId(id);
});

final googleSearchProvider =
    FutureProvider.autoDispose.family<SearchResponse, String>((ref, query) async {
  if (query.trim().length < 3) {
    return SearchResponse(query: query, count: 0, results: []);
  }
  return ref.watch(bookRepositoryProvider).googleSearch(query.trim());
});
