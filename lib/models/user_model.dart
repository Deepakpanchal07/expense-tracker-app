class UserModel {
  final String id;
  final String name;
  final String email;
  final String? token;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.token,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'token': token,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: (map['id'] ?? map['_id']) as String,
      name: map['name'] as String,
      email: map['email'] as String,
      token: map['token'] as String?,
    );
  }
}
