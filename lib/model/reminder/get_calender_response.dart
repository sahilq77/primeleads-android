// To parse this JSON data, do
//
//     final getCalenderResponse = getCalenderResponseFromJson(jsonString);

import 'dart:convert';

List<GetCalenderResponse> getCalenderResponseFromJson(String str) =>
    List<GetCalenderResponse>.from(
      json.decode(str).map((x) => GetCalenderResponse.fromJson(x)),
    );

String getCalenderResponseToJson(List<GetCalenderResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetCalenderResponse {
  String status;
  String message;
  List<CalenderData> data;

  GetCalenderResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetCalenderResponse.fromJson(Map<String, dynamic> json) =>
      GetCalenderResponse(
        status: json["status"],
        message: json["message"],
        data: List<CalenderData>.from(
          json["data"].map((x) => CalenderData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class CalenderData {
  DateTime reminderDate;
  int reminderCount;

  CalenderData({required this.reminderDate, required this.reminderCount});

  factory CalenderData.fromJson(Map<String, dynamic> json) => CalenderData(
    reminderDate: DateTime.parse(json["reminder_date"]),
    reminderCount: json["reminder_count"],
  );

  Map<String, dynamic> toJson() => {
    "reminder_date":
        "${reminderDate.year.toString().padLeft(4, '0')}-${reminderDate.month.toString().padLeft(2, '0')}-${reminderDate.day.toString().padLeft(2, '0')}",
    "reminder_count": reminderCount,
  };
}
