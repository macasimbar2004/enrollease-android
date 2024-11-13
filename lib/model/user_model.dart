class UserModel {
  final String name;
  final String email;
  final String contactNumber;

  UserModel({
    required this.name,
    required this.email,
    required this.contactNumber,
  });

  // A method to convert data from a map (useful for Firestore)
  factory UserModel.fromMap(Map<String, dynamic> data) {
    return UserModel(
      name: data['name'] ?? '',
      email: data['email'] ?? '',
      contactNumber: data['contactNumber'] ?? '',
    );
  }

  // A method to convert the user object back to a map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'contactNumber': contactNumber,
    };
  }
}
