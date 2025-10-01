import 'dart:convert';

GetTrainingVideoCall getTrainingVideoCallFromJson(String str) =>
    GetTrainingVideoCall.fromJson(json.decode(str));

String getTrainingVideoCallToJson(GetTrainingVideoCall data) =>
    json.encode(data.toJson());

class GetTrainingVideoCall {
  final String sectorId;
  final String limit;
  final String offset;
  final String userID;
  GetTrainingVideoCall(
      {required this.sectorId,
      required this.limit,
      required this.offset,
      required this.userID});

  factory GetTrainingVideoCall.fromJson(Map<String, dynamic> json) =>
      GetTrainingVideoCall(
        sectorId: json["sector_id"] ?? "",
        limit: json["limit"] ?? "",
        offset: json["offset"] ?? "",
        userID: json["user_id"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "sector_id": sectorId,
        "limit": limit,
        "offset": offset,
        "user_id": userID
      };
}
