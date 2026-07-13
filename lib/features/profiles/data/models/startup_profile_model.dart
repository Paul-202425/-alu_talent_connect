import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/database/firestore_field_names.dart';
import '../../domain/entities/startup_profile.dart';

class StartupProfileModel {
  const StartupProfileModel({
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

  factory StartupProfileModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return StartupProfileModel(
      id: doc.id,
      name: data[FirestoreFields.name] as String? ?? '',
      description: data[FirestoreFields.description] as String? ?? '',
      industry: data[FirestoreFields.industry] as String? ?? '',
      founderId: data[FirestoreFields.founderId] as String? ?? '',
      logoUrl: data[FirestoreFields.logoUrl] as String?,
      website: data[FirestoreFields.website] as String?,
      teamSize: data[FirestoreFields.teamSize] as int?,
      createdAt: (data[FirestoreFields.createdAt] as Timestamp?)?.toDate(),
      updatedAt: (data[FirestoreFields.updatedAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore({bool isCreate = false}) {
    return {
      FirestoreFields.name: name,
      FirestoreFields.description: description,
      FirestoreFields.industry: industry,
      FirestoreFields.founderId: founderId,
      FirestoreFields.logoUrl: logoUrl,
      FirestoreFields.website: website,
      FirestoreFields.teamSize: teamSize,
      if (isCreate) FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  StartupProfile toEntity() {
    return StartupProfile(
      id: id,
      name: name,
      description: description,
      industry: industry,
      founderId: founderId,
      logoUrl: logoUrl,
      website: website,
      teamSize: teamSize,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
