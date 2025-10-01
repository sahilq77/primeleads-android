import 'package:another_flushbar/flushbar.dart';
import 'package:another_flushbar/flushbar_route.dart';
import 'package:flutter/material.dart';
import 'package:prime_leads/utility/app_colors.dart';

class Utils {
  static void flushbarMessage(
    String message,
    BuildContext context, {
    required String status,
  }) {
    showFlushbar(
      context: context,
      flushbar: Flushbar(
        margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        flushbarPosition: FlushbarPosition.TOP,
        padding: EdgeInsets.all(15),
        forwardAnimationCurve: Curves.decelerate,
        message: message,
        reverseAnimationCurve: Curves.easeInOut,
        duration: Duration(seconds: 3),
        backgroundColor: status == 'e' ? AppColors.error : AppColors.success,
        positionOffset: 20.0,
        borderRadius: BorderRadius.circular(10),
        icon:
            status == 'e'
                ? Icon(Icons.error, size: 28, color: Colors.white)
                : Icon(Icons.check_circle_sharp, size: 28, color: Colors.white),
      )..show(context),
    );
  }

  static snackBar(String message, BuildContext context) {
    return ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(backgroundColor: AppColors.error, content: Text(message)),
    );
  }
}
