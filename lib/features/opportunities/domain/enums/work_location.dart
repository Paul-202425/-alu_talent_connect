enum WorkLocation {
  remote('remote'),
  onCampus('on_campus'),
  hybrid('hybrid');

  const WorkLocation(this.value);

  final String value;

  static WorkLocation fromString(String value) {
    return WorkLocation.values.firstWhere(
      (l) => l.value == value,
      orElse: () => WorkLocation.hybrid,
    );
  }

  String get label => switch (this) {
        WorkLocation.remote => 'Remote',
        WorkLocation.onCampus => 'On Campus',
        WorkLocation.hybrid => 'Hybrid',
      };
}
