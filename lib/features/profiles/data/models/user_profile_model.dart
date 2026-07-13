import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/database/firestore_field_names.dart';
import '../../domain/entities/user_profile.dart';

class UserProfileModel {
  const UserProfileModel({
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
  final String? startupId;
  final List<String> bookmarkedOpportunityIds;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory UserProfileModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return UserProfileModel(
      id: doc.id,
      email: data[FirestoreFields.email] as String? ?? '',
      fullName: data[FirestoreFields.fullName] as String? ?? '',
      role: UserRole.fromString(data[FirestoreFields.role] as String? ?? 'student'),
      bio: data[FirestoreFields.bio] as String?,
      skills: List<String>.from(data[FirestoreFields.skills] as List? ?? []),
      profileImageUrl: data[FirestoreFields.profileImageUrl] as String?,
      startupId: data[FirestoreFields.startupId] as String?,
      bookmarkedOpportunityIds: List<String>.from(
        data[FirestoreFields.bookmarkedOpportunityIds] as List? ?? [],
      ),
      createdAt: (data[FirestoreFields.createdAt] as Timestamp?)?.toDate(),
      updatedAt: (data[FirestoreFields.updatedAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore({bool isCreate = false}) {
    return {
      FirestoreFields.email: email.trim().toLowerCase(),
      FirestoreFields.fullName: fullName.trim(),
      FirestoreFields.role: role.value,
      FirestoreFields.bio: bio,
      FirestoreFields.skills: skills,
      FirestoreFields.profileImageUrl: profileImageUrl,
      FirestoreFields.startupId: startupId,
      FirestoreFields.bookmarkedOpportunityIds: bookmarkedOpportunityIds,
      if (isCreate) FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  UserProfile toEntity() {
    return UserProfile(
      id: id,
      email: email,
      fullName: fullName,
      role: role,
      bio: bio,
      skills: skills,
      profileImageUrl: profileImageUrl,
      startupId: startupId,
      bookmarkedOpportunityIds: bookmarkedOpportunityIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
