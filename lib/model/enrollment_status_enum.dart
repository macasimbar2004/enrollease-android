enum EnrollmentStatus {
  approved,
  disapproved,
  pending,
}

extension StringName on EnrollmentStatus {
  String formalName() => '${name[0].toUpperCase()}${name.substring(1)}';
}
