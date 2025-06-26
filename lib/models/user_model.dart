class User {
  final int? id;
  final String username;
  final String password;

  User({this.id, required this.username, required this.password});

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['id'],
      username: map['username'],
      password: map['password'],
    );
  }

  Map<String, Object?> toMap() {
    return {
      'id': id,
      'username': username,
      'password': password,
    };
  }
}
