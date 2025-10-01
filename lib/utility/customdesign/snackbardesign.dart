import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prime_leads/utility/app_colors.dart';



void SnackBarDesign(String Message, BuildContext context, Color backgroundColor,
    Color textColor) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      Message,
      style: TextStyle(color: textColor),
    ),
    backgroundColor: backgroundColor.withOpacity(0.7),
    duration: const Duration(seconds: 2),
    behavior: SnackBarBehavior.floating, // Customize the behavior
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Customize the border radius
    ),
  ));

  if (kDebugMode) {
    print(Message);
  }
}

void SomethingWentWrongSnackBarDesign(BuildContext context) async {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: const Text(
      "Something went wrong, Please be patient we are working on it and check your connection",
      style: TextStyle(color: AppColors.error),
    ),
    backgroundColor: AppColors.error.withOpacity(0.7),
    duration: const Duration(seconds: 2),
    behavior: SnackBarBehavior.floating,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0),
    ),
  ));
}

void SnackBarDesignLowTime(String Message, BuildContext context,
    Color backgroundColor, Color textColor) {
  ScaffoldMessenger.of(context).showSnackBar(SnackBar(
    content: Text(
      Message,
      style: TextStyle(color: textColor),
    ),
    backgroundColor: backgroundColor.withOpacity(0.7),
    duration: const Duration(seconds: 1),
    behavior: SnackBarBehavior.floating, // Customize the behavior
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(10.0), // Customize the border radius
    ),
  ));

  if (kDebugMode) {
    print(Message);
  }
}
