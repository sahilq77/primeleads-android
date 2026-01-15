// To parse this JSON data, do
//
//     final setDeviceDetailResponse = setDeviceDetailResponseFromJson(jsonString);

import 'dart:convert';

List<SetDeviceDetailResponse> setDeviceDetailResponseFromJson(String str) =>
    List<SetDeviceDetailResponse>.from(
      json.decode(str).map((x) => SetDeviceDetailResponse.fromJson(x)),
    );

String setDeviceDetailResponseToJson(List<SetDeviceDetailResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SetDeviceDetailResponse {
  String status;
  String message;

  SetDeviceDetailResponse({required this.status, required this.message});

  factory SetDeviceDetailResponse.fromJson(Map<String, dynamic> json) =>
      SetDeviceDetailResponse(
        status: json["status"],
        message: json["message"] ?? "",
      );

  Map<String, dynamic> toJson() => {"status": status, "message": message};
}
