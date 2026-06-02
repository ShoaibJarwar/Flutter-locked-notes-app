class UserModel {
  final int? id;
  final String name;
  final String email;
  final String password;

  const UserModel({
    this.id,
    required this.name,
    required this.email,
    required this.password,
  });

  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'email': email,
      'password': password,
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] as int?,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      password: map['password'] as String? ?? '',
    );
  }

  @override
  String toString() => 'User(id: $id, email: $email)';
}
