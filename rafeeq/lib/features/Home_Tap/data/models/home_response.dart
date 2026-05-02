class HomeResponse {
  final List<dynamic> mustVisit;
  final List<dynamic> hiddenGems;
  final List<dynamic> nearYou;
  final List<dynamic> featuredDeals;

  HomeResponse({
    required this.mustVisit,
    required this.hiddenGems,
    required this.nearYou,
    required this.featuredDeals,
  });

  factory HomeResponse.fromJson(Map<String, dynamic> json) {
    return HomeResponse(
      mustVisit: json['mustVisit'] ?? [],
      hiddenGems: json['hiddenGems'] ?? [],
      nearYou: json['nearYou'] ?? [],
      featuredDeals: json['featuredDeals'] ?? [],
    );
  }
}