// To parse this JSON data, do
//
//     final getNoteUpdateResponse = getNoteUpdateResponseFromJson(jsonString);

import 'dart:convert';

List<GetNoteUpdateResponse> getNoteUpdateResponseFromJson(String str) => List<GetNoteUpdateResponse>.from(json.decode(str).map((x) => GetNoteUpdateResponse.fromJson(x)));

String getNoteUpdateResponseToJson(List<GetNoteUpdateResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetNoteUpdateResponse {
    String status;
    String message;
    List<dynamic> data;

    GetNoteUpdateResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetNoteUpdateResponse.fromJson(Map<String, dynamic> json) => GetNoteUpdateResponse(
        status: json["status"],
        message: json["message"],
        data: List<dynamic>.from(json["data"].map((x) => x)),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x)),
    };
}
