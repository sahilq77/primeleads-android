// To parse this JSON data, do
//
//     final getLeadDetailResponse = getLeadDetailResponseFromJson(jsonString);

import 'dart:convert';

List<GetLeadDetailResponse> getLeadDetailResponseFromJson(String str) =>
    List<GetLeadDetailResponse>.from(
      json.decode(str).map((x) => GetLeadDetailResponse.fromJson(x)),
    );

String getLeadDetailResponseToJson(List<GetLeadDetailResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLeadDetailResponse {
  String status;
  String message;
  LeadDetail data;

  GetLeadDetailResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetLeadDetailResponse.fromJson(Map<String, dynamic> json) =>
      GetLeadDetailResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: LeadDetail.fromJson(json["data"] ?? []),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class LeadDetail {
  String userId;
  String leadId;
  String sectorId;
  String userName;
  String leadsId;
  String name;
  String mobileNo;
  String whatsappNo;
  String state;
  String city;
  String location;
  dynamic note;
  dynamic reminderDate;
  dynamic reminderTime;
  DateTime createdOn;
  List<AdditionalDetail> additionalDetails;

  LeadDetail({
    required this.userId,
    required this.leadId,
    required this.sectorId,
    required this.userName,
    required this.leadsId,
    required this.name,
    required this.mobileNo,
    required this.whatsappNo,
    required this.state,
    required this.city,
    required this.location,
    required this.note,
    required this.reminderDate,
    required this.reminderTime,
    required this.createdOn,
    required this.additionalDetails,
  });

  factory LeadDetail.fromJson(Map<String, dynamic> json) => LeadDetail(
    userId: json["user_id"] ?? "",
    leadId: json["lead_id"] ?? "",
    sectorId: json["sector_id"] ?? "",
    userName: json["user_name"] ?? "",
    leadsId: json["leads_id"] ?? "",
    name: json["name"] ?? "",
    mobileNo: json["mobile_no"] ?? "",
    whatsappNo: json["whatsapp_no"] ?? "",
    state: json["state"] ?? "",
    city: json["city"] ?? "",
    location: json["location"] ?? "",
    note: json["note"] ?? "",
    reminderDate: json["reminder_date"] ?? "",
    reminderTime: json["reminder_time"] ?? "",
    createdOn: DateTime.parse(json["created_on"]),
    additionalDetails: List<AdditionalDetail>.from(
      json["additional_details"].map((x) => AdditionalDetail.fromJson(x)),
    ),
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "lead_id": leadId,
    "sector_id": sectorId,
    "user_name": userName,
    "leads_id": leadsId,
    "name": name,
    "mobile_no": mobileNo,
    "whatsapp_no": whatsappNo,
    "state": state,
    "city": city,
    "location": location,
    "note": note,
    "reminder_date": reminderDate,
    "reminder_time": reminderTime,
    "created_on": createdOn.toIso8601String(),
    "additional_details": List<dynamic>.from(
      additionalDetails.map((x) => x.toJson()),
    ),
  };
}

class AdditionalDetail {
  String title;
  String value;

  AdditionalDetail({required this.title, required this.value});

  factory AdditionalDetail.fromJson(Map<String, dynamic> json) =>
      AdditionalDetail(title: json["title"] ?? "", value: json["value"] ?? "");

  Map<String, dynamic> toJson() => {"title": title, "value": value};
}
