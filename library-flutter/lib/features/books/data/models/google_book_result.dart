class GoogleBookResult {
  final String googleId;
  final String? title;
  final String? subtitle;
  final String? authors;
  final String? publisher;
  final String? publishedDate;
  final String? description;
  final String? isbn10;
  final String? isbn13;
  final int? pageCount;
  final String? categories;
  final String? language;
  final String? smallThumbnail;
  final String? thumbnail;
  final String? smallImage;
  final String? mediumImage;
  final String? largeImage;
  final String? previewLink;
  final String? infoLink;

  GoogleBookResult({
    required this.googleId,
    this.title,
    this.subtitle,
    this.authors,
    this.publisher,
    this.publishedDate,
    this.description,
    this.isbn10,
    this.isbn13,
    this.pageCount,
    this.categories,
    this.language,
    this.smallThumbnail,
    this.thumbnail,
    this.smallImage,
    this.mediumImage,
    this.largeImage,
    this.previewLink,
    this.infoLink,
  });

  factory GoogleBookResult.fromJson(Map<String, dynamic> json) => GoogleBookResult(
        googleId: json['googleId'] as String,
        title: json['title'] as String?,
        subtitle: json['subtitle'] as String?,
        authors: json['authors'] as String?,
        publisher: json['publisher'] as String?,
        publishedDate: json['publishedDate'] as String?,
        description: json['description'] as String?,
        isbn10: json['isbn10'] as String?,
        isbn13: json['isbn13'] as String?,
        pageCount: json['pageCount'] as int?,
        categories: json['categories'] as String?,
        language: json['language'] as String?,
        smallThumbnail: json['smallThumbnail'] as String?,
        thumbnail: json['thumbnail'] as String?,
        smallImage: json['smallImage'] as String?,
        mediumImage: json['mediumImage'] as String?,
        largeImage: json['largeImage'] as String?,
        previewLink: json['previewLink'] as String?,
        infoLink: json['infoLink'] as String?,
      );

  String? get bestCover =>
      largeImage ?? mediumImage ?? smallImage ?? thumbnail ?? smallThumbnail;
}
