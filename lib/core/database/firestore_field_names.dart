/// Canonical Firestore field names — single source of truth for all collections.
/// Prevents typos and enables safe refactors across features.
abstract final class FirestoreFields {
  // ── Shared ──────────────────────────────────────────────────────────────────
  static const createdAt = 'createdAt';
  static const updatedAt = 'updatedAt';

  // ── users ───────────────────────────────────────────────────────────────────
  static const email = 'email';
  static const fullName = 'fullName';
  static const role = 'role';
  static const bio = 'bio';
  static const skills = 'skills';
  static const profileImageUrl = 'profileImageUrl';
  static const startupId = 'startupId';
  static const bookmarkedOpportunityIds = 'bookmarkedOpportunityIds';

  // ── startups ────────────────────────────────────────────────────────────────
  static const name = 'name';
  static const description = 'description';
  static const industry = 'industry';
  static const logoUrl = 'logoUrl';
  static const founderId = 'founderId';
  static const website = 'website';
  static const teamSize = 'teamSize';

  // ── opportunities ───────────────────────────────────────────────────────────
  static const title = 'title';
  static const startupName = 'startupName';
  static const location = 'location';
  static const type = 'type';
  static const requiredSkills = 'requiredSkills';
  static const duration = 'duration';
  static const isActive = 'isActive';
  static const applicationCount = 'applicationCount';
  static const expiresAt = 'expiresAt';

  // ── applications ────────────────────────────────────────────────────────────
  static const opportunityId = 'opportunityId';
  static const opportunityTitle = 'opportunityTitle';
  static const applicantId = 'applicantId';
  static const applicantName = 'applicantName';
  static const applicantEmail = 'applicantEmail';
  static const coverLetter = 'coverLetter';
  static const status = 'status';
}
