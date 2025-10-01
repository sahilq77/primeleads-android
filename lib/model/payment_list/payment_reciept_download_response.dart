// To parse this JSON data, do
//
//     final getPaymentRecieptUrlResponse = getPaymentRecieptUrlResponseFromJson(jsonString);

import 'dart:convert';

List<GetPaymentRecieptUrlResponse> getPaymentRecieptUrlResponseFromJson(String str) => List<GetPaymentRecieptUrlResponse>.from(json.decode(str).map((x) => GetPaymentRecieptUrlResponse.fromJson(x)));

String getPaymentRecieptUrlResponseToJson(List<GetPaymentRecieptUrlResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPaymentRecieptUrlResponse {
    String status;
    String message;
    String recipt;

    GetPaymentRecieptUrlResponse({
        required this.status,
        required this.message,
        required this.recipt,
    });

    factory GetPaymentRecieptUrlResponse.fromJson(Map<String, dynamic> json) => GetPaymentRecieptUrlResponse(
        status: json["status"],
        message: json["message"],
        recipt: json["recipt"],
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "recipt": recipt,
    };
}
