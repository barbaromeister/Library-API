class CollectionCheckResponse {
  final bool inCollection;
  CollectionCheckResponse({required this.inCollection});
  factory CollectionCheckResponse.fromJson(Map<String, dynamic> json) =>
      CollectionCheckResponse(inCollection: json['inCollection'] as bool);
}
