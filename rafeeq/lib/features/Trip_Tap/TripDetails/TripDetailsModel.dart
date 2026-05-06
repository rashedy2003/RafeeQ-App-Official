class TripDetailsModel {
  final String id;
  final String title;
  final String description;
  final String startDate;
  final String endDate;
  final String status;
  final String statusDisplay;
  final String toleranceDisplay; // أضفتها عشان الـ Screen بتستخدمها
  final int totalDays;
  final int totalSites;
  final int estimatedTotalDurationMinutes;
  final PriceModel estimatedBudget; // غيرت الاسم ليطابق الـ Screen
  final PriceModel? actualCost;
  final List<TripDay> days; // القائمة الأساسية للأيام

  TripDetailsModel({
    required this.id,
    required this.title,
    required this.description,
    required this.startDate,
    required this.endDate,
    required this.status,
    required this.statusDisplay,
    required this.toleranceDisplay,
    required this.totalDays,
    required this.totalSites,
    required this.estimatedTotalDurationMinutes,
    required this.estimatedBudget,
    this.actualCost,
    required this.days,
  });

  factory TripDetailsModel.fromJson(Map<String, dynamic> json) {
    return TripDetailsModel(
      id: json['id'] ?? '',
      title: json['title'] ?? '',
      description: json['description'] ?? '',
      startDate: json['startDate'] ?? '',
      endDate: json['endDate'] ?? '',
      status: json['status'] ?? '',
      statusDisplay: json['statusDisplay'] ?? '',
      toleranceDisplay: json['toleranceDisplay'] ?? 'Medium',
      totalDays: json['totalDays'] ?? 0,
      totalSites: json['totalSites'] ?? 0,
      estimatedTotalDurationMinutes: json['estimatedTotalDurationMinutes'] ?? 0,
      estimatedBudget: PriceModel.fromJson(json['estimatedTotalBudget'] ?? {}),
      actualCost: json['actualCost'] != null ? PriceModel.fromJson(json['actualCost']) : null,
      days: (json['days'] as List? ?? [])
          .map((day) => TripDay.fromJson(day))
          .toList(),
    );
  }
}

class TripDay {
  final int dayNumber;
  final String date;
  final PriceModel estimatedDayCost;
  final List<TripSite> sites;

  TripDay({
    required this.dayNumber,
    required this.date,
    required this.estimatedDayCost,
    required this.sites,
  });

  factory TripDay.fromJson(Map<String, dynamic> json) {
    return TripDay(
      dayNumber: json['dayNumber'] ?? 0,
      date: json['date'] ?? '',
      estimatedDayCost: PriceModel.fromJson(json['estimatedDayCost'] ?? {}),
      sites: (json['sites'] as List? ?? [])
          .map((site) => TripSite.fromJson(site))
          .toList(),
    );
  }
}

class TripSite {
  final String siteName;
  final String siteImageUrl;
  final String cityName;
  final String siteTypeDisplay;
  final String plannedArrivalTime;
  final PriceModel estimatedCost;

  TripSite({
    required this.siteName,
    required this.siteImageUrl,
    required this.cityName,
    required this.siteTypeDisplay,
    required this.plannedArrivalTime,
    required this.estimatedCost,
  });

  factory TripSite.fromJson(Map<String, dynamic> json) {
    return TripSite(
      siteName: json['siteName'] ?? '',
      siteImageUrl: json['siteImageUrl'] ?? '',
      cityName: json['cityName'] ?? '',
      siteTypeDisplay: json['siteTypeDisplay'] ?? '',
      plannedArrivalTime: json['plannedArrivalTime'] ?? '',
      estimatedCost: PriceModel.fromJson(json['estimatedCost'] ?? {}),
    );
  }
}

class PriceModel {
  final double amount;
  final String currency;
  final String formattedAmount;

  PriceModel({
    required this.amount,
    required this.currency,
    required this.formattedAmount,
  });

  factory PriceModel.fromJson(Map<String, dynamic> json) {
    return PriceModel(
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      currency: json['currency'] ?? '',
      formattedAmount: json['formattedAmount'] ?? '0 EGP',
    );
  }
}


// class TripDetailsModel {
//   final String id, title, description, startDate, endDate;
//   final String statusDisplay, toleranceDisplay;
//   final CostModel estimatedBudget;
//   final List<TripDay> days;
//
//   TripDetailsModel({
//     required this.id, required this.title, required this.description,
//     required this.startDate, required this.endDate,
//     required this.statusDisplay, required this.toleranceDisplay,
//     required this.estimatedBudget, required this.days,
//   });
//
//   factory TripDetailsModel.fromJson(Map<String, dynamic> json) {
//     return TripDetailsModel(
//       id: json['id'],
//       title: json['title'],
//       description: json['description'] ?? "",
//       startDate: json['startDate'],
//       endDate: json['endDate'],
//       statusDisplay: json['statusDisplay'],
//       toleranceDisplay: json['toleranceDisplay'],
//       estimatedBudget: CostModel.fromJson(json['estimatedBudget']),
//       days: (json['days'] as List).map((i) => TripDay.fromJson(i)).toList(),
//     );
//   }
// }
//
// class TripDay {
//   final int dayNumber;
//   final String date;
//   final List<TripSite> sites;
//
//   TripDay({required this.dayNumber, required this.date, required this.sites});
//
//   factory TripDay.fromJson(Map<String, dynamic> json) {
//     return TripDay(
//       dayNumber: json['dayNumber'],
//       date: json['date'],
//       sites: (json['sites'] as List).map((i) => TripSite.fromJson(i)).toList(),
//     );
//   }
// }
//
// class TripSite {
//   final String siteName, siteImageUrl, plannedArrivalTime, siteTypeDisplay;
//   final int visitOrder;
//
//   TripSite({
//     required this.siteName, required this.siteImageUrl,
//     required this.plannedArrivalTime, required this.siteTypeDisplay,
//     required this.visitOrder,
//   });
//
//   factory TripSite.fromJson(Map<String, dynamic> json) {
//     return TripSite(
//       siteName: json['siteName'],
//       siteImageUrl: json['siteImageUrl'] ?? "",
//       plannedArrivalTime: json['plannedArrivalTime'],
//       siteTypeDisplay: json['siteTypeDisplay'],
//       visitOrder: json['visitOrder'],
//     );
//   }
// }
//
// class CostModel {
//   final String formattedAmount;
//   CostModel({required this.formattedAmount});
//   factory CostModel.fromJson(Map<String, dynamic> json) => CostModel(formattedAmount: json['formattedAmount']);
// }