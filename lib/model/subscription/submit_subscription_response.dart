// To parse this JSON data, do
//
//     final getSubmitSubscriptionResponse = getSubmitSubscriptionResponseFromJson(jsonString);

import 'dart:convert';

List<GetSubmitSubscriptionResponse> getSubmitSubscriptionResponseFromJson(
  String str,
) => List<GetSubmitSubscriptionResponse>.from(
  json.decode(str).map((x) => GetSubmitSubscriptionResponse.fromJson(x)),
);

String getSubmitSubscriptionResponseToJson(
  List<GetSubmitSubscriptionResponse> data,
) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSubmitSubscriptionResponse {
  String status;
  String message;
  Data data;

  GetSubmitSubscriptionResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetSubmitSubscriptionResponse.fromJson(Map<String, dynamic> json) =>
      GetSubmitSubscriptionResponse(
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
  DateTime buyDate;
  String buyTime;
  dynamic transactionNo;
  String payment;

  String sectorId;
  String topicName;

  Data({
    required this.id,
    required this.userId,
    required this.subscribtionId,
    required this.buyDate,
    required this.buyTime,
    required this.transactionNo,
    required this.payment,

    required this.sectorId,
    required this.topicName,
  });

  factory Data.fromJson(Map<String, dynamic> json) => Data(
    id: json["id"] ?? "",
    userId: json["user_id"] ?? "",
    subscribtionId: json["subscribtion_id"] ?? "",
    buyDate: DateTime.parse(json["buy_date"]),
    buyTime: json["buy_time"] ?? "",
    transactionNo: json["transaction_no"] ?? "",
    payment: json["payment"] ?? "",

    sectorId: json["sector_id"] ?? "",
    topicName: json["topic"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "user_id": userId,
    "subscribtion_id": subscribtionId,
    "buy_date":
        "${buyDate.year.toString().padLeft(4, '0')}-${buyDate.month.toString().padLeft(2, '0')}-${buyDate.day.toString().padLeft(2, '0')}",
    "buy_time": buyTime,
    "transaction_no": transactionNo,
    "payment": payment,

    "sector_id": sectorId,
    "topic ": topicName,
  };
}
