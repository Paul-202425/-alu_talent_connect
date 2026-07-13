enum OpportunityType {
  internship('internship'),
  partTime('part_time'),
  project('project');

  const OpportunityType(this.value);

  final String value;

  static OpportunityType fromString(String value) {
    return OpportunityType.values.firstWhere(
      (t) => t.value == value,
      orElse: () => OpportunityType.internship,
    );
  }

  String get label => switch (this) {
        OpportunityType.internship => 'Internship',
        OpportunityType.partTime => 'Part-time',
        OpportunityType.project => 'Project',
      };
}
