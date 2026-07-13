import 'package:equatable/equatable.dart';

import '../enums/opportunity_type.dart';
import '../enums/work_location.dart';

/// Internship / role listing posted by a startup.
/// Stored in Firestore `opportunities` collection.
class Opportunity extends Equatable {
  const Opportunity({
    required this.id,
    required this.title,
    required this.description,
    required this.startupId,
    required this.startupName,
    required this.location,
    required this.type,
    required this.requiredSkills,
    required this.duration,
    required this.isActive,
    this.applicationCount = 0,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  final String id;
  final String title;
  final String description;
  final String startupId;
  final String startupName;
  final WorkLocation location;
  final OpportunityType type;
  final List<String> requiredSkills;
  final String duration;
  final bool isActive;
  final int applicationCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;

  /// Skills overlap score for basic recommendation (Step 8).
  int skillMatchScore(List<String> userSkills) {
    if (userSkills.isEmpty || requiredSkills.isEmpty) return 0;
    final userSet = userSkills.map((s) => s.toLowerCase()).toSet();
    return requiredSkills
        .where((skill) => userSet.contains(skill.toLowerCase()))
        .length;
  }

  @override
  List<Object?> get props => [
        id,
        title,
        description,
        startupId,
        startupName,
        location,
        type,
        requiredSkills,
        duration,
        isActive,
        applicationCount,
        createdAt,
        updatedAt,
        expiresAt,
      ];
}
