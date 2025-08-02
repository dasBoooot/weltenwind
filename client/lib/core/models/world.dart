import 'package:flutter/material.dart';
import '../../l10n/app_localizations.dart';

enum WorldStatus {
  upcoming,
  open,
  running,
  closed,
  archived,
}

enum WorldCategory {
  classic,
  pvp,
  event,
  experimental,
}

class World {
  final int id;
  final String name;
  final WorldStatus status;
  final DateTime createdAt;
  final DateTime startsAt;
  final DateTime? endsAt;
  final String? description;
  final WorldCategory category;
  final int playerCount;
  
  // 🎨 THEME INTEGRATION - World-spezifische Themes
  final String? themeBundle;
  final String? parentTheme;
  final Map<String, dynamic>? themeOverrides;
  final String? themeVariant;

  World({
    required this.id,
    required this.name,
    required this.status,
    required this.createdAt,
    required this.startsAt,
    this.endsAt,
    this.description,
    this.category = WorldCategory.classic,
    this.playerCount = 0,
    
    // 🎨 THEME FIELDS
    this.themeBundle,
    this.parentTheme,
    this.themeOverrides,
    this.themeVariant,
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
      description: json['description'],
      category: json['category'] != null 
        ? WorldCategory.values.firstWhere(
            (e) => e.toString().split('.').last == json['category'],
            orElse: () => WorldCategory.classic,
          )
        : WorldCategory.classic,
      playerCount: json['playerCount'] ?? 0,
      
      // 🎨 THEME FIELDS FROM DB
      themeBundle: json['themeBundle'] ?? json['theme_bundle'],
      parentTheme: json['parentTheme'] ?? json['parent_theme'],
      themeOverrides: json['themeOverrides'] ?? json['theme_overrides'],
      themeVariant: json['themeVariant'] ?? json['theme_variant'],
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
      'description': description,
      'category': category.toString().split('.').last,
      'playerCount': playerCount,
      
      // 🎨 THEME FIELDS  
      'themeBundle': themeBundle,
      'parentTheme': parentTheme,
      'themeOverrides': themeOverrides,
      'themeVariant': themeVariant,
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

// Extensions für Lokalisierung
extension WorldStatusLocalization on WorldStatus {
  String getDisplayName(BuildContext context) {
    switch (this) {
      case WorldStatus.upcoming:
        return AppLocalizations.of(context).worldStatusUpcoming;
      case WorldStatus.open:
        return AppLocalizations.of(context).worldStatusOpen;
      case WorldStatus.running:
        return AppLocalizations.of(context).worldStatusRunning;
      case WorldStatus.closed:
        return AppLocalizations.of(context).worldStatusClosed;
      case WorldStatus.archived:
        return AppLocalizations.of(context).worldStatusArchived;
    }
  }
}

extension WorldCategoryLocalization on WorldCategory {
  String getDisplayName(BuildContext context) {
    switch (this) {
      case WorldCategory.classic:
        return AppLocalizations.of(context).worldCategoryClassic;
      case WorldCategory.pvp:
        return AppLocalizations.of(context).worldCategoryPvP;
      case WorldCategory.event:
        return AppLocalizations.of(context).worldCategoryEvent;
      case WorldCategory.experimental:
        return AppLocalizations.of(context).worldCategoryExperimental;
    }
  }
  
  Color get color {
    switch (this) {
      case WorldCategory.classic:
        return Colors.blue;
      case WorldCategory.pvp:
        return Colors.red;
      case WorldCategory.event:
        return Colors.purple;
      case WorldCategory.experimental:
        return Colors.orange;
    }
  }
  
  IconData get icon {
    switch (this) {
      case WorldCategory.classic:
        return Icons.castle;
      case WorldCategory.pvp:
        return Icons.sports_martial_arts;
      case WorldCategory.event:
        return Icons.event;
      case WorldCategory.experimental:
        return Icons.science;
    }
  }
} 