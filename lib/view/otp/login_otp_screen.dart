import 'dart:async';
import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:prime_leads/controller/login/login_controller.dart';
import 'package:prime_leads/controller/login/verify_login_otp_controller.dart';

import '../../controller/login/login_send_otp_controller.dart';
import '../../notification_services .dart';
import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';

class OtpVerifyScreen extends StatefulWidget {
  @override
  _OtpVerifyScreenState createState() => _OtpVerifyScreenState();
}

class _OtpVerifyScreenState extends State<OtpVerifyScreen> {
  final loginControlller = Get.put(LoginController());
  final verifyLoginOtpController = Get.put(VerifyLoginOtpController());
  final loginSendOtpControlller = Get.put(LoginSendOtpController());
  final List<TextEditingController> _otpControllers = List.generate(
    6,
    (_) => TextEditingController(),
  );
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  int _resendTimer = 59;
  late Timer _timer;
  String? pushtoken;
  NotificationServices notificationServices = NotificationServices();

  @override
  void initState() {
    super.initState();
    _startTimer();
    notificationServices.firebaseInit(context);
    notificationServices.setInteractMessage(context);
    notificationServices.getDevicetoken().then((value) {
      log('Device Token ${value}');
      pushtoken = value;
      print(pushtoken);
      setState(() {});
    });
  }

  void _startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (_resendTimer > 0) {
        setState(() {
          _resendTimer--;
        });
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    _otpControllers.forEach((controller) => controller.dispose());
    _focusNodes.forEach((node) => node.dispose());
    super.dispose();
  }

  String _getOtp() {
    return _otpControllers.map((controller) => controller.text).join();
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.1),
            Center(
              child: SizedBox(
                height: screenHeight * 0.15,
                child: Image.asset(AppImages.logoP),
              ),
            ),
            SizedBox(height: screenHeight * 0.05),
            Text(
              'OTP Verification',
              style: GoogleFonts.poppins(
                fontSize: 24,
                fontWeight: FontWeight.w600,
                color: AppColors.textDark,
              ),
            ),
            SizedBox(height: screenHeight * 0.03),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Check your phone',
                  style: GoogleFonts.poppins(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDark,
                  ),
                ),
                SizedBox(height: screenHeight * 0.01),
                Text(
                  'We\'ve sent an OTP to your phone. Please check and enter it.',
                  style: GoogleFonts.poppins(
                    color: AppColors.grey,
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
            SizedBox(height: screenHeight * 0.03),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 50,
                  child: TextField(
                    controller: _otpControllers[index],
                    focusNode: _focusNodes[index],
                    textAlign: TextAlign.center,
                    keyboardType: TextInputType.number,
                    maxLength: 1,
                    decoration: InputDecoration(
                      counterText: '',
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.grey.shade300),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: "-",
                      hintStyle: TextStyle(
                        color: const Color(0xFFD9D9D9),
                        fontWeight: FontWeight.w600,
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(
                          color: AppColors.primary,
                          width: 2,
                        ),
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
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(
                        1,
                      ), // Restrict input to 10 digits
                    ],
                    onChanged: (value) {
                      if (value.length == 1 && index < 5) {
                        _focusNodes[index].unfocus();
                        FocusScope.of(
                          context,
                        ).requestFocus(_focusNodes[index + 1]);
                      }
                      if (value.isEmpty && index > 0) {
                        _focusNodes[index].unfocus();
                        FocusScope.of(
                          context,
                        ).requestFocus(_focusNodes[index - 1]);
                      }
                    },
                  ),
                );
              }),
            ),
            SizedBox(height: screenHeight * 0.04),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String otp = _getOtp();
                  if (otp.length == 6) {
                    final args = Get.arguments;
                    final mobile = args as String?;
                    // verifyLoginOtpController.verifyOTP(
                    //   context: context,
                    //   mobileNumber: mobile,
                    //   otp: otp,
                    //   token: pushtoken,
                    // );
                    if (mobile == "9766869071" && otp == "123456") {
                      // Static OTP logic: treat as valid and directly call login
                      loginControlller.login(
                        mobileNumber: mobile,
                        otp: otp,
                        token: pushtoken,
                      );
                    } else {
                      // Proceed with normal verification
                      verifyLoginOtpController.verifyOTP(
                        context: context,
                        mobileNumber: mobile,
                        otp: otp,
                        token: pushtoken,
                      );
                    }
                  } else {
                    Get.snackbar(
                      'Error',
                      'Please enter a complete 6-digit OTP',
                      snackPosition: SnackPosition.TOP,
                      backgroundColor: Colors.red,
                      colorText: Colors.white,
                    );
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
                  'Verify OTP',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            SizedBox(height: screenHeight * 0.02),
            Center(
              child: TextButton(
                onPressed:
                    _resendTimer > 0
                        ? null
                        : () {
                          // Add resend OTP logic here
                          setState(() {
                            _resendTimer = 59;
                            _startTimer();
                          });
                          final args = Get.arguments;
                          final mobile = args as String?;
                          // print('Entered OTP: $otp');
                          // print('Mobile: $mobile');
                          loginSendOtpControlller.sendOTP(
                            context: context,
                            mobileNumber: mobile,
                          );
                          
                          // Get.snackbar(
                          //   'Success',
                          //   'OTP resent to your phone',
                          //   snackPosition: SnackPosition.TOP,
                          //   backgroundColor: AppColors.success,
                          //   colorText: Colors.white,
                          // );
                        },
                child: Text(
                  _resendTimer > 0
                      ? 'Didn\'t Receive Code? Resend Code in 00:${_resendTimer.toString().padLeft(2, '0')}'
                      : 'Didn\'t Receive Code? Resend Code',
                  style: TextStyle(
                    color:
                        _resendTimer > 0 ? AppColors.grey : AppColors.primary,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
