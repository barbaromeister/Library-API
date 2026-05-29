import 'cover_images.dart';

class BookResponse {
  final int id;
  final String title;
  final String author;
  final String? isbn;
  final DateTime? publishDate;
  final int? pageCount;
  final String? googleBooksId;
  final String? publisher;
  final String? description;
  final String? language;
  final CoverImages? covers;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  BookResponse({
    required this.id,
    required this.title,
    required this.author,
    this.isbn,
    this.publishDate,
    this.pageCount,
    this.googleBooksId,
    this.publisher,
    this.description,
    this.language,
    this.covers,
    this.createdAt,
    this.updatedAt,
  });

  factory BookResponse.fromJson(Map<String, dynamic> json) => BookResponse(
        id: json['id'] as int,
        title: json['title'] as String,
        author: json['author'] as String,
        isbn: json['isbn'] as String?,
        publishDate: json['publishDate'] != null
            ? DateTime.parse(json['publishDate'] as String)
            : null,
        pageCount: json['pageCount'] as int?,
        googleBooksId: json['googleBooksId'] as String?,
        publisher: json['publisher'] as String?,
        description: json['description'] as String?,
        language: json['language'] as String?,
        covers: json['covers'] != null
            ? CoverImages.fromJson(json['covers'] as Map<String, dynamic>)
            : null,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
        updatedAt: json['updatedAt'] != null
            ? DateTime.parse(json['updatedAt'] as String)
            : null,
      );
}
