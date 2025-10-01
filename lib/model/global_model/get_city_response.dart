

// To parse this JSON data, do
//
//     final getCityResponse = getCityResponseFromJson(jsonString);

import 'dart:convert';

List<GetCityResponse> getCityResponseFromJson(String str) =>
    List<GetCityResponse>.from(
        json.decode(str).map((x) => GetCityResponse.fromJson(x)));

String getCityResponseToJson(List<GetCityResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetCityResponse {
  String status;
  String message;
  List<CityData> data;

  GetCityResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetCityResponse.fromJson(Map<String, dynamic> json) =>
      GetCityResponse(
        status: json["status"],
        message: json["message"],
        data:
            List<CityData>.from(json["data"].map((x) => CityData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class CityData {
  String id;
  String name;

  String stateId;
  String stateCode;
  String countryId;
  String countryCode;

  CityData({
    required this.id,
    required this.name,
    required this.stateId,
    required this.stateCode,
    required this.countryId,
    required this.countryCode,
  });

  factory CityData.fromJson(Map<String, dynamic> json) => CityData(
        id: json["id"].toString(),
        name: json["name"].toString(),
        stateId: json["state_id"].toString(),
        stateCode: json["state_code"].toString(),
        countryId: json["country_id"].toString(),
        countryCode: json["country_code"].toString(),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "state_id": stateId,
        "state_code": stateCode,
        "country_id": countryId,
        "country_code": countryCode,
      };
}