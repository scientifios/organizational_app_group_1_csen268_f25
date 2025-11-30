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

  factory User.fromMap(String id, Map<String, dynamic> data) {
    return User(
      id: id,
      email: data['email'] as String? ?? '',
      nickname: data['nickname'] as String? ?? '',
      avatarUrl: data['avatarUrl'] as String? ?? '',
      phoneNumber: data['phoneNumber'] as String? ?? '',
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'email': email,
      'nickname': nickname,
      'avatarUrl': avatarUrl,
      'phoneNumber': phoneNumber,
    };
  }

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
