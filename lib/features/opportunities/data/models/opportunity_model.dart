import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/database/firestore_field_names.dart';
import '../../domain/entities/opportunity.dart';
import '../../domain/enums/opportunity_type.dart';
import '../../domain/enums/work_location.dart';

class OpportunityModel {
  const OpportunityModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startupId,
    required this.startupName,
    required this.location,
    required this.type,
    required this.requiredSkills,
    required this.duration,
    required this.isActive,
    this.applicationCount = 0,
    this.createdAt,
    this.updatedAt,
    this.expiresAt,
  });

  final String id;
  final String title;
  final String description;
  final String startupId;
  final String startupName;
  final WorkLocation location;
  final OpportunityType type;
  final List<String> requiredSkills;
  final String duration;
  final bool isActive;
  final int applicationCount;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final DateTime? expiresAt;

  factory OpportunityModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return OpportunityModel(
      id: doc.id,
      title: data[FirestoreFields.title] as String? ?? '',
      description: data[FirestoreFields.description] as String? ?? '',
      startupId: data[FirestoreFields.startupId] as String? ?? '',
      startupName: data[FirestoreFields.startupName] as String? ?? '',
      location: WorkLocation.fromString(data[FirestoreFields.location] as String? ?? 'hybrid'),
      type: OpportunityType.fromString(data[FirestoreFields.type] as String? ?? 'internship'),
      requiredSkills: List<String>.from(data[FirestoreFields.requiredSkills] as List? ?? []),
      duration: data[FirestoreFields.duration] as String? ?? '',
      isActive: data[FirestoreFields.isActive] as bool? ?? true,
      applicationCount: data[FirestoreFields.applicationCount] as int? ?? 0,
      createdAt: (data[FirestoreFields.createdAt] as Timestamp?)?.toDate(),
      updatedAt: (data[FirestoreFields.updatedAt] as Timestamp?)?.toDate(),
      expiresAt: (data[FirestoreFields.expiresAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore({bool isCreate = false}) {
    return {
      FirestoreFields.title: title,
      FirestoreFields.description: description,
      FirestoreFields.startupId: startupId,
      FirestoreFields.startupName: startupName,
      FirestoreFields.location: location.value,
      FirestoreFields.type: type.value,
      FirestoreFields.requiredSkills: requiredSkills,
      FirestoreFields.duration: duration,
      FirestoreFields.isActive: isActive,
      FirestoreFields.applicationCount: applicationCount,
      if (expiresAt != null) FirestoreFields.expiresAt: Timestamp.fromDate(expiresAt!),
      if (isCreate) FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  Opportunity toEntity() {
    return Opportunity(
      id: id,
      title: title,
      description: description,
      startupId: startupId,
      startupName: startupName,
      location: location,
      type: type,
      requiredSkills: requiredSkills,
      duration: duration,
      isActive: isActive,
      applicationCount: applicationCount,
      createdAt: createdAt,
      updatedAt: updatedAt,
      expiresAt: expiresAt,
    );
  }
}
