class CoverImages {
  final String? small;
  final String? thumbnail;
  final String? medium;
  final String? large;

  CoverImages({this.small, this.thumbnail, this.medium, this.large});

  factory CoverImages.fromJson(Map<String, dynamic> json) => CoverImages(
        small: json['small'] as String?,
        thumbnail: json['thumbnail'] as String?,
        medium: json['medium'] as String?,
        large: json['large'] as String?,
      );

  String? get best => large ?? medium ?? thumbnail ?? small;
}
