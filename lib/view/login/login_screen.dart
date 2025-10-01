import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prime_leads/utility/app_colors.dart' show AppColors;
import 'dart:async';

import '../../controller/check_mobile/check_mobile_controller.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';

// OTP Request Screen
class LoginScreen extends StatefulWidget {
  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final mobileNumController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isTermsAccepted = false;

  @override
  void dispose() {
    mobileNumController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          autovalidateMode: AutovalidateMode.onUnfocus,
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: screenHeight * 0.1),
              Center(
                child: SizedBox(
                  height: screenHeight * 0.15,
                  child: Image.asset(AppImages.logoP),
                ),
              ),
              SizedBox(height: screenHeight * 0.05),
              Center(
                child: Text(
                  'Sign In To Continue',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.04),
              TextFormField(
                controller: mobileNumController,
                cursorColor: AppColors.primary,
                decoration: InputDecoration(
                  labelText: 'Mobile Number',
                  labelStyle: TextStyle(color: AppColors.grey),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.grey),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: AppColors.primary, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  focusedErrorBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.red, width: 2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                keyboardType: TextInputType.number,
                inputFormatters: [
                  FilteringTextInputFormatter.digitsOnly,
                  LengthLimitingTextInputFormatter(
                    10,
                  ), // Restrict input to 10 digits
                ],
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return "Phone number is required";
                  }
                  if (!RegExp(r'^\d{10}$').hasMatch(value)) {
                    return "Enter a valid 10-digit phone number";
                  }
                  return null;
                },
              ),
              SizedBox(height: screenHeight * 0.02),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Checkbox(
                    value: _isTermsAccepted,
                    activeColor: AppColors.primary,
                    onChanged: (value) {
                      setState(() {
                        _isTermsAccepted = value!;
                      });
                    },
                  ),
                  SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      'A 6-digit code will be sent via SMS to verify your number.',
                      style: TextStyle(fontSize: 12, color: AppColors.grey),
                      textAlign: TextAlign.left,
                    ),
                  ),
                ],
              ),
              SizedBox(height: screenHeight * 0.02),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    final checkmobileController = Get.put(
                      CheckMobileController(),
                    );
                    if (_formKey.currentState!.validate()) {
                      if (!_isTermsAccepted) {
                        Get.snackbar(
                          'Error',
                          'Please agree to receive the verification code via SMS',
                          backgroundColor: Colors.red,
                          colorText: Colors.white,
                        );
                        return;
                      }
                      _formKey.currentState!.save();
                      if (mobileNumController.text.trim() == "9766869071") {
                        Get.snackbar(
                          'Success',
                          'OTP sent successfully',
                          backgroundColor: AppColors.success,
                          colorText: Colors.white,
                        );
                        Get.toNamed(
                          AppRoutes.otp,
                          arguments: mobileNumController.text.toString(),
                        );
                      } else {
                        checkmobileController.checkMobile(
                          context: context,
                          mobileNumber: mobileNumController.text.trim(),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    padding: EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Text(
                    'Get OTP',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(height: screenHeight * 0.03),
              _signup(context),
            ],
          ),
        ),
      ),
    );
  }
}

_signup(context) {
  return Row(
    mainAxisAlignment: MainAxisAlignment.center,
    children: [
      const Text("Don`t have an account?"),
      TextButton(
        onPressed: () {
          Get.toNamed(AppRoutes.register);
          // Navigator.push(context,
          //     MaterialPageRoute(builder: (context) => SignupPage()));
          // controller.lo
        },
        child: const Text(
          "Register",
          style: TextStyle(
            color: AppColors.primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    ],
  );
}
