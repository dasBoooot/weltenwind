class User {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLoginAt;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.lastLoginAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      createdAt: _parseDateTime(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null 
          ? _parseDateTime(json['lastLoginAt']) 
          : null,
    );
  }

  static DateTime _parseDateTime(dynamic dateValue) {
    if (dateValue is String) {
      try {
        return DateTime.parse(dateValue);
      } catch (e) {
        // Try different date formats
        try {
          return DateTime.parse(dateValue + 'Z'); // Add Z if missing timezone
        } catch (e2) {
          // If all parsing fails, return current time
          return DateTime.now();
        }
      }
    } else if (dateValue is DateTime) {
      return dateValue;
    } else {
      // Fallback to current time
      return DateTime.now();
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'createdAt': createdAt.toIso8601String(),
      'lastLoginAt': lastLoginAt?.toIso8601String(),
    };
  }
} 