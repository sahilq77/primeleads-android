import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';


import '../app_images.dart';

class ProgressDialog {
  static showProgressDialog(BuildContext context) async {
    try {
      await Future.delayed(const Duration(milliseconds: 50));
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return Lottie.asset("");
        },
      );
    } catch (e) {
      if (kDebugMode) {
        print(e.toString());
      }
    }
  }
}
