enum WorldStatus {
  upcoming,
  open,
  running,
  closed,
  archived,
}

class World {
  final int id;
  final String name;
  final WorldStatus status;
  final DateTime createdAt;
  final DateTime startsAt;
  final DateTime? endsAt;

  World({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.startsAt,
    this.endsAt,
  });

  factory World.fromJson(Map<String, dynamic> json) {
    return World(
      id: json['id'],
      name: json['name'],
      status: WorldStatus.values.firstWhere(
        (e) => e.toString().split('.').last == json['status'],
        orElse: () => WorldStatus.upcoming,
      ),
      createdAt: DateTime.parse(json['createdAt']),
      startsAt: DateTime.parse(json['startsAt']),
      endsAt: json['endsAt'] != null ? DateTime.parse(json['endsAt']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'status': status.toString().split('.').last,
      'createdAt': createdAt.toIso8601String(),
      'startsAt': startsAt.toIso8601String(),
      'endsAt': endsAt?.toIso8601String(),
    };
  }

  String get statusText {
    switch (status) {
      case WorldStatus.upcoming:
        return 'Bevorstehend';
      case WorldStatus.open:
        return 'Offen';
      case WorldStatus.running:
        return 'Läuft';
      case WorldStatus.closed:
        return 'Geschlossen';
      case WorldStatus.archived:
        return 'Archiviert';
    }
  }

  String get statusColor {
    switch (status) {
      case WorldStatus.upcoming:
        return '#FFA500'; // Orange
      case WorldStatus.open:
        return '#4CAF50'; // Green
      case WorldStatus.running:
        return '#2196F3'; // Blue
      case WorldStatus.closed:
        return '#F44336'; // Red
      case WorldStatus.archived:
        return '#9E9E9E'; // Grey
    }
  }

  bool get canJoin => status == WorldStatus.open || status == WorldStatus.running;
  bool get isActive => status == WorldStatus.running;
  bool get isArchived => status == WorldStatus.archived;
  
  // New helper methods for invites and pre-registration
  bool get canInvite => status == WorldStatus.open || status == WorldStatus.upcoming || status == WorldStatus.running;
  bool get canPreRegister => status == WorldStatus.upcoming;
  bool get isUpcoming => status == WorldStatus.upcoming;
  bool get isOpen => status == WorldStatus.open;
} 