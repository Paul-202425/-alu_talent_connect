import '../entities/opportunity.dart';
import '../enums/opportunity_type.dart';
import '../enums/work_location.dart';

abstract class OpportunityRepository {
  /// Real-time feed of active opportunities, newest first.
  Stream<List<Opportunity>> watchActiveOpportunities();

  /// Single opportunity by ID with real-time updates.
  Stream<Opportunity?> watchOpportunity(String id);

  Future<Opportunity?> getOpportunity(String id);

  /// Real-time list of a startup's own postings (active and inactive).
  Stream<List<Opportunity>> watchOpportunitiesByStartup(String startupId);

  Future<Opportunity> createOpportunity({
    required String startupId,
    required String startupName,
    required String title,
    required String description,
    required WorkLocation location,
    required OpportunityType type,
    required List<String> requiredSkills,
    required String duration,
  });

  Future<void> setOpportunityActive({
    required String opportunityId,
    required bool isActive,
  });
}
