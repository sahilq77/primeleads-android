// To parse this JSON data, do
//
//     final getLeadsResponse = getLeadsResponseFromJson(jsonString);

import 'dart:convert';

List<GetLeadsResponse> getLeadsResponseFromJson(String str) =>
    List<GetLeadsResponse>.from(
      json.decode(str).map((x) => GetLeadsResponse.fromJson(x)),
    );

String getLeadsResponseToJson(List<GetLeadsResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLeadsResponse {
  String? status;
  String? message;
  List<LeadsData>? data;

  GetLeadsResponse({this.status, this.message, this.data});

  factory GetLeadsResponse.fromJson(Map<String, dynamic> json) =>
      GetLeadsResponse(
        status: json["status"] as String?,
        message: json["message"] as String?,
        data:
            json["data"] != null
                ? List<LeadsData>.from(
                  json["data"].map((x) => LeadsData.fromJson(x)),
                )
                : null,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data":
        data != null ? List<dynamic>.from(data!.map((x) => x.toJson())) : null,
  };

  GetLeadsResponse copyWith({
    String? status,
    String? message,
    List<LeadsData>? data,
  }) => GetLeadsResponse(
    status: status ?? this.status,
    message: message ?? this.message,
    data: data ?? this.data,
  );
}

class LeadsData {
  String? id;
  String? leadId;
  String? name;
  String? mobileNo;
  String? whatsappNo;
  String? state;
  String? city;
  String? location;
  String? packageId;
  String? packageName;
  String? sectorName;
  String? noteId;
  String? note;
  String? distributionDate;
  String? totalLeads;
  String? leadsSent;
  String? receivedLeads;
  String? remainLeads;

  LeadsData({
    this.id,
    this.leadId,
    this.name,
    this.mobileNo,
    this.whatsappNo,
    this.state,
    this.city,
    this.location,
    this.packageId,
    this.packageName,
    this.sectorName,
    this.noteId,
    this.note,
    this.distributionDate,
    this.totalLeads,
    this.leadsSent,
    this.receivedLeads,
    this.remainLeads,
  });

  factory LeadsData.fromJson(Map<String, dynamic> json) => LeadsData(
    id: json["id"] as String?,
    leadId: json["lead_id"] as String?,
    name: json["name"] as String?,
    mobileNo: json["mobile_no"] as String?,
    whatsappNo: json["whatsapp_no"] as String?,
    state: json["state"] as String?,
    city: json["city"] as String?,
    location: json["location"] as String?,
    packageId: json["package_id"] as String?,
    packageName: json["package_name"] as String?,
    sectorName: json["sector_name"] as String?,
    noteId: json["note_id"] as String?,
    note: json["note"] as String?,
    distributionDate: json["distribution_date"] as String?,
    totalLeads: json["total_leads"] as String?,
    leadsSent: json["leads_sent"] as String?,
    receivedLeads: json["received_leads"] as String?,
    remainLeads: json["remain_leads"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lead_id": leadId,
    "name": name,
    "mobile_no": mobileNo,
    "whatsapp_no": whatsappNo,
    "state": state,
    "city": city,
    "location": location,
    "package_id": packageId,
    "package_name": packageName,
    "sector_name": sectorName,
    "note_id": noteId,
    "note": note,
    "distribution_date": distributionDate,
    "total_leads": totalLeads,
    "leads_sent": leadsSent,
    "received_leads": receivedLeads,
    "remain_leads": remainLeads,
  };

  LeadsData copyWith({
    String? id,
    String? leadId,
    String? name,
    String? mobileNo,
    String? whatsappNo,
    String? state,
    String? city,
    String? location,
    String? packageId,
    String? packageName,
    String? sectorName,
    String? noteId,
    String? note,
    String? distributionDate,
    String? totalLeads,
    String? leadsSent,
    String? receivedLeads,
    String? remainLeads,
  }) => LeadsData(
    id: id ?? this.id,
    leadId: leadId ?? this.leadId,
    name: name ?? this.name,
    mobileNo: mobileNo ?? this.mobileNo,
    whatsappNo: whatsappNo ?? this.whatsappNo,
    state: state ?? this.state,
    city: city ?? this.city,
    location: location ?? this.location,
    packageId: packageId ?? this.packageId,
    packageName: packageName ?? this.packageName,
    sectorName: sectorName ?? this.sectorName,
    noteId: noteId ?? this.noteId,
    note: note ?? this.note,
    distributionDate: distributionDate ?? this.distributionDate,
    totalLeads: totalLeads ?? this.totalLeads,
    leadsSent: leadsSent ?? this.leadsSent,
    receivedLeads: receivedLeads ?? this.receivedLeads,
    remainLeads: remainLeads ?? this.remainLeads,
  );
}
