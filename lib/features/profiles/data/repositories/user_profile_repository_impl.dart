import '../../../../core/errors/exceptions.dart';
import '../../../../core/errors/failures.dart';
import '../../domain/entities/user_profile.dart';
import '../../domain/repositories/user_profile_repository.dart';
import '../datasources/user_profile_remote_datasource.dart';

class UserProfileRepositoryImpl implements UserProfileRepository {
  UserProfileRepositoryImpl(this._remoteDataSource);

  final UserProfileRemoteDataSource _remoteDataSource;

  @override
  Stream<UserProfile?> watchProfile(String userId) {
    return _remoteDataSource.watchProfile(userId);
  }

  @override
  Future<UserProfile?> getProfile(String userId) async {
    try {
      return await _remoteDataSource.getProfile(userId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }

  @override
  Future<void> linkStartup({required String userId, required String startupId}) async {
    try {
      await _remoteDataSource.linkStartup(userId: userId, startupId: startupId);
    } on ServerException catch (e) {
      throw ServerFailure(e.message);
    }
  }
}
