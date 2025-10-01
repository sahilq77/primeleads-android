// To parse this JSON data, do
//
//     final getTestimonialResponse = getTestimonialResponseFromJson(jsonString);

import 'dart:convert';

List<GetTestimonialResponse> getTestimonialResponseFromJson(String str) =>
    List<GetTestimonialResponse>.from(
      json.decode(str).map((x) => GetTestimonialResponse.fromJson(x)),
    );

String getTestimonialResponseToJson(List<GetTestimonialResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetTestimonialResponse {
  String status;
  String message;
  List<Testmonial> data;

  GetTestimonialResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetTestimonialResponse.fromJson(Map<String, dynamic> json) =>
      GetTestimonialResponse(
        status: json["status"],
        message: json["message"],
        data: List<Testmonial>.from(
          json["data"].map((x) => Testmonial.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Testmonial {
  String id;
  String sectorId;
  String thumbnail;
  String testimonialVideo;

  String sectorName;

  Testmonial({
    required this.id,
    required this.sectorId,
    required this.thumbnail,
    required this.testimonialVideo,

    required this.sectorName,
  });

  factory Testmonial.fromJson(Map<String, dynamic> json) => Testmonial(
    id: json["id"] ?? "",
    sectorId: json["sector_id"] ?? "",
    testimonialVideo: json["testimonial_video"] ?? "",
    thumbnail: json["thumbnail"] ?? "",
    sectorName: json["sector_name"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sector_id": sectorId,
    "testimonial_video": testimonialVideo,
    "thumbnail": thumbnail,
    "sector_name": sectorName,
  };
}
