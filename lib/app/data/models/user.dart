class User {
  final int id;
  final String email;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String role;

  User({
    required this.id,
    required this.email,
    this.firstName,
    this.lastName,
    this.fullName,
    required this.role,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      email: json['email'] ?? '',
      firstName: json['first_name'],
      lastName: json['last_name'],
      fullName: json['full_name'],
      role: json['role'] ?? 'STUDENT',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'email': email,
      'first_name': firstName,
      'last_name': lastName,
      'full_name': fullName,
      'role': role,
    };
  }
}

enum UserRole { ADMIN, TEACHER, STUDENT, PARENT }

extension UserRoleExtension on UserRole {
  String get value {
    switch (this) {
      case UserRole.ADMIN:
        return 'ADMIN';
      case UserRole.TEACHER:
        return 'TEACHER';
      case UserRole.STUDENT:
        return 'STUDENT';
      case UserRole.PARENT:
        return 'PARENT';
    }
  }

  static UserRole fromString(String role) {
    switch (role.toUpperCase()) {
      case 'ADMIN':
        return UserRole.ADMIN;
      case 'TEACHER':
        return UserRole.TEACHER;
      case 'STUDENT':
        return UserRole.STUDENT;
      case 'PARENT':
        return UserRole.PARENT;
      default:
        return UserRole.STUDENT;
    }
  }
}
