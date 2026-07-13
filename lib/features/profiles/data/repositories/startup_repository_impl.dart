import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/startup_profile.dart';
import '../../domain/repositories/startup_repository.dart';
import '../datasources/startup_remote_datasource.dart';

class StartupRepositoryImpl implements StartupRepository {
  StartupRepositoryImpl(this._remoteDataSource);

  final StartupRemoteDataSource _remoteDataSource;

  @override
  Stream<StartupProfile?> watchStartup(String startupId) {
    return _remoteDataSource.watchStartup(startupId);
  }

  @override
  Future<StartupProfile?> getStartup(String startupId) async {
    try {
      return await _remoteDataSource.getStartup(startupId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<StartupProfile?> getStartupByFounder(String founderId) async {
    try {
      return await _remoteDataSource.getStartupByFounder(founderId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<StartupProfile> createStartup({
    required String founderId,
    required String name,
    required String description,
    required String industry,
    int? teamSize,
    String? website,
  }) async {
    try {
      return await _remoteDataSource.createStartup(
        founderId: founderId,
        name: name,
        description: description,
        industry: industry,
        teamSize: teamSize,
        website: website,
      );
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
