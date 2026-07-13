import 'package:equatable/equatable.dart';

import '../enums/application_status.dart';

/// A student's application to an opportunity.
/// Document ID: `{opportunityId}_{applicantId}` (see [FirestoreSchema.applicationDocId]).
class Application extends Equatable {
  const Application({
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

  @override
  List<Object?> get props => [
        id,
        opportunityId,
        opportunityTitle,
        startupId,
        startupName,
        applicantId,
        applicantName,
        applicantEmail,
        status,
        coverLetter,
        createdAt,
        updatedAt,
      ];
}
