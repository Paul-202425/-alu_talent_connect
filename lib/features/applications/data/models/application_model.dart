import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../../core/database/firestore_field_names.dart';
import '../../domain/entities/application.dart';
import '../../domain/enums/application_status.dart';

class ApplicationModel {
  const ApplicationModel({
    required this.id,
    required this.opportunityId,
    required this.opportunityTitle,
    required this.startupId,
    required this.startupName,
    required this.applicantId,
    required this.applicantName,
    required this.applicantEmail,
    required this.status,
    this.coverLetter,
    this.createdAt,
    this.updatedAt,
  });

  final String id;
  final String opportunityId;
  final String opportunityTitle;
  final String startupId;
  final String startupName;
  final String applicantId;
  final String applicantName;
  final String applicantEmail;
  final ApplicationStatus status;
  final String? coverLetter;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  factory ApplicationModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;

    return ApplicationModel(
      id: doc.id,
      opportunityId: data[FirestoreFields.opportunityId] as String? ?? '',
      opportunityTitle: data[FirestoreFields.opportunityTitle] as String? ?? '',
      startupId: data[FirestoreFields.startupId] as String? ?? '',
      startupName: data[FirestoreFields.startupName] as String? ?? '',
      applicantId: data[FirestoreFields.applicantId] as String? ?? '',
      applicantName: data[FirestoreFields.applicantName] as String? ?? '',
      applicantEmail: data[FirestoreFields.applicantEmail] as String? ?? '',
      status: ApplicationStatus.fromString(data[FirestoreFields.status] as String? ?? 'pending'),
      coverLetter: data[FirestoreFields.coverLetter] as String?,
      createdAt: (data[FirestoreFields.createdAt] as Timestamp?)?.toDate(),
      updatedAt: (data[FirestoreFields.updatedAt] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toFirestore({bool isCreate = false}) {
    return {
      FirestoreFields.opportunityId: opportunityId,
      FirestoreFields.opportunityTitle: opportunityTitle,
      FirestoreFields.startupId: startupId,
      FirestoreFields.startupName: startupName,
      FirestoreFields.applicantId: applicantId,
      FirestoreFields.applicantName: applicantName,
      FirestoreFields.applicantEmail: applicantEmail,
      FirestoreFields.status: status.value,
      FirestoreFields.coverLetter: coverLetter,
      if (isCreate) FirestoreFields.createdAt: FieldValue.serverTimestamp(),
      FirestoreFields.updatedAt: FieldValue.serverTimestamp(),
    };
  }

  Application toEntity() {
    return Application(
      id: id,
      opportunityId: opportunityId,
      opportunityTitle: opportunityTitle,
      startupId: startupId,
      startupName: startupName,
      applicantId: applicantId,
      applicantName: applicantName,
      applicantEmail: applicantEmail,
      status: status,
      coverLetter: coverLetter,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }
}
