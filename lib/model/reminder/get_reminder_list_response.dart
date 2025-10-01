// To parse this JSON data, do
//
//     final getReminderListResponse = getReminderListResponseFromJson(jsonString);

import 'dart:convert';

List<GetReminderListResponse> getReminderListResponseFromJson(String str) =>
    List<GetReminderListResponse>.from(
      json.decode(str).map((x) => GetReminderListResponse.fromJson(x)),
    );

String getReminderListResponseToJson(List<GetReminderListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetReminderListResponse {
  String status;
  String message;
  List<ReminderData> data;

  GetReminderListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetReminderListResponse.fromJson(Map<String, dynamic> json) =>
      GetReminderListResponse(
        status: json["status"],
        message: json["message"],
        data: List<ReminderData>.from(
          json["data"].map((x) => ReminderData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };

  GetReminderListResponse copyWith({
    String? status,
    String? message,
    List<ReminderData>? data,
  }) => GetReminderListResponse(
    status: status ?? this.status,
    message: message ?? this.message,
    data: data ?? this.data,
  );
}

class ReminderData {
  String id;
  String sectorId;
  String userId;
  String note;
  DateTime reminderDate;
  String reminderTime;
  String name;
  String mobileNo;
  String whatsappNo;
  DateTime date;

  ReminderData({
    required this.id,
    required this.sectorId,
    required this.userId,
    required this.note,
    required this.reminderDate,
    required this.reminderTime,
    required this.name,
    required this.mobileNo,
    required this.whatsappNo,
    required this.date,
  });

  factory ReminderData.fromJson(Map<String, dynamic> json) => ReminderData(
    id: json["id"] ?? "",
    sectorId: json["sector_id"] ?? "",
    userId: json["user_id"] ?? "",
    note: json["note"] ?? "",
    reminderDate: DateTime.parse(json["reminder_date"]),
    reminderTime: json["reminder_time"] ?? "",
    name: json["name"] ?? "",
    mobileNo: json["mobile_no"] ?? "",
    whatsappNo: json["whatsapp_no"] ?? "",
    date: DateTime.parse(json["date"]),
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "sector_id": sectorId,
    "user_id": userId,
    "note": note,
    "reminder_date":
        "${reminderDate.year.toString().padLeft(4, '0')}-${reminderDate.month.toString().padLeft(2, '0')}-${reminderDate.day.toString().padLeft(2, '0')}",
    "reminder_time": reminderTime,
    "name": name,
    "mobile_no": mobileNo,
    "whatsapp_no": whatsappNo,
    "date":
        "${date.year.toString().padLeft(4, '0')}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}",
  };

  ReminderData copyWith({
    String? id,
    String? sectorId,
    String? userId,
    String? note,
    DateTime? reminderDate,
    String? reminderTime,
    String? name,
    String? mobileNo,
    String? whatsappNo,
    DateTime? date,
  }) => ReminderData(
    id: id ?? this.id,
    sectorId: sectorId ?? this.sectorId,
    userId: userId ?? this.userId,
    note: note ?? this.note,
    reminderDate: reminderDate ?? this.reminderDate,
    reminderTime: reminderTime ?? this.reminderTime,
    name: name ?? this.name,
    mobileNo: mobileNo ?? this.mobileNo,
    whatsappNo: whatsappNo ?? this.whatsappNo,
    date: date ?? this.date,
  );
}
