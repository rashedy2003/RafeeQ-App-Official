class TripRequestModel {
  final String title;
  final String description;
  final double latitude;
  final double longitude;
  final List<String> preferredSiteTypes;
  final String startDate;
  final String endDate;
  final String dailyStartTime;
  final String dailyEndTime;
  final double estimatedBudget;
  final String currency;
  final String tolerance;

  TripRequestModel({
    required this.title,
    required this.description,
    required this.latitude,
    required this.longitude,
    required this.preferredSiteTypes,
    required this.startDate,
    required this.endDate,
    required this.dailyStartTime,
    required this.dailyEndTime,
    required this.estimatedBudget,
    required this.currency,
    required this.tolerance,
  });

  Map<String, dynamic> toJson() {
    return {
      "title": title,
      "description": description,
      "latitude": latitude,
      "longitude": longitude,
      "preferredSiteTypes": preferredSiteTypes,
      "startDate": startDate,
      "endDate": endDate,
      "dailyStartTime": dailyStartTime,
      "dailyEndTime": dailyEndTime,
      "estimatedBudget": estimatedBudget,
      "currency": currency,
      "tolerance": tolerance,
    };
  }
}