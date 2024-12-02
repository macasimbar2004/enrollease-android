// should be created every time enrollment is approved
class BalanceAccount {
  final String gradeLevel; // e.g. K1-01, K1-02, K1-03, auto-generated
  final String parentID; // UserModel
  /// from UserModel, we will get:
  /// user name
  final String pupilID; // EnrollmentFormModel
  /// from EnrollmentFormModel, we will get:
  /// first name
  /// middle name
  /// last name
  /// enrollingGrade
  /// gender
  /// age
  /// contact number
  /// address
  /// religion
  /// mother tongue
  /// civil status
  /// IP/ICC
  /// unpaidBill
  final double tuitionDiscount;
  final double bookDiscount;
  BalanceAccount({
    required this.gradeLevel,
    required this.parentID,
    required this.pupilID,
    required this.tuitionDiscount,
    required this.bookDiscount,
  });

  factory BalanceAccount.fromMap(Map<String, dynamic> data) {
    return BalanceAccount(
      gradeLevel: data['gradeLevel'],
      parentID: data['parentID'],
      pupilID: data['pupilID'],
      tuitionDiscount: data['tuitionDiscount'],
      bookDiscount: data['bookDiscount'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'gradeLevel': gradeLevel,
      'parentID': parentID,
      'pupilID': pupilID,
      'tuitionDiscount': tuitionDiscount,
      'bookDiscount': bookDiscount,
    };
  }
}
