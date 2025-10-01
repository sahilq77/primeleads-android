// To parse this JSON data, do
//
//     final getUpdateResponse = getUpdateResponseFromJson(jsonString);

import 'dart:convert';

List<GetUpdateResponse> getUpdateResponseFromJson(String str) =>
    List<GetUpdateResponse>.from(
      json.decode(str).map((x) => GetUpdateResponse.fromJson(x)),
    );

String getUpdateResponseToJson(List<GetUpdateResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetUpdateResponse {
  String status;
  String message;
  Data data;

  GetUpdateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetUpdateResponse.fromJson(Map<String, dynamic> json) =>
      GetUpdateResponse(
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
  String sectorId;
  String fullName;
  String profileImage;
  String mobileNumber;
  String state;
  String city;

  Data({
    required this.id,
    required this.sectorId,
    required this.fullName,
    required this.profileImage,
    required this.mobileNumber,
    required this.state,
    required this.city,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] ?? "",
    sectorId: json["sector_id"] ?? "",
    fullName: json["full_name"] ?? "",
    profileImage: json["profile_image"] ?? "",
    mobileNumber: json["mobile_number"] ?? "",
    state: json["state"] ?? "",
    city: json["city"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sector_id": sectorId,
    "full_name": fullName,
    "profile_image": profileImage,
    "mobile_number": mobileNumber,
    "state": state,
    "city": city,
  };
}
