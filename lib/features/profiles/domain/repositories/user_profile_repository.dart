import '../entities/user_profile.dart';

abstract class UserProfileRepository {
  Stream<UserProfile?> watchProfile(String userId);

  Future<UserProfile?> getProfile(String userId);

  /// Links a founder's account to the startup they just created.
  Future<void> linkStartup({required String userId, required String startupId});
}
