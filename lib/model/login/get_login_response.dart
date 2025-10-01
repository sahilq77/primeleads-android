// To parse this JSON data, do
//
//     final getLoginResponse = getLoginResponseFromJson(jsonString);

import 'dart:convert';

List<GetLoginResponse> getLoginResponseFromJson(String str) =>
    List<GetLoginResponse>.from(
      json.decode(str).map((x) => GetLoginResponse.fromJson(x)),
    );

String getLoginResponseToJson(List<GetLoginResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLoginResponse {
  String status;
  String message;
  LoginResponse data;

  GetLoginResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetLoginResponse.fromJson(Map<String, dynamic> json) =>
      GetLoginResponse(
        status: json["status"],
        message: json["message"],
        data: LoginResponse.fromJson(json["data"]),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class LoginResponse {
  String id;
  String userName;
  String mobileNumber;
  String state;
  String city;
  String sectorName;
  String sectorID;
  String otp;
  String topicName;
  String subscriptionId;

  LoginResponse({
    required this.id,
    required this.userName,
    required this.mobileNumber,
    required this.state,
    required this.city,
    required this.sectorName,
    required this.sectorID,
    required this.otp,
    required this.topicName,
    required this.subscriptionId,
  });

  factory LoginResponse.fromJson(Map<String, dynamic> json) => LoginResponse(
    id: json["id"] ?? "",
    userName: json["user_name"] ?? "",
    mobileNumber: json["mobile_number"] ?? "",
    state: json["state"] ?? "",
    city: json["city"] ?? "",
    sectorName: json["sector_name"] ?? "",
    sectorID: json["sector_id"] ?? "",
    otp: json["otp"] ?? "",
    topicName: json["topic"] ?? "",
    subscriptionId: json["subscription_id"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_name": userName,
    "mobile_number": mobileNumber,
    "state": state,
    "city": city,
    "sector_name": sectorName,
    "sector_id": sectorID,
    "otp": otp,
    "topic": topicName,
    "subscription_id": subscriptionId,
  };
}
