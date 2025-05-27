class User {
  final String id;
  final String email;
  final String username;
  final String passwordHash;
  final String? name;
  final String? profilePictureUrl;

  User({
    required this.id,
    required this.email,
    required this.username,
    required this.passwordHash,
    this.name,
    this.profilePictureUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id']?.toString() ?? json['id']?.toString() ?? '',
      email: json['email'],
      username: json['username'],
      passwordHash: json['passwordHash'] ?? '',
      name: json['name'],
      profilePictureUrl: json['profilePictureUrl'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'username': username,
      'passwordHash': passwordHash,
      if (name != null) 'name': name,
      if (profilePictureUrl != null) 'profilePictureUrl': profilePictureUrl,
    };
  }
}
