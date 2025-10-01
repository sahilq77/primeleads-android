// To parse this JSON data, do
//
//     final getLocationResponse = getLocationResponseFromJson(jsonString);

import 'dart:convert';

List<GetLocationResponse> getLocationResponseFromJson(String str) => List<GetLocationResponse>.from(json.decode(str).map((x) => GetLocationResponse.fromJson(x)));

String getLocationResponseToJson(List<GetLocationResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLocationResponse {
    String status;
    String message;
    List<LocationData> data;

    GetLocationResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetLocationResponse.fromJson(Map<String, dynamic> json) => GetLocationResponse(
        status: json["status"],
        message: json["message"],
        data: List<LocationData>.from(json["data"].map((x) => LocationData.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class LocationData {
    String id;
    String sectorId;
    String stateId;
    String cityId;
    String isDeleted;
    String status;
    DateTime createdOn;
    DateTime updatedOn;
    String sectorName;
    String stateName;
    String cityName;

    LocationData({
        required this.id,
        required this.sectorId,
        required this.stateId,
        required this.cityId,
        required this.isDeleted,
        required this.status,
        required this.createdOn,
        required this.updatedOn,
        required this.sectorName,
        required this.stateName,
        required this.cityName,
    });

    factory LocationData.fromJson(Map<String, dynamic> json) => LocationData(
        id: json["id"],
        sectorId: json["sector_id"],
        stateId: json["state_id"],
        cityId: json["city_id"],
        isDeleted: json["is_deleted"],
        status: json["status"],
        createdOn: DateTime.parse(json["created_on"]),
        updatedOn: DateTime.parse(json["updated_on"]),
        sectorName: json["sector_name"],
        stateName: json["state_name"],
        cityName: json["city_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sector_id": sectorId,
        "state_id": stateId,
        "city_id": cityId,
        "is_deleted": isDeleted,
        "status": status,
        "created_on": createdOn.toIso8601String(),
        "updated_on": updatedOn.toIso8601String(),
        "sector_name": sectorName,
        "state_name": stateName,
        "city_name": cityName,
    };
}
