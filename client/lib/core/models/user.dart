// Role model
class Role {
  final int id;
  final String name;
  final String? description;
  final List<RolePermission>? permissions;

  Role({
    required this.id,
    required this.name,
    this.description,
    this.permissions,
  });

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      permissions: json['permissions'] != null
          ? (json['permissions'] as List)
              .map((p) => RolePermission.fromJson(p))
              .toList()
          : null,
    );
  }
}

// UserRole model
class UserRole {
  final int id;
  final int userId;
  final int roleId;
  final String scopeType;
  final String scopeObjectId;
  final String? condition;
  final Role role;

  UserRole({
    required this.id,
    required this.userId,
    required this.roleId,
    required this.scopeType,
    required this.scopeObjectId,
    this.condition,
    required this.role,
  });

  factory UserRole.fromJson(Map<String, dynamic> json) {
    return UserRole(
      id: json['id'],
      userId: json['userId'],
      roleId: json['roleId'],
      scopeType: json['scopeType'],
      scopeObjectId: json['scopeObjectId'],
      condition: json['condition'],
      role: Role.fromJson(json['role']),
    );
  }
}

// Permission model
class Permission {
  final int id;
  final String name;
  final String? description;

  Permission({
    required this.id,
    required this.name,
    this.description,
  });

  factory Permission.fromJson(Map<String, dynamic> json) {
    return Permission(
      id: json['id'],
      name: json['name'],
      description: json['description'],
    );
  }
}

// RolePermission model
class RolePermission {
  final int id;
  final Permission permission;

  RolePermission({
    required this.id,
    required this.permission,
  });

  factory RolePermission.fromJson(Map<String, dynamic> json) {
    return RolePermission(
      id: json['id'],
      permission: Permission.fromJson(json['permission']),
    );
  }
}

class User {
  final String id;
  final String username;
  final String email;
  final DateTime createdAt;
  final DateTime? lastLoginAt;
  final bool? isLocked;
  final List<UserRole>? roles;

  User({
    required this.id,
    required this.username,
    required this.email,
    required this.createdAt,
    this.lastLoginAt,
    this.isLocked,
    this.roles,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'].toString(),
      username: json['username'],
      email: json['email'],
      createdAt: _parseDateTime(json['createdAt']),
      lastLoginAt: json['lastLoginAt'] != null 
          ? _parseDateTime(json['lastLoginAt']) 
          : null,
      isLocked: json['isLocked'],
      roles: json['roles'] != null
          ? (json['roles'] as List)
              .map((r) => UserRole.fromJson(r))
              .toList()
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
      'isLocked': isLocked,
      'roles': roles?.map((r) => {
        'id': r.id,
        'userId': r.userId,
        'roleId': r.roleId,
        'scopeType': r.scopeType,
        'scopeObjectId': r.scopeObjectId,
        'condition': r.condition,
        'role': {
          'id': r.role.id,
          'name': r.role.name,
          'description': r.role.description,
        }
      }).toList(),
    };
  }
} 