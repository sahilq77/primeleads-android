import 'dart:convert';

List<GetSubscriptionStatusResponse> getSubscriptionStatusResponseFromJson(
  String str,
) => List<GetSubscriptionStatusResponse>.from(
  json.decode(str).map((x) => GetSubscriptionStatusResponse.fromJson(x)),
);

String getSubscriptionStatusResponseToJson(
  List<GetSubscriptionStatusResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSubscriptionStatusResponse {
  String status;
  String message;
  Data? data; // Make data nullable to handle empty array case

  GetSubscriptionStatusResponse({
    required this.status,
    required this.message,
    this.data, // Allow null data
  });

  factory GetSubscriptionStatusResponse.fromJson(Map<String, dynamic> json) =>
      GetSubscriptionStatusResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data:
            json["data"] is List
                ? null // Handle empty array case
                : json["data"] != null
                ? Data.fromJson(json["data"])
                : null,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class Data {
  String subscribedUserId;
  String hasExpired;

  Data({required this.subscribedUserId, required this.hasExpired});

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    subscribedUserId: json["subscribed_user_id"] ?? "",
    hasExpired: json["has_expired"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "subscribed_user_id": subscribedUserId,
    "has_expired": hasExpired,
  };
}
