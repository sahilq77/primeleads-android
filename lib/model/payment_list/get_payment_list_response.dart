// To parse this JSON data, do
//
//     final getPaymentListResponse = getPaymentListResponseFromJson(jsonString);

import 'dart:convert';

List<GetPaymentListResponse> getPaymentListResponseFromJson(String str) =>
    List<GetPaymentListResponse>.from(
      json.decode(str).map((x) => GetPaymentListResponse.fromJson(x)),
    );

String getPaymentListResponseToJson(List<GetPaymentListResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetPaymentListResponse {
  String status;
  String message;
  List<PaymentData> data;

  GetPaymentListResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetPaymentListResponse.fromJson(Map<String, dynamic> json) =>
      GetPaymentListResponse(
        status: json["status"],
        message: json["message"],
        data: List<PaymentData>.from(
          json["data"].map((x) => PaymentData.fromJson(x)),
        ),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class PaymentData {
  String id;
  String refNo;
  String transactionNo;
  String userName;
  String mobileNumber;
  DateTime buyDate;
  String amount;
  String packageName;
  String payment;

  PaymentData({
    required this.id,
    required this.refNo,
    required this.transactionNo,
    required this.userName,
    required this.mobileNumber,
    required this.buyDate,
    required this.amount,
    required this.packageName,
    required this.payment,
  });

  factory PaymentData.fromJson(Map<String, dynamic> json) => PaymentData(
    refNo: json["ref_no"] ?? "",
    id: json["card_id"] ?? "",
    transactionNo: json["transaction_no"] ?? "",
    userName: json["user_name"] ?? "",
    mobileNumber: json["mobile_number"] ?? "",
    buyDate: DateTime.parse(json["buy_date"]),
    amount: json["discount_amount"] ?? "",
    packageName: json["package_name"] ?? "",
    payment: json["payment"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "transaction_no": transactionNo,
    "user_name": userName,
    "mobile_number": mobileNumber,
    "buy_date":
        "${buyDate.year.toString().padLeft(4, '0')}-${buyDate.month.toString().padLeft(2, '0')}-${buyDate.day.toString().padLeft(2, '0')}",
    "discount_amount": amount,
    "package_name": packageName,
    "payment": payment,
    "ref_no": refNo,
  };
}
