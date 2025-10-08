import 'dart:async';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:pinput/pinput.dart';
import 'package:prime_leads/controller/login/login_controller.dart';
import 'package:prime_leads/controller/register/register_otp/register_send_otp_controller.dart';
import 'package:prime_leads/controller/register/register_otp/register_verify_otp_controller.dart';
import '../../controller/login/login_send_otp_controller.dart';
import '../../notification_services .dart';
import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';

class RegisterOtpScreen extends StatefulWidget {
  @override
  _RegisterOtpScreenState createState() => _RegisterOtpScreenState();
}

class _RegisterOtpScreenState extends State<RegisterOtpScreen> {
  final loginControlller = Get.put(LoginController());
  final registerSendOtpControlller = Get.put(RegisterSendOtpController());
  final registerVerifyOtpControlller = Get.put(RegisterVerifyOtpController());
  final TextEditingController _otpController = TextEditingController();
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
    _otpController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    // Define Pinput theme
    final defaultPinTheme = PinTheme(
      width: 50,
      height: 50,
      textStyle: GoogleFonts.poppins(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: AppColors.textDark,
      ),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final focusedPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.primary, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );

    final errorPinTheme = defaultPinTheme.copyWith(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red, width: 2),
        borderRadius: BorderRadius.circular(10),
      ),
    );

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
            Pinput(
              controller: _otpController,
              length: 6,
              defaultPinTheme: defaultPinTheme,
              focusedPinTheme: focusedPinTheme,
              errorPinTheme: errorPinTheme,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              onChanged: (value) {
                // Optional: Handle onChanged if needed
              },
              // onCompleted: (pin) {
              //   if (pin.length == 6) {
              //     final args = Get.arguments as Map<String, dynamic>?;
              //     final mobile = args?['mobile'] as String?;
              //     registerVerifyOtpControlller.verifyOTP(
              //       context: context,
              //       mobileNumber: mobile,
              //       otp: pin,
              //     );
              //   }
              // },
              isCursorAnimationEnabled: true,
              showCursor: true,
              // onClipboardFound: (value) {
              //   if (value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value)) {
              //     _otpController.text = value;
              //   } else {
              //     Get.snackbar(
              //       'Error',
              //       'Please paste a valid 6-digit OTP',
              //       snackPosition: SnackPosition.TOP,
              //       backgroundColor: Colors.red,
              //       colorText: Colors.white,
              //     );
              //   }
              // },
            ),
            SizedBox(height: screenHeight * 0.04),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  String otp = _otpController.text;
                  if (otp.length == 6) {
                    final args = Get.arguments as Map<String, dynamic>?;
                    final mobile = args?['mobile'] as String?;
                    registerVerifyOtpControlller.verifyOTP(
                      context: context,
                      mobileNumber: mobile,
                      otp: otp,
                    );
                    // Get.toNamed(
                    //   AppRoutes.category,
                    //   arguments: {
                    //     "name": name,
                    //     "state": state,
                    //     "city": city,
                    //     "mobile": mobile,
                    //   },
                    // );
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
                          setState(() {
                            _resendTimer = 59;
                            _startTimer();
                          });
                          final loginSendOtpControlller = Get.put(
                            LoginSendOtpController(),
                          );
                          final args = Get.arguments;
                          final mobile = args;
                          loginSendOtpControlller.sendOTP(
                            context: context,
                            mobileNumber: args['mobile'],
                            argu: args,
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
