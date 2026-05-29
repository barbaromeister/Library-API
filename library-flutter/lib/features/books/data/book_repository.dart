import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/api/api_client.dart';
import 'models/add_to_collection_request.dart';
import 'models/book_response.dart';
import 'models/collection_check_response.dart';
import 'models/google_book_result.dart';
import 'models/search_response.dart';

class BookRepository {
  final Dio _dio;
  BookRepository(this._dio);

  Future<List<BookResponse>> all() async {
    final res = await _dio.get('/api/books');
    return (res.data as List)
        .map((e) => BookResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BookResponse> byId(int id) async {
    final res = await _dio.get('/api/books/$id');
    return BookResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<BookResponse>> searchByAuthor(String author) async {
    final res = await _dio.get('/api/books/search/author',
        queryParameters: {'author': author});
    return (res.data as List)
        .map((e) => BookResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<List<BookResponse>> searchByTitle(String title) async {
    final res = await _dio.get('/api/books/search/title',
        queryParameters: {'title': title});
    return (res.data as List)
        .map((e) => BookResponse.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<SearchResponse> googleSearch(String query, {int maxResults = 10}) async {
    final res = await _dio.get('/api/books/google-search', queryParameters: {
      'query': query,
      'maxResults': maxResults,
    });
    return SearchResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<List<GoogleBookResult>> googleSuggest(String query, {int limit = 5}) async {
    final res = await _dio.get('/api/books/google-suggest', queryParameters: {
      'query': query,
      'limit': limit,
    });
    return (res.data as List)
        .map((e) => GoogleBookResult.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  Future<BookResponse> addToCollection(String googleBooksId) async {
    final res = await _dio.post(
      '/api/books/collection',
      data: AddToCollectionRequest(googleBooksId: googleBooksId).toJson(),
    );
    return BookResponse.fromJson(res.data as Map<String, dynamic>);
  }

  Future<CollectionCheckResponse> checkInCollection(String googleBooksId) async {
    final res = await _dio.get('/api/books/collection/check',
        queryParameters: {'googleBooksId': googleBooksId});
    return CollectionCheckResponse.fromJson(res.data as Map<String, dynamic>);
  }
}

final bookRepositoryProvider = Provider<BookRepository>(
  (ref) => BookRepository(ref.watch(dioProvider)),
);
