// To parse this JSON data, do
//
//     final getSubscriptionResponse = getSubscriptionResponseFromJson(jsonString);

import 'dart:convert';

List<GetSubscriptionResponse> getSubscriptionResponseFromJson(String str) =>
    List<GetSubscriptionResponse>.from(
      json.decode(str).map((x) => GetSubscriptionResponse.fromJson(x)),
    );

String getSubscriptionResponseToJson(List<GetSubscriptionResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSubscriptionResponse {
  String status;
  String message;
  List<Subscription> data;

  GetSubscriptionResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      GetSubscriptionResponse(
        status: json["status"],
        message: json["message"],
        data: List<Subscription>.from(
          json["data"].map((x) => Subscription.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class Subscription {
  String id;
  String sectorId;
  String packageName;
  String noOfLeads;
  String amount;
  String discountAmount;
  String image;
  String validityDays;
  String tags;
  List<String> bulletPoints;
  String sectorName;

  Subscription({
    required this.id,
    required this.sectorId,
    required this.packageName,
    required this.noOfLeads,
    required this.amount,
    required this.discountAmount,
    required this.image,
    required this.validityDays,
    required this.tags,
    required this.bulletPoints,
    required this.sectorName,
  });

  factory Subscription.fromJson(Map<String, dynamic> json) => Subscription(
    id: json["id"] ?? "",
    sectorId: json["sector_id"] ?? "",
    packageName: json["package_name"] ?? "",
    noOfLeads: json["no_of_leads"] ?? "",
    amount: json["amount"] ?? "",
    discountAmount: json["discount_amount"] ?? "",
    image: json["image"] ?? "",
    validityDays: json["validity_days"] ?? "",
    tags: json["tags"] ?? "",

    sectorName: json["sector_name"],
    bulletPoints: List<String>.from(json["bullet_points"].map((x) => x)),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sector_id": sectorId,
    "package_name": packageName,
    "no_of_leads": noOfLeads,
    "amount": amount,
    "discount_amount": discountAmount,
    "image": image,
    "validity_days": validityDays,
    "tags": tags,

    "sector_name": sectorName,
    "bullet_points": List<dynamic>.from(bulletPoints.map((x) => x)),
  };
}
