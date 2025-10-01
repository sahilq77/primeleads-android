// To parse this JSON data, do
//
//     final getMinMaxCityResposne = getMinMaxCityResposneFromJson(jsonString);

import 'dart:convert';

List<GetMinMaxCityResposne> getMinMaxCityResposneFromJson(String str) => List<GetMinMaxCityResposne>.from(json.decode(str).map((x) => GetMinMaxCityResposne.fromJson(x)));

String getMinMaxCityResposneToJson(List<GetMinMaxCityResposne> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetMinMaxCityResposne {
    String status;
    String message;
    List<MinMaxCity> data;

    GetMinMaxCityResposne({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetMinMaxCityResposne.fromJson(Map<String, dynamic> json) => GetMinMaxCityResposne(
        status: json["status"],
        message: json["message"],
        data: List<MinMaxCity>.from(json["data"].map((x) => MinMaxCity.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class MinMaxCity {
    String id;
    String sectorId;
    String minCities;
    String maxCities;
  
    String sectorName;

    MinMaxCity({
        required this.id,
        required this.sectorId,
        required this.minCities,
        required this.maxCities,
      
        required this.sectorName,
    });

    factory MinMaxCity.fromJson(Map<String, dynamic> json) => MinMaxCity(
        id: json["id"],
        sectorId: json["sector_id"],
        minCities: json["min_cities"],
        maxCities: json["max_cities"],
       
        sectorName: json["sector_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sector_id": sectorId,
        "min_cities": minCities,
        "max_cities": maxCities,
     
        "sector_name": sectorName,
    };
}
