// To parse this JSON data, do
//
//     final getNotificationResoponse = getNotificationResoponseFromJson(jsonString);

import 'dart:convert';

List<GetNotificationResoponse> getNotificationResoponseFromJson(String str) =>
    List<GetNotificationResoponse>.from(
      json.decode(str).map((x) => GetNotificationResoponse.fromJson(x)),
    );

String getNotificationResoponseToJson(List<GetNotificationResoponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetNotificationResoponse {
  String status;
  String message;
  List<NotificationData> data;

  GetNotificationResoponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetNotificationResoponse.fromJson(Map<String, dynamic> json) =>
      GetNotificationResoponse(
        status: json["status"],
        message: json["message"],
        data: List<NotificationData>.from(json["data"].map((x) => NotificationData.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": List<dynamic>.from(data.map((x) => x.toJson())),
  };
}

class NotificationData {
  String pushId;
  String sectorList;
  String customerDetails;
  String notificationId;
  DateTime pushCreatedOn;
  String id;
  String title;
  String description;
  String notificationImage;
  DateTime createdOn;
  DateTime updatedOn;

  NotificationData({
    required this.pushId,
    required this.sectorList,
    required this.customerDetails,
    required this.notificationId,
    required this.pushCreatedOn,
    required this.id,
    required this.title,
    required this.description,
    required this.notificationImage,
    required this.createdOn,
    required this.updatedOn,
  });

  factory NotificationData.fromJson(Map<String, dynamic> json) => NotificationData(
    pushId: json["push_id"] ?? "",
    sectorList: json["sector_list"] ?? "",
    customerDetails: json["customer_details"] ?? "",
    notificationId: json["notification_id"] ?? "",
    pushCreatedOn: DateTime.parse(json["push_created_on"]),
    id: json["id"] ?? "",
    title: json["title"] ?? "",
    description: json["description"] ?? "",
    notificationImage: json["notification_image"] ?? "",
    createdOn: DateTime.parse(json["created_on"]),
    updatedOn: DateTime.parse(json["updated_on"]),
  );

  Map<String, dynamic> toJson() => {
    "push_id": pushId,
    "sector_list": sectorList,
    "customer_details": customerDetails,
    "notification_id": notificationId,
    "push_created_on": pushCreatedOn.toIso8601String(),
    "id": id,
    "title": title,
    "description": description,
    "notification_image": notificationImage,
    "created_on": createdOn.toIso8601String(),
    "updated_on": updatedOn.toIso8601String(),
  };
}
