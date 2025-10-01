import 'dart:convert';

import 'package:flutter/foundation.dart';

import '../../../model/video/get_training_video_call.dart';



class Createjson {
  String createJsonForGetTrainingVideo(
      String sectorId, String limit, String offset,String userID) {
    try {
      const encoder = JsonEncoder.withIndent('');
      final call = GetTrainingVideoCall(
        sectorId: sectorId,
        limit: limit,
        offset: offset,
        userID:userID
      );
      final json = GetTrainingVideoCall.fromJson(call.toJson());
      return encoder.convert(json);
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
      return "";
    }
  }
}
