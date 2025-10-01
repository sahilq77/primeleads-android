// To parse this JSON data, do
//
//     final getSetOrderResponse = getSetOrderResponseFromJson(jsonString);

import 'dart:convert';

List<GetSetOrderResponse> getSetOrderResponseFromJson(String str) =>
    List<GetSetOrderResponse>.from(
      json.decode(str).map((x) => GetSetOrderResponse.fromJson(x)),
    );

String getSetOrderResponseToJson(List<GetSetOrderResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSetOrderResponse {
  String? status; // Made nullable
  String? message; // Made nullable
  SetOrderData? data; // Made nullable

  GetSetOrderResponse({this.status, this.message, this.data});

  factory GetSetOrderResponse.fromJson(Map<String, dynamic> json) =>
      GetSetOrderResponse(
        status: json["status"] as String?,
        message: json["message"] as String?,
        data: json["data"] != null ? SetOrderData.fromJson(json["data"]) : null,
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson(),
  };
}

class SetOrderData {
  String? id; // Made nullable
  String? userId; // Made nullable
  String? subscribtionId; // Made nullable
  DateTime? buyDate; // Made nullable
  String? buyTime; // Made nullable
  dynamic transactionNo;
  String? refNo; // Made nullable
  String? payment; // Made nullable
  dynamic stateId;
  dynamic cityId;
  String? sectorId; // Made nullable
  String? hasExpired; // Made nullable
  String? leadStatus; // Made nullable
  String? status; // Made nullable
  String? isDeleted; // Made nullable
  DateTime? createdOn; // Made nullable
  DateTime? updatedOn; // Made nullable
  String? sectorName; // Made nullable
  String? packageName; // Made nullable
  String? userName; // Made nullable
  String? topic; // Made nullable

  SetOrderData({
    this.id,
    this.userId,
    this.subscribtionId,
    this.buyDate,
    this.buyTime,
    this.transactionNo,
    this.refNo,
    this.payment,
    this.stateId,
    this.cityId,
    this.sectorId,
    this.hasExpired,
    this.leadStatus,
    this.status,
    this.isDeleted,
    this.createdOn,
    this.updatedOn,
    this.sectorName,
    this.packageName,
    this.userName,
    this.topic,
  });

  factory SetOrderData.fromJson(Map<String, dynamic> json) => SetOrderData(
    id: json["id"] as String?,
    userId: json["user_id"] as String?,
    subscribtionId: json["subscribtion_id"] as String?,
    buyDate:
        json["buy_date"] != null ? DateTime.tryParse(json["buy_date"]) : null,
    buyTime: json["buy_time"] as String?,
    transactionNo: json["transaction_no"],
    refNo: json["ref_no"] as String?,
    payment: json["payment"] as String?,
    stateId: json["state_id"],
    cityId: json["city_id"],
    sectorId: json["sector_id"] as String?,
    hasExpired: json["has_expired"] as String?,
    leadStatus: json["lead_status"] as String?,
    status: json["status"] as String?,
    isDeleted: json["is_deleted"] as String?,
    createdOn:
        json["created_on"] != null
            ? DateTime.tryParse(json["created_on"])
            : null,
    updatedOn:
        json["updated_on"] != null
            ? DateTime.tryParse(json["updated_on"])
            : null,
    sectorName: json["sector_name"] as String?,
    packageName: json["package_name"] as String?,
    userName: json["user_name"] as String?,
    topic: json["topic"] as String?,
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "subscribtion_id": subscribtionId,
    "buy_date":
        buyDate != null
            ? "${buyDate!.year.toString().padLeft(4, '0')}-${buyDate!.month.toString().padLeft(2, '0')}-${buyDate!.day.toString().padLeft(2, '0')}"
            : null,
    "buy_time": buyTime,
    "transaction_no": transactionNo,
    "ref_no": refNo,
    "payment": payment,
    "state_id": stateId,
    "city_id": cityId,
    "sector_id": sectorId,
    "has_expired": hasExpired,
    "lead_status": leadStatus,
    "status": status,
    "is_deleted": isDeleted,
    "created_on": createdOn?.toIso8601String(),
    "updated_on": updatedOn?.toIso8601String(),
    "sector_name": sectorName,
    "package_name": packageName,
    "user_name": userName,
    "topic": topic,
  };
}
