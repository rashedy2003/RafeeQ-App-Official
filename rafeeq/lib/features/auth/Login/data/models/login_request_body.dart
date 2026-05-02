class LoginRequestBody {
  final String? email;
  final String? password;
  final String? idToken;

  LoginRequestBody({this.email, this.password, this.idToken});

  Map<String, dynamic> toJson() {
    if (idToken != null) {
      return {'idToken': idToken};
    }
    return {
      'email': email,
      'password': password,
    };
  }
}