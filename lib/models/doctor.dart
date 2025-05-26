class Doctor {
  final int? id;
  final String username;
  final String email;
  final String? fullName;
  final String? specialty;
  final DateTime? createdAt;
  final DateTime? lastLogin;

  Doctor({
    this.id,
    required this.username,
    required this.email,
    this.fullName,
    this.specialty,
    this.createdAt,
    this.lastLogin,
  });

  factory Doctor.fromJson(Map<String, dynamic> json) {
    return Doctor(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      fullName: json['full_name'],
      specialty: json['specialty'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : null,
      lastLogin: json['last_login'] != null
          ? DateTime.parse(json['last_login'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'full_name': fullName,
      'specialty': specialty,
      'created_at': createdAt?.toIso8601String(),
      'last_login': lastLogin?.toIso8601String(),
    };
  }

  @override
  String toString() {
    return 'Doctor{id: $id, username: $username, email: $email, fullName: $fullName, specialty: $specialty}';
  }
}
