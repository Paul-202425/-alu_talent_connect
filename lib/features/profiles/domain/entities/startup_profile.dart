import 'package:equatable/equatable.dart';

/// Student-led startup profile stored in Firestore `startups` collection.
class StartupProfile extends Equatable {
  const StartupProfile({
    required this.id,
    required this.name,
    required this.description,
    required this.industry,
    required this.founderId,
    this.logoUrl,
    this.website,
    this.teamSize,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String name;
  final String description;
  final String industry;
  final String founderId;
  final String? logoUrl;
  final String? website;
  final int? teamSize;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        industry,
        founderId,
        logoUrl,
        website,
        teamSize,
        createdAt,
        updatedAt,
      ];
}
