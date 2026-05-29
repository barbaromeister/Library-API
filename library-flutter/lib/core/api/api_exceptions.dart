class FieldError {
  final String field;
  final String message;
  FieldError(this.field, this.message);
}

class ApiException implements Exception {
  final int statusCode;
  final String message;
  final List<FieldError>? fieldErrors;

  ApiException(this.statusCode, this.message, [this.fieldErrors]);

  factory ApiException.fromMap(int code, Map<String, dynamic> data) {
    final raw = data['fieldErrors'];
    List<FieldError>? fes;
    if (raw is List) {
      fes = raw
          .whereType<Map<String, dynamic>>()
          .map((e) => FieldError(e['field']?.toString() ?? '', e['message']?.toString() ?? ''))
          .toList();
    }
    final msg = data['message']?.toString() ?? data['error']?.toString() ?? 'Error';
    return ApiException(code, msg, fes);
  }

  @override
  String toString() => message;
}
