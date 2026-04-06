class RegisterRequestBody {
  final String userName;
  final String firstName;
  final String lastName;
  final String email;
  final String password;
  final String nationality;
  final String preferredLanguage;

  RegisterRequestBody({
    required this.userName,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.password,
    required this.nationality,
    required this.preferredLanguage,
  });

  Map<String, dynamic> toJson() {
    return {
      'userName': userName,
      'firstName': firstName,
      'lastName': lastName,
      'email': email,
      'password': password,
      'nationality': nationality,
      'preferredLanguage': preferredLanguage.toLowerCase(),
    };
  }
}