class AddToCollectionRequest {
  final String googleBooksId;
  AddToCollectionRequest({required this.googleBooksId});
  Map<String, dynamic> toJson() => {'googleBooksId': googleBooksId};
}
