enum ApplicationStatus {
  pending('pending'),
  reviewed('reviewed'),
  accepted('accepted'),
  rejected('rejected'),
  withdrawn('withdrawn');

  const ApplicationStatus(this.value);

  final String value;

  static ApplicationStatus fromString(String value) {
    return ApplicationStatus.values.firstWhere(
      (s) => s.value == value,
      orElse: () => ApplicationStatus.pending,
    );
  }

  String get label => switch (this) {
        ApplicationStatus.pending => 'Pending',
        ApplicationStatus.reviewed => 'Reviewed',
        ApplicationStatus.accepted => 'Accepted',
        ApplicationStatus.rejected => 'Rejected',
        ApplicationStatus.withdrawn => 'Withdrawn',
      };

  bool get isTerminal =>
      this == ApplicationStatus.accepted ||
      this == ApplicationStatus.rejected ||
      this == ApplicationStatus.withdrawn;
}
