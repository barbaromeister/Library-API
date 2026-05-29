class UserResponse {
  final int id;
  final String username;
  final String email;
  final String role;
  final DateTime? createdAt;

  UserResponse({
    required this.id,
    required this.username,
    required this.email,
    required this.role,
    this.createdAt,
  });

  factory UserResponse.fromJson(Map<String, dynamic> json) => UserResponse(
        id: json['id'] as int,
        username: json['username'] as String,
        email: json['email'] as String,
        role: json['role'] as String,
        createdAt: json['createdAt'] != null
            ? DateTime.parse(json['createdAt'] as String)
            : null,
      );

  bool get isAdmin => role == 'ADMIN';
}
