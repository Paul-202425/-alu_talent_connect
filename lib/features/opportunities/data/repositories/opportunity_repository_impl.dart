import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/enums/opportunity_type.dart';
import '../../domain/enums/work_location.dart';
import '../../domain/repositories/opportunity_repository.dart';
import '../datasources/opportunity_remote_datasource.dart';

class OpportunityRepositoryImpl implements OpportunityRepository {
  OpportunityRepositoryImpl(this._remoteDataSource);

  final OpportunityRemoteDataSource _remoteDataSource;

  @override
  Stream<List<Opportunity>> watchActiveOpportunities() {
    return _remoteDataSource.watchActiveOpportunities();
  }

  @override
  Stream<Opportunity?> watchOpportunity(String id) {
    return _remoteDataSource.watchOpportunity(id);
  }

  @override
  Future<Opportunity?> getOpportunity(String id) async {
    try {
      return await _remoteDataSource.getOpportunity(id);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Stream<List<Opportunity>> watchOpportunitiesByStartup(String startupId) {
    return _remoteDataSource.watchOpportunitiesByStartup(startupId);
  }

  @override
  Future<Opportunity> createOpportunity({
    required String startupId,
    required String startupName,
    required String title,
    required String description,
    required WorkLocation location,
    required OpportunityType type,
    required List<String> requiredSkills,
    required String duration,
  }) async {
    try {
      return await _remoteDataSource.createOpportunity(
        startupId: startupId,
        startupName: startupName,
        title: title,
        description: description,
        location: location,
        type: type,
        requiredSkills: requiredSkills,
        duration: duration,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> setOpportunityActive({
    required String opportunityId,
    required bool isActive,
  }) async {
    try {
      await _remoteDataSource.setOpportunityActive(
        opportunityId: opportunityId,
        isActive: isActive,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
