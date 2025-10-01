// To parse this JSON data, do
//
//     final getSetCitiesResponse = getSetCitiesResponseFromJson(jsonString);

import 'dart:convert';

List<GetSetCitiesResponse> getSetCitiesResponseFromJson(String str) =>
    List<GetSetCitiesResponse>.from(
      json.decode(str).map((x) => GetSetCitiesResponse.fromJson(x)),
    );

String getSetCitiesResponseToJson(List<GetSetCitiesResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSetCitiesResponse {
  String status;
  String message;
  Data data;

  GetSetCitiesResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSetCitiesResponse.fromJson(Map<String, dynamic> json) =>
      GetSetCitiesResponse(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class Data {
  String subscribedUserId;

  Data({required this.subscribedUserId});

  factory Data.fromJson(Map<String, dynamic> json) =>
      Data(subscribedUserId: json["subscribed_user_id"] ?? "");

  Map<String, dynamic> toJson() => {"subscribed_user_id": subscribedUserId};
}
