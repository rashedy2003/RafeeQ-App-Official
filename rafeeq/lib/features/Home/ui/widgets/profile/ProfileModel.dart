class ProfileModel {
  final String? id;
  final String? userName;
  final String? firstName;
  final String? lastName;
  final String? fullName;
  final String? email;
  final String? nationality;
  final int? totalTrips;
  final int? totalReviews;
  final String? createdAt;

  ProfileModel({
    this.id,
    this.userName,
    this.firstName,
    this.lastName,
    this.fullName,
    this.email,
    this.nationality,
    this.totalTrips,
    this.totalReviews,
    this.createdAt,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      id: json['id'],
      userName: json['userName'],
      firstName: json['firstName'],
      lastName: json['lastName'],
      fullName: json['fullName'],
      email: json['email'],
      nationality: json['nationality'],
      totalTrips: json['totalTrips'] ?? 0,
      totalReviews: json['totalReviews'] ?? 0,
      createdAt: json['createdAt'],
    );
  }
}