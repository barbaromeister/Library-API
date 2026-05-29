import 'google_book_result.dart';

class SearchResponse {
  final String query;
  final int count;
  final List<GoogleBookResult> results;

  SearchResponse({required this.query, required this.count, required this.results});

  factory SearchResponse.fromJson(Map<String, dynamic> json) => SearchResponse(
        query: json['query'] as String,
        count: json['count'] as int,
        results: (json['results'] as List<dynamic>)
            .map((e) => GoogleBookResult.fromJson(e as Map<String, dynamic>))
            .toList(),
      );
}
