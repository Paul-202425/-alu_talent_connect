import 'package:equatable/equatable.dart';

/// Distinguishes student seekers from startup founders posting opportunities.
enum UserRole {
  student('student'),
  startupFounder('startup_founder');

  const UserRole(this.value);

  final String value;

  static UserRole fromString(String value) {
    return UserRole.values.firstWhere(
      (role) => role.value == value,
      orElse: () => UserRole.student,
    );
  }
}

/// Core user profile entity stored in Firestore `users` collection.
class UserProfile extends Equatable {
  const UserProfile({
    required this.id,
    required this.email,
    required this.fullName,
    required this.role,
    this.bio,
    this.skills = const [],
    this.profileImageUrl,
    this.startupId,
    this.bookmarkedOpportunityIds = const [],
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String email;
  final String fullName;
  final UserRole role;
  final String? bio;
  final List<String> skills;
  final String? profileImageUrl;

  /// Reference to `startups/{startupId}` — set for startup founders.
  final String? startupId;

  /// Denormalized bookmark list for quick lookups (Step 8).
  final List<String> bookmarkedOpportunityIds;

  final DateTime? createdAt;
  final DateTime? updatedAt;

  bool get isStudent => role == UserRole.student;
  bool get isStartupFounder => role == UserRole.startupFounder;

  bool hasBookmarked(String opportunityId) {
    return bookmarkedOpportunityIds.contains(opportunityId);
  }

  @override
  List<Object?> get props => [
        id,
        email,
        fullName,
        role,
        bio,
        skills,
        profileImageUrl,
        startupId,
        bookmarkedOpportunityIds,
        createdAt,
        updatedAt,
      ];
}
