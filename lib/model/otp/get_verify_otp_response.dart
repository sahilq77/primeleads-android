import 'dart:convert';

List<GetVerifyOtpResponse> getVerifyOtpResponseFromJson(String str) =>
    List<GetVerifyOtpResponse>.from(
      json.decode(str).map((x) => GetVerifyOtpResponse.fromJson(x)),
    );

String getVerifyOtpResponseToJson(List<GetVerifyOtpResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetVerifyOtpResponse {
  String status;
  String message;
  VerifyOtpData data;

  GetVerifyOtpResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetVerifyOtpResponse.fromJson(Map<String, dynamic> json) =>
      GetVerifyOtpResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data:
            json["data"] is Map<String, dynamic>
                ? VerifyOtpData.fromJson(json["data"])
                : VerifyOtpData.empty(), // Handle empty list case
      );

  Map<String, dynamic> toJson() => {
    "status": status,
    "message": message,
    "data": data.toJson(),
  };
}

class VerifyOtpData {
  String userId;
  String userName;
  String mobileNumber;
  String stateId;
  String cityId;
  String sectorId;
  String? userImage; // Made nullable to handle null explicitly
  bool isNewUser;
  String loginType;

  VerifyOtpData({
    required this.userId,
    required this.userName,
    required this.mobileNumber,
    required this.stateId,
    required this.cityId,
    required this.sectorId,
    this.userImage,
    required this.isNewUser,
    required this.loginType,
  });

  // Factory for creating an empty VerifyOtpData object
  factory VerifyOtpData.empty() => VerifyOtpData(
    userId: "",
    userName: "",
    mobileNumber: "",
    stateId: "",
    cityId: "",
    sectorId: "",
    userImage: null,
    isNewUser: false,
    loginType: "",
  );

  factory VerifyOtpData.fromJson(Map<String, dynamic> json) => VerifyOtpData(
    userId: json["user_id"] ?? "",
    userName: json["user_name"] ?? "",
    mobileNumber: json["mobile_number"] ?? "",
    stateId: json["state_id"] ?? "",
    cityId: json["city_id"] ?? "",
    sectorId: json["sector_id"] ?? "",
    userImage: json["user_image"],
    isNewUser: json["is_new_user"] ?? false,
    loginType: json["login_type"] ?? "",
  );

  Map<String, dynamic> toJson() => {
    "user_id": userId,
    "user_name": userName,
    "mobile_number": mobileNumber,
    "state_id": stateId,
    "city_id": cityId,
    "sector_id": sectorId,
    "user_image": userImage,
    "is_new_user": isNewUser,
    "login_type": loginType,
  };
}
