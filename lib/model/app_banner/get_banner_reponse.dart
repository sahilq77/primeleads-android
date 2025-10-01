// To parse this JSON data, do
//
//     final getBannerImagesResponse = getBannerImagesResponseFromJson(jsonString);

import 'dart:convert';

List<GetBannerImagesResponse> getBannerImagesResponseFromJson(String str) =>
    List<GetBannerImagesResponse>.from(
      json.decode(str).map((x) => GetBannerImagesResponse.fromJson(x)),
    );

String getBannerImagesResponseToJson(List<GetBannerImagesResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetBannerImagesResponse {
  String status;
  String message;
  List<BannerImages> data;

  GetBannerImagesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetBannerImagesResponse.fromJson(Map<String, dynamic> json) =>
      GetBannerImagesResponse(
        status: json["status"],
        message: json["message"],
        data: List<BannerImages>.from(
          json["data"].map((x) => BannerImages.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class BannerImages {
  String id;
  String sectorId;
  String bannerImage;

  String sectorName;

  BannerImages({
    required this.id,
    required this.sectorId,
    required this.bannerImage,

    required this.sectorName,
  });

  factory BannerImages.fromJson(Map<String, dynamic> json) => BannerImages(
    id: json["id"],
    sectorId: json["sector_id"],
    bannerImage: json["banner_image"],

    sectorName: json["sector_name"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sector_id": sectorId,
    "banner_image": bannerImage,

    "sector_name": sectorName,
  };
}
