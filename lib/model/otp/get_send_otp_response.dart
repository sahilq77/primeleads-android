import 'dart:convert';

List<GetSendOtpResponse> getSendOtpResponseFromJson(String str) =>
    List<GetSendOtpResponse>.from(
      json.decode(str).map((x) => GetSendOtpResponse.fromJson(x)),
    );

String getSendOtpResponseToJson(List<GetSendOtpResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetSendOtpResponse {
  String status;
  String message;
  OtpData? data; // Made nullable to handle empty data

  GetSendOtpResponse({
    required this.status,
    required this.message,
    this.data, // Nullable, so it can be null when data is empty
  });

  factory GetSendOtpResponse.fromJson(Map<String, dynamic> json) =>
      GetSendOtpResponse(
        status: json["status"]?.toString() ?? "", // Handle potential null
        message: json["message"] ?? "",
        data:
            json["data"] is Map<String, dynamic>
                ? OtpData.fromJson(json["data"] ?? [])
                : null, // Handle empty list or null data
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data?.toJson() ?? [], // Return empty list if data is null
  };
}

class OtpData {
  String otp;
  bool isNew;
  String mobileNumber;
  int? tempId; // Added to handle temp_id
  String? userName; // Added to handle user_name

  OtpData({
    required this.otp,
    required this.isNew,
    required this.mobileNumber,
    this.tempId,
    this.userName,
  });

  factory OtpData.fromJson(Map<String, dynamic> json) => OtpData(
    otp: json["otp"]?.toString() ?? "",
    isNew: json["is_new"] ?? false,
    mobileNumber: json["mobile_number"]?.toString() ?? "",
    tempId: json["temp_id"],
    userName: json["user_name"],
  );

  Map<String, dynamic> toJson() => {
    "otp": otp,
    "is_new": isNew,
    "mobile_number": mobileNumber,
    if (tempId != null) "temp_id": tempId,
    if (userName != null) "user_name": userName,
  };
}
