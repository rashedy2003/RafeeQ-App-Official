class LoginResponse {
  final String? token;

  LoginResponse({this.token});

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    token: json['accessToken'], // بنقرأ الـ token بس زي الأول
  );
}