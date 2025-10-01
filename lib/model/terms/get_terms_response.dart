// To parse this JSON data, do
//
//     final getTermsResponse = getTermsResponseFromJson(jsonString);

import 'dart:convert';

List<GetTermsResponse> getTermsResponseFromJson(String str) => List<GetTermsResponse>.from(json.decode(str).map((x) => GetTermsResponse.fromJson(x)));

String getTermsResponseToJson(List<GetTermsResponse> data) => json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetTermsResponse {
    String status;
    String message;
    List<Terms> data;

    GetTermsResponse({
        required this.status,
        required this.message,
        required this.data,
    });

    factory GetTermsResponse.fromJson(Map<String, dynamic> json) => GetTermsResponse(
        status: json["status"],
        message: json["message"],
        data: List<Terms>.from(json["data"].map((x) => Terms.fromJson(x))),
    );

    Map<String, dynamic> toJson() => {
        "status": status,
        "message": message,
        "data": List<dynamic>.from(data.map((x) => x.toJson())),
    };
}

class Terms {
    String id;
    String pageHeading;
    String pageHeadingInLocalLanguage;
    String pageContent;
    String pageContentInLocalLanguage;
    String isDeleted;
    String status;
    DateTime createdOn;
    DateTime updatedOn;

    Terms({
        required this.id,
        required this.pageHeading,
        required this.pageHeadingInLocalLanguage,
        required this.pageContent,
        required this.pageContentInLocalLanguage,
        required this.isDeleted,
        required this.status,
        required this.createdOn,
        required this.updatedOn,
    });

    factory Terms.fromJson(Map<String, dynamic> json) => Terms(
        id: json["id"],
        pageHeading: json["page_heading"],
        pageHeadingInLocalLanguage: json["page_heading_in_local_language"],
        pageContent: json["page_content"],
        pageContentInLocalLanguage: json["page_content_in_local_language"],
        isDeleted: json["is_deleted"],
        status: json["status"],
        createdOn: DateTime.parse(json["created_on"]),
        updatedOn: DateTime.parse(json["updated_on"]),
    );

    Map<String, dynamic> toJson() => {
        "id": id,
        "page_heading": pageHeading,
        "page_heading_in_local_language": pageHeadingInLocalLanguage,
        "page_content": pageContent,
        "page_content_in_local_language": pageContentInLocalLanguage,
        "is_deleted": isDeleted,
        "status": status,
        "created_on": createdOn.toIso8601String(),
        "updated_on": updatedOn.toIso8601String(),
    };
}
