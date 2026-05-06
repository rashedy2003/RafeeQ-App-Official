class ScanModel {
  final String? id;
  final String? siteId;
  final String? name;
  final String? description;
  final String? siteName;
  final String? mainImageUrl;
  final String? type;
  final List<SiteImage>? images;
  final String? typeDisplay;

  ScanModel({
    this.id,
    this.siteId,
    this.name,
    this.description,
    this.siteName,
    this.mainImageUrl,
    this.type,
    this.images,
    this.typeDisplay,
  });

  factory ScanModel.fromJson(Map<String, dynamic> json) {
    return ScanModel(
      id: json['id'],
      siteId: json['siteId'],
      name: json['name'],
      description: json['description'],
      siteName: json['siteName'],
      mainImageUrl: json['mainImageUrl'],
      type: json['type'],
      typeDisplay: json['typeDisplay'],
      images: json['images'] != null
          ? (json['images'] as List).map((i) => SiteImage.fromJson(i)).toList()
          : [],
    );
  }
}

class SiteImage {
  final String? id;
  final String? storageKey;
  final String? url;
  final String? caption;
  final bool? isMain;
  final int? displayOrder;

  SiteImage({
    this.id,
    this.storageKey,
    this.url,
    this.caption,
    this.isMain,
    this.displayOrder,
  });

  factory SiteImage.fromJson(Map<String, dynamic> json) {
    return SiteImage(
      id: json['id'],
      storageKey: json['storageKey'],
      url: json['url'],
      caption: json['caption'],
      isMain: json['isMain'],
      displayOrder: json['displayOrder'],
    );
  }
}