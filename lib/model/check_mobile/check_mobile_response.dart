// To parse this JSON data, do
//
//     final checkMobileResponse = checkMobileResponseFromJson(jsonString);

import 'dart:convert';

List<CheckMobileResponse> checkMobileResponseFromJson(String str) => List<CheckMobileResponse>.from(json.decode(str).map((x) => CheckMobileResponse.fromJson(x)));

String checkMobileResponseToJson(List<CheckMobileResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class CheckMobileResponse {
    String status;
    String message;
    List<dynamic> data;

    CheckMobileResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory CheckMobileResponse.fromJson(Map<String, dynamic> json) => CheckMobileResponse(
        status: json["status"],
        message: json["message"],
        data: List<dynamic>.from(json["data"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x)),
    };
}
