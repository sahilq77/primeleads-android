// To parse this JSON data, do
//
//     final getBannerVideoResponse = getBannerVideoResponseFromJson(jsonString);

import 'dart:convert';

List<GetBannerVideoResponse> getBannerVideoResponseFromJson(String str) =>
    List<GetBannerVideoResponse>.from(
      json.decode(str).map((x) => GetBannerVideoResponse.fromJson(x)),
    );

String getBannerVideoResponseToJson(List<GetBannerVideoResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetBannerVideoResponse {
  String status;
  String message;
  List<BannerVideo> data;

  GetBannerVideoResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetBannerVideoResponse.fromJson(Map<String, dynamic> json) =>
      GetBannerVideoResponse(
        status: json["status"],
        message: json["message"],
        data: List<BannerVideo>.from(json["data"].map((x) => BannerVideo.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class BannerVideo {
  String id;
  String sectorId;
  String thumbnail;
  String bannerVideo;

  BannerVideo({
    required this.id,
    required this.sectorId,
    required this.thumbnail,
    required this.bannerVideo,
  });

  factory BannerVideo.fromJson(Map<String, dynamic> json) => BannerVideo(
    id: json["id"] ?? 0,
    sectorId: json["sector_id"] ?? "",
    thumbnail: json["thumbnail"] ?? "",
    bannerVideo: json["banner_video"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sector_id": sectorId,
    "thumbnail": thumbnail,
    "banner_video": bannerVideo,
  };
}
