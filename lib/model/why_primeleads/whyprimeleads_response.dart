// To parse this JSON data, do
//
//     final getwhyprimeLeadsResponse = getwhyprimeLeadsResponseFromJson(jsonString);

import 'dart:convert';

List<GetwhyprimeLeadsResponse> getwhyprimeLeadsResponseFromJson(String str) => List<GetwhyprimeLeadsResponse>.from(json.decode(str).map((x) => GetwhyprimeLeadsResponse.fromJson(x)));

String getwhyprimeLeadsResponseToJson(List<GetwhyprimeLeadsResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetwhyprimeLeadsResponse {
    String status;
    String message;
    List<WhyPrimeleads> data;

    GetwhyprimeLeadsResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetwhyprimeLeadsResponse.fromJson(Map<String, dynamic> json) => GetwhyprimeLeadsResponse(
        status: json["status"],
        message: json["message"],
        data: List<WhyPrimeleads>.from(json["data"].map((x) => WhyPrimeleads.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class WhyPrimeleads {
    String id;
    String sectorId;
    String title;
    String icon;
   
    String sectorName;

    WhyPrimeleads({
        required this.id,
        required this.sectorId,
        required this.title,
        required this.icon,
       
        required this.sectorName,
    });

    factory WhyPrimeleads.fromJson(Map<String, dynamic> json) => WhyPrimeleads(
        id: json["id"],
        sectorId: json["sector_id"],
        title: json["title"],
        icon: json["icon"],
      
        sectorName: json["sector_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sector_id": sectorId,
        "title": title,
        "icon": icon,
      
        "sector_name": sectorName,
    };
}
