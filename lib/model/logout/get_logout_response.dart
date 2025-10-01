// To parse this JSON data, do
//
//     final getLogoutResponse = getLogoutResponseFromJson(jsonString);

import 'dart:convert';

List<GetLogoutResponse> getLogoutResponseFromJson(String str) =>
    List<GetLogoutResponse>.from(
      json.decode(str).map((x) => GetLogoutResponse.fromJson(x)),
    );

String getLogoutResponseToJson(List<GetLogoutResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLogoutResponse {
  String status;
  String message;
  Data data;

  GetLogoutResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetLogoutResponse.fromJson(Map<String, dynamic> json) =>
      GetLogoutResponse(
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
  String id;
  String mobileNumber;
  String userName;
  String stateId;
  String cityId;
  String otp;
  String sectorId;
  String userImage;
  String isLogin;
  String status;
  String isDeleted;
  DateTime createdOn;
  DateTime updatedOn;
  String topicName;

  Data({
    required this.id,
    required this.mobileNumber,
    required this.userName,
    required this.stateId,
    required this.cityId,
    required this.otp,
    required this.sectorId,
    required this.userImage,
    required this.isLogin,
    required this.status,
    required this.isDeleted,
    required this.createdOn,
    required this.updatedOn,
    required this.topicName,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] ?? "",
    mobileNumber: json["mobile_number"] ?? "",
    userName: json["user_name"] ?? "",
    stateId: json["state_id"] ?? "",
    cityId: json["city_id"] ?? "",
    otp: json["otp"] ?? "",
    sectorId: json["sector_id"] ?? "",
    userImage: json["user_image"] ?? "",
    isLogin: json["is_login"] ?? "",
    status: json["status"] ?? "",
    isDeleted: json["is_deleted"] ?? "",
    createdOn: DateTime.parse(json["created_on"]),
    updatedOn: DateTime.parse(json["updated_on"]),
    topicName: json["topic"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "mobile_number": mobileNumber,
    "user_name": userName,
    "state_id": stateId,
    "city_id": cityId,
    "otp": otp,
    "sector_id": sectorId,
    "user_image": userImage,
    "is_login": isLogin,
    "status": status,
    "is_deleted": isDeleted,
    "created_on": createdOn.toIso8601String(),
    "updated_on": updatedOn.toIso8601String(),
    "topic": topicName,
  };
}
