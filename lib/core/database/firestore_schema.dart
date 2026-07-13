import '../constants/app_constants.dart';
import 'firestore_field_names.dart';

/// Firestore database design for ALU Talent Connect.
///
/// ## Entity Relationship Overview
///
/// ```
/// users ──────────────┐
///   │                 │ founderId
///   │ startupId       ▼
///   └──────────► startups
///                     │
///                     │ startupId
///                     ▼
///               opportunities
///                     │
///                     │ opportunityId
///                     ▼
///               applications ◄── applicantId ── users
/// ```
///
/// ## Design Principles
///
/// 1. **Denormalization** — Feed and list views embed `startupName`,
///    `opportunityTitle`, etc. to avoid N+1 reads (Firestore has no joins).
/// 2. **Flat top-level collections** — Easier to query across entities than
///    deep subcollections. Scales to millions of docs with composite indexes.
/// 3. **Deterministic application IDs** — `{opportunityId}_{applicantId}`
///    enforces one application per student per opportunity without transactions.
/// 4. **Counters** — `applicationCount` on opportunities enables popularity
///    sorting without aggregating the applications collection.
/// 5. **Soft deletes** — Opportunities use `isActive: false` instead of
///    hard deletes, preserving application history.
abstract final class FirestoreSchema {
  static const collections = [
    AppConstants.usersCollection,
    AppConstants.startupsCollection,
    AppConstants.opportunitiesCollection,
    AppConstants.applicationsCollection,
  ];

  /// Builds a deterministic application document ID.
  static String applicationDocId({
    required String opportunityId,
    required String applicantId,
  }) {
    return '${opportunityId}_$applicantId';
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// SAMPLE DOCUMENTS (paste into Firestore console or use seed script)
// ─────────────────────────────────────────────────────────────────────────────

/// ```json
/// // users/{uid}
/// {
///   "email": "amara.k@alu.edu",
///   "fullName": "Amara Kabanda",
///   "role": "student",
///   "bio": "CS student passionate about fintech and product design.",
///   "skills": ["Flutter", "UI Design", "Python"],
///   "profileImageUrl": null,
///   "startupId": null,
///   "bookmarkedOpportunityIds": ["opp_techbridge_001"],
///   "createdAt": "<timestamp>",
///   "updatedAt": "<timestamp>"
/// }
/// ```
abstract final class SampleUserDocument {
  static const Map<String, dynamic> student = {
    FirestoreFields.email: 'amara.k@alu.edu',
    FirestoreFields.fullName: 'Amara Kabanda',
    FirestoreFields.role: 'student',
    FirestoreFields.bio: 'CS student passionate about fintech and product design.',
    FirestoreFields.skills: ['Flutter', 'UI Design', 'Python'],
    FirestoreFields.profileImageUrl: null,
    FirestoreFields.startupId: null,
    FirestoreFields.bookmarkedOpportunityIds: ['opp_techbridge_001'],
  };

  static const Map<String, dynamic> founder = {
    FirestoreFields.email: 'david.m@alu.edu',
    FirestoreFields.fullName: 'David Mwangi',
    FirestoreFields.role: 'startup_founder',
    FirestoreFields.bio: 'Building TechBridge — connecting rural merchants to digital payments.',
    FirestoreFields.skills: ['Leadership', 'Business Development'],
    FirestoreFields.profileImageUrl: null,
    FirestoreFields.startupId: 'startup_techbridge',
    FirestoreFields.bookmarkedOpportunityIds: [],
  };
}

/// ```json
/// // startups/{startupId}
/// {
///   "name": "TechBridge",
///   "description": "A student-led fintech startup digitizing informal trade in East Africa.",
///   "industry": "Fintech",
///   "logoUrl": null,
///   "founderId": "uid_david_mwangi",
///   "website": "https://techbridge.example.com",
///   "teamSize": 4,
///   "createdAt": "<timestamp>",
///   "updatedAt": "<timestamp>"
/// }
/// ```
abstract final class SampleStartupDocument {
  static const id = 'startup_techbridge';

  static const Map<String, dynamic> document = {
    FirestoreFields.name: 'TechBridge',
    FirestoreFields.description:
        'A student-led fintech startup digitizing informal trade in East Africa.',
    FirestoreFields.industry: 'Fintech',
    FirestoreFields.logoUrl: null,
    FirestoreFields.founderId: 'uid_david_mwangi',
    FirestoreFields.website: 'https://techbridge.example.com',
    FirestoreFields.teamSize: 4,
  };
}

/// ```json
/// // opportunities/{opportunityId}
/// {
///   "title": "Mobile Developer Intern",
///   "description": "Build and ship features for our Flutter mobile app...",
///   "startupId": "startup_techbridge",
///   "startupName": "TechBridge",
///   "location": "hybrid",
///   "type": "internship",
///   "requiredSkills": ["Flutter", "Dart", "Git"],
///   "duration": "3 months",
///   "isActive": true,
///   "applicationCount": 2,
///   "createdAt": "<timestamp>",
///   "updatedAt": "<timestamp>",
///   "expiresAt": "<timestamp>"
/// }
/// ```
abstract final class SampleOpportunityDocument {
  static const id = 'opp_techbridge_001';

  static const Map<String, dynamic> document = {
    FirestoreFields.title: 'Mobile Developer Intern',
    FirestoreFields.description:
        'Build and ship features for our Flutter mobile app used by 500+ merchants. '
        'You will work directly with the founding team on UI, API integration, and testing.',
    FirestoreFields.startupId: SampleStartupDocument.id,
    FirestoreFields.startupName: 'TechBridge',
    FirestoreFields.location: 'hybrid',
    FirestoreFields.type: 'internship',
    FirestoreFields.requiredSkills: ['Flutter', 'Dart', 'Git'],
    FirestoreFields.duration: '3 months',
    FirestoreFields.isActive: true,
    FirestoreFields.applicationCount: 2,
    FirestoreFields.expiresAt: null,
  };
}

/// ```json
/// // applications/{opportunityId}_{applicantId}
/// {
///   "opportunityId": "opp_techbridge_001",
///   "opportunityTitle": "Mobile Developer Intern",
///   "startupId": "startup_techbridge",
///   "startupName": "TechBridge",
///   "applicantId": "uid_amara_kabanda",
///   "applicantName": "Amara Kabanda",
///   "applicantEmail": "amara.k@alu.edu",
///   "coverLetter": "I have built two Flutter apps and am excited to contribute...",
///   "status": "pending",
///   "createdAt": "<timestamp>",
///   "updatedAt": "<timestamp>"
/// }
/// ```
abstract final class SampleApplicationDocument {
  static const id = 'opp_techbridge_001_uid_amara_kabanda';

  static const Map<String, dynamic> document = {
    FirestoreFields.opportunityId: SampleOpportunityDocument.id,
    FirestoreFields.opportunityTitle: 'Mobile Developer Intern',
    FirestoreFields.startupId: SampleStartupDocument.id,
    FirestoreFields.startupName: 'TechBridge',
    FirestoreFields.applicantId: 'uid_amara_kabanda',
    FirestoreFields.applicantName: 'Amara Kabanda',
    FirestoreFields.applicantEmail: 'amara.k@alu.edu',
    FirestoreFields.coverLetter:
        'I have built two Flutter apps and am excited to contribute to TechBridge.',
    FirestoreFields.status: 'pending',
  };
}

/// Common query patterns and their required composite indexes.
abstract final class FirestoreQueries {
  /// Feed: active opportunities, newest first.
  /// Index: opportunities — isActive ASC, createdAt DESC
  static const opportunityFeed = 'opportunities where isActive==true orderBy createdAt desc';

  /// Student dashboard: my applications, newest first.
  /// Index: applications — applicantId ASC, createdAt DESC
  static const studentApplications =
      'applications where applicantId=={uid} orderBy createdAt desc';

  /// Startup dashboard: applications for my opportunities.
  /// Index: applications — startupId ASC, createdAt DESC
  static const startupApplications =
      'applications where startupId=={startupId} orderBy createdAt desc';

  /// Recommendations: match skills (client-side filter after fetch, or
  /// array-contains-any on requiredSkills for ≤10 skills).
  static const skillMatch =
      'opportunities where isActive==true and requiredSkills array-contains-any [...]';
}
