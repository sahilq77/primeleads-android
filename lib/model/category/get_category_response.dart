// To parse this JSON data, do
//
//     final getCategoryResponse = getCategoryResponseFromJson(jsonString);

import 'dart:convert';

List<GetCategoryResponse> getCategoryResponseFromJson(String str) => List<GetCategoryResponse>.from(json.decode(str).map((x) => GetCategoryResponse.fromJson(x)));

String getCategoryResponseToJson(List<GetCategoryResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetCategoryResponse {
    String status;
    String message;
    List<Category> data;

    GetCategoryResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetCategoryResponse.fromJson(Map<String, dynamic> json) => GetCategoryResponse(
        status: json["status"],
        message: json["message"],
        data: List<Category>.from(json["data"].map((x) => Category.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Category {
    String id;
    String sectorName;
    String icon;
   

    Category({
        required this.id,
        required this.sectorName,
        required this.icon,
       
    });

    factory Category.fromJson(Map<String, dynamic> json) => Category(
        id: json["id"],
        sectorName: json["sector_name"],
        icon: json["icon"],
      
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "sector_name": sectorName,
        "icon": icon,
       
    };
}
