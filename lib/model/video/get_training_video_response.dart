import 'dart:convert';

List<GetTrainingVideoResponse> getTrainingVideoResponseFromJson(String str) =>
    List<GetTrainingVideoResponse>.from(
        json.decode(str).map((x) => GetTrainingVideoResponse.fromJson(x)));

String getTrainingVideoResponseToJson(List<GetTrainingVideoResponse> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetTrainingVideoResponse {
  final String status;
  final String message;
  final List<VideoData> data;

  GetTrainingVideoResponse({
    required this.status,
    required this.message,
    required this.data,
  });

  factory GetTrainingVideoResponse.fromJson(Map<String, dynamic> json) =>
      GetTrainingVideoResponse(
        status: json["status"] ?? "",
        message: json["message"] ?? "",
        data: json["data"] != null
            ? List<VideoData>.from(
                json["data"].map((x) => VideoData.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
      };
}

class VideoData {
  final String id;
  final String sectorId;
  final String videoLink;
  final String title;
  final String description;
  final String date;
  final String time;
  final String status;
  final String isDeleted;
  final String createdOn;
  final String updatedOn;
  final String sectorName;

  VideoData({
    required this.id,
    required this.sectorId,
    required this.videoLink,
    required this.title,
    required this.description,
    required this.date,
    required this.time,
    required this.status,
    required this.isDeleted,
    required this.createdOn,
    required this.updatedOn,
    required this.sectorName,
  });

  factory VideoData.fromJson(Map<String, dynamic> json) => VideoData(
        id: json["id"] ?? "",
        sectorId: json["sector_id"] ?? "",
        videoLink: json["video_link"] ?? "",
        title: json["title"] ?? "",
        description: json["description"] ?? "",
        date: json["date"] ?? "",
        time: json["time"] ?? "",
        status: json["status"] ?? "",
        isDeleted: json["is_deleted"] ?? "",
        createdOn: json["created_on"] ?? "",
        updatedOn: json["updated_on"] ?? "",
        sectorName: json["sector_name"] ?? "",
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "sector_id": sectorId,
        "video_link": videoLink,
        "title": title,
        "description": description,
        "date": date,
        "time": time,
        "status": status,
        "is_deleted": isDeleted,
        "created_on": createdOn,
        "updated_on": updatedOn,
        "sector_name": sectorName,
      };
}
