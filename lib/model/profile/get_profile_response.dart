// To parse this JSON data, do
//
//     final getProfileResponse = getProfileResponseFromJson(jsonString);

import 'dart:convert';

List<GetProfileResponse> getProfileResponseFromJson(String str) =>
    List<GetProfileResponse>.from(
      json.decode(str)?.map((x) => GetProfileResponse.fromJson(x)) ?? [],
    );

String getProfileResponseToJson(List<GetProfileResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetProfileResponse {
  String? status;
  String? message;
  ProfileData? data;

  GetProfileResponse({this.status, this.message, this.data});

  factory GetProfileResponse.fromJson(Map<String, dynamic> json) =>
      GetProfileResponse(
        status: json["status"] as String? ?? "",
        message: json["message"] as String? ?? "",
        data:
            json["data"] != null
                ? ProfileData.fromJson(json["data"] as Map<String, dynamic>)
                : null,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class ProfileData {
  String? id;
  String? fullName;
  String? profileImage; // Changed from dynamic to String?
  String? mobileNumber;
  String? state;
  String? city;
  String? sectorId;
  String? sectorName;
  String? subscriptionId;
  SubscriptionDetail? subscriptionDetail;
  String? transactioId;
  String? isSelectedCities;
  String? hasReceivedLeads;
  String? subscribedUserId;
  String? refNo;

  ProfileData({
    this.id,
    this.fullName,
    this.profileImage,
    this.mobileNumber,
    this.state,
    this.city,
    this.sectorId,
    this.sectorName,
    this.subscriptionId,
    this.subscriptionDetail,
    this.transactioId,
    this.isSelectedCities,
    this.hasReceivedLeads,
    this.subscribedUserId,
    this.refNo,
  });

  factory ProfileData.fromJson(Map<String, dynamic> json) => ProfileData(
    id: json["id"] as String? ?? "",
    fullName: json["full_name"] as String? ?? "",
    profileImage: json["profile_image"] as String? ?? "",
    mobileNumber: json["mobile_number"] as String? ?? "",
    state: json["state"] as String? ?? "",
    city: json["city"] as String? ?? "",
    sectorId: json["sector_id"] as String? ?? "",
    sectorName: json["sector_name"] as String? ?? "",
    subscriptionId: json["subscription_id"] as String? ?? "",
    subscriptionDetail:
        json["subscription_detail"] != null
            ? SubscriptionDetail.fromJson(
              json["subscription_detail"] as Map<String, dynamic>,
            )
            : SubscriptionDetail(
              packageName: "",
              noOfLeads: "",
              validityDays: "",
              tags: "",
              bulletPoints: [],
            ),
    transactioId: json["transaction_no"] as String? ?? "",
    isSelectedCities: json["is_selected_cities"] as String? ?? "",
    hasReceivedLeads: json["has_received_leads"] as String? ?? "",
    subscribedUserId: json["subscribed_user_id"] as String? ?? "",
    refNo: json["ref_no"] as String? ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "full_name": fullName,
    "profile_image": profileImage,
    "mobile_number": mobileNumber,
    "state": state,
    "city": city,
    "sector_id": sectorId,
    "sector_name": sectorName,
    "subscription_id": subscriptionId,
    "subscription_detail": subscriptionDetail?.toJson(),
  };
}

class SubscriptionDetail {
  String? packageName;
  String? noOfLeads;
  String? validityDays;
  String? tags;
  List<String> bulletPoints;

  SubscriptionDetail({
    this.packageName,
    this.noOfLeads,
    this.validityDays,
    this.tags,
    required this.bulletPoints,
  });

  factory SubscriptionDetail.fromJson(Map<String, dynamic> json) =>
      SubscriptionDetail(
        packageName: json["package_name"] as String? ?? "",
        noOfLeads: json["no_of_leads"] as String? ?? "",
        validityDays: json["validity_days"] as String? ?? "",
        tags: json["tags"] as String? ?? "",
        bulletPoints:
            json["bullet_points"] != null
                ? List<String>.from(
                  (json["bullet_points"] as List<dynamic>).map(
                    (x) => x.toString(),
                  ),
                )
                : [],
      );

  Map<String, dynamic> toJson() => {
    "package_name": packageName,
    "no_of_leads": noOfLeads,
    "validity_days": validityDays,
    "tags": tags,
    "bullet_points": List<dynamic>.from(bulletPoints.map((x) => x)),
  };
}
