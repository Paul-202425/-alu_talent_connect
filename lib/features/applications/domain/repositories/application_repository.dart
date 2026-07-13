import '../../../opportunities/domain/entities/opportunity.dart';
import '../entities/application.dart';
import '../enums/application_status.dart';

abstract class ApplicationRepository {
  /// Student's applications, newest first.
  Stream<List<Application>> watchStudentApplications(String applicantId);

  /// Applications for a startup's opportunities.
  Stream<List<Application>> watchStartupApplications(String startupId);

  /// Real-time status for a specific user + opportunity pair.
  Stream<Application?> watchApplicationForOpportunity({
    required String opportunityId,
    required String applicantId,
  });

  /// Check if student already applied to an opportunity.
  Future<bool> hasApplied({
    required String opportunityId,
    required String applicantId,
  });

  Future<Application> submitApplication({
    required String opportunityId,
    required String applicantId,
    required String applicantName,
    required String applicantEmail,
    String? coverLetter,
    Opportunity? opportunity,
  });

  Future<void> updateStatus({
    required String applicationId,
    required ApplicationStatus status,
  });
}
