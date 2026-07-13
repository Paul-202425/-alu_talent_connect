import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../../opportunities/domain/entities/opportunity.dart';
import '../../domain/entities/application.dart';
import '../../domain/enums/application_status.dart';
import '../../domain/repositories/application_repository.dart';
import '../datasources/application_remote_datasource.dart';

class ApplicationRepositoryImpl implements ApplicationRepository {
  ApplicationRepositoryImpl(this._remoteDataSource);

  final ApplicationRemoteDataSource _remoteDataSource;

  @override
  Stream<List<Application>> watchStudentApplications(String applicantId) {
    return _remoteDataSource.watchStudentApplications(applicantId);
  }

  @override
  Stream<List<Application>> watchStartupApplications(String startupId) {
    return _remoteDataSource.watchStartupApplications(startupId);
  }

  @override
  Stream<Application?> watchApplicationForOpportunity({
    required String opportunityId,
    required String applicantId,
  }) {
    return _remoteDataSource.watchApplicationForOpportunity(
      opportunityId: opportunityId,
      applicantId: applicantId,
    );
  }

  @override
  Future<bool> hasApplied({
    required String opportunityId,
    required String applicantId,
  }) {
    return _remoteDataSource.hasApplied(
      opportunityId: opportunityId,
      applicantId: applicantId,
    );
  }

  @override
  Future<Application> submitApplication({
    required String opportunityId,
    required String applicantId,
    required String applicantName,
    required String applicantEmail,
    String? coverLetter,
    Opportunity? opportunity,
  }) async {
    try {
      if (opportunity == null) {
        throw const ServerException('Opportunity data is required to apply.');
      }

      return await _remoteDataSource.submitApplication(
        opportunity: opportunity,
        applicantId: applicantId,
        applicantName: applicantName,
        applicantEmail: applicantEmail,
        coverLetter: coverLetter,
      );
    } on AuthException catch (e) {
      throw AuthFailure(e.message);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> updateStatus({
    required String applicationId,
    required ApplicationStatus status,
  }) async {
    try {
      await _remoteDataSource.updateStatus(
        applicationId: applicationId,
        status: status,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
