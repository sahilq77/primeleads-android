// To parse this JSON data, do
//
//     final setReminderResponse = setReminderResponseFromJson(jsonString);

import 'dart:convert';

List<SetReminderResponse> setReminderResponseFromJson(String str) => List<SetReminderResponse>.from(json.decode(str).map((x) => SetReminderResponse.fromJson(x)));

String setReminderResponseToJson(List<SetReminderResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class SetReminderResponse {
    String status;
    String message;
    List<dynamic> data;

    SetReminderResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory SetReminderResponse.fromJson(Map<String, dynamic> json) => SetReminderResponse(
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
