class User {
  const User({
    required this.id,
    required this.email,
    required this.nickname,
    required this.avatarUrl,
    required this.phoneNumber,
  });

  final String id;
  final String email;
  final String nickname;
  final String avatarUrl;
  final String phoneNumber;

  User copyWith({
    String? id,
    String? email,
    String? nickname,
    String? avatarUrl,
    String? phoneNumber,
  }) {
    return User(
      id: id ?? this.id,
      email: email ?? this.email,
      nickname: nickname ?? this.nickname,
      avatarUrl: avatarUrl ?? this.avatarUrl,
      phoneNumber: phoneNumber ?? this.phoneNumber,
    );
  }
}
