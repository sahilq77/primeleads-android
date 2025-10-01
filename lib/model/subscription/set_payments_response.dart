// To parse this JSON data, do
//
//     final getSetPaymentResponse = getSetPaymentResponseFromJson(jsonString);

import 'dart:convert';

List<GetSetPaymentResponse> getSetPaymentResponseFromJson(String str) => List<GetSetPaymentResponse>.from(json.decode(str).map((x) => GetSetPaymentResponse.fromJson(x)));

String getSetPaymentResponseToJson(List<GetSetPaymentResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSetPaymentResponse {
    String status;
    String message;
    Data data;

    GetSetPaymentResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetSetPaymentResponse.fromJson(Map<String, dynamic> json) => GetSetPaymentResponse(
        status: json["status"],
        message: json["message"],
        data: Data.fromJson(json["data"]),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": data.toJson(),
    };
}

class Data {
    String id;
    String userId;
    String subscribtionId;
  
    String transactionNo;
    String refNo;
    String payment;
    dynamic stateId;
    dynamic cityId;
    String sectorId;
    String hasExpired;
    String leadStatus;
   

    Data({
        required this.id,
        required this.userId,
        required this.subscribtionId,
      
        required this.transactionNo,
        required this.refNo,
        required this.payment,
        required this.stateId,
        required this.cityId,
        required this.sectorId,
        required this.hasExpired,
        required this.leadStatus,
       
    });

    factory Data.fromJson(Map<String, dynamic> json) => Data(
        id: json["id"]??"",
        userId: json["user_id"]??"",
        subscribtionId: json["subscribtion_id"]??"",
        
        transactionNo: json["transaction_no"]??"",
        refNo: json["ref_no"]??"",
        payment: json["payment"]??"",
        stateId: json["state_id"]??"",
        cityId: json["city_id"]??"",
        sectorId: json["sector_id"]??"",
        hasExpired: json["has_expired"]??"",
        leadStatus: json["lead_status"]??"",
       
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "user_id": userId,
        "subscribtion_id": subscribtionId,
       
        "transaction_no": transactionNo,
        "ref_no": refNo,
        "payment": payment,
        "state_id": stateId,
        "city_id": cityId,
        "sector_id": sectorId,
        "has_expired": hasExpired,
        "lead_status": leadStatus,
       
    };
}
