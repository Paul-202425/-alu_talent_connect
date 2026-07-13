import '../../domain/entities/startup_profile.dart';

abstract class StartupRepository {
  Stream<StartupProfile?> watchStartup(String startupId);

  Future<StartupProfile?> getStartup(String startupId);

  Future<StartupProfile?> getStartupByFounder(String founderId);

  Future<StartupProfile> createStartup({
    required String founderId,
    required String name,
    required String description,
    required String industry,
    int? teamSize,
    String? website,
  });
}
