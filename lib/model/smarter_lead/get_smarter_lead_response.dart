// To parse this JSON data, do
//
//     final getSmarterLeadResponse = getSmarterLeadResponseFromJson(jsonString);

import 'dart:convert';

List<GetSmarterLeadResponse> getSmarterLeadResponseFromJson(String str) => List<GetSmarterLeadResponse>.from(json.decode(str).map((x) => GetSmarterLeadResponse.fromJson(x)));

String getSmarterLeadResponseToJson(List<GetSmarterLeadResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSmarterLeadResponse {
    String status;
    String message;
    List<SmarterLead> data;

    GetSmarterLeadResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetSmarterLeadResponse.fromJson(Map<String, dynamic> json) => GetSmarterLeadResponse(
        status: json["status"],
        message: json["message"],
        data: List<SmarterLead>.from(json["data"].map((x) => SmarterLead.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class SmarterLead {
    String id;
    String sectorId;
    String title;
    String icon;
    String description;
  
    String sectorName;

    SmarterLead({
        required this.id,
        required this.sectorId,
        required this.title,
        required this.icon,
        required this.description,
       
        required this.sectorName,
    });

    factory SmarterLead.fromJson(Map<String, dynamic> json) => SmarterLead(
        id: json["id"],
        sectorId: json["sector_id"],
        title: json["title"],
        icon: json["icon"],
        description: json["description"],
      
        sectorName: json["sector_name"],
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sector_id": sectorId,
        "title": title,
        "icon": icon,
        "description": description,
      
        "sector_name": sectorName,
    };
}
