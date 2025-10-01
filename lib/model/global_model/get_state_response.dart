// To parse this JSON data, do
//
//     final getStateResponse = getStateResponseFromJson(jsonString);

import 'dart:convert';

List<GetStateResponse> getStateResponseFromJson(String str) =>
    List<GetStateResponse>.from(
        json.decode(str).map((x) => GetStateResponse.fromJson(x)));

String getStateResponseToJson(List<GetStateResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetStateResponse {
  String status;
  String message;
  List<StateData> data;

  GetStateResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetStateResponse.fromJson(Map<String, dynamic> json) =>
      GetStateResponse(
        status: json["status"],
        message: json["message"],
        data: List<StateData>.from(
            json["data"].map((x) => StateData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class StateData {
  String id;
  String name;
  String countryId;
  String countryCode;
  String fipsCode;
 

  StateData({
    required this.id,
    required this.name,
    required this.countryId,
    required this.countryCode,
    required this.fipsCode,
 
  });

  factory StateData.fromJson(Map<String, dynamic> json) => StateData(
        id: json["id"] ?? "",
        name: json["name"] ?? "",
        countryId: json["country_id"] ?? "",
        countryCode: json["country_code"] ?? "",
        fipsCode: json["fips_code"] ?? "",
    
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "country_id": countryId,
        "country_code": countryCode,
        "fips_code": fipsCode,
       
      };
}

