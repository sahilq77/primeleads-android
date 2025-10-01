import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:prime_leads/controller/global_controller.dart/city_controller.dart';
import 'package:prime_leads/controller/global_controller.dart/state_controller.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/check_mobile/check_mobile_controller.dart';
import '../../controller/register/register_otp/register_send_otp_controller.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';
import '../../utility/app_routes.dart';

class RegisterScreen extends StatefulWidget {
  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final stateController = Get.put(StateController());
  final cityController = Get.put(CityController());
  final nameController = TextEditingController();
  final mobileController = TextEditingController();
  //  final sendOtpControlller = Get.put(SendOtpController());
  final _formKey = GlobalKey<FormState>();
  String? selectedState;
  String? selectedCity;
  bool _agreeToVerify = false;

  @override
  void dispose() {
    nameController.dispose();
    mobileController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    if (Get.arguments is Map) {
      mobileController.text = Get.arguments['mobile'] ?? '';
    } else {
      mobileController.text = Get.arguments as String? ?? '';
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: SingleChildScrollView(
          child: Form(
            key: _formKey,
            autovalidateMode: AutovalidateMode.onUnfocus,
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
                    'Register To Begin',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.04),
                TextFormField(
                  cursorColor: AppColors.primary,
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Name',
                    labelStyle: TextStyle(color: AppColors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.textfieldBorderColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedErrorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red, width: 2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),

                  inputFormatters: [
                    FilteringTextInputFormatter.deny(RegExp(r'^\s')),
                  ],
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your name';
                    }
                    if (value.length < 2) {
                      return 'Name must be at least 2 characters long';
                    }
                    return null;
                  },
                  onSaved: (value) => nameController.text = value!.trim(),
                ),
                SizedBox(height: screenHeight * 0.02),
                Obx(() {
                  if (stateController.isLoading.value) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.textfieldBorderColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (stateController.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            stateController.errorMessage.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed:
                                () => stateController.fetchStates(
                                  context: context,
                                  forceFetch: true,
                                ),
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return FormField<String>(
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          stateController.getStateId(value) == '') {
                        return 'Please select a state';
                      }
                      return null;
                    },
                    builder: (FormFieldState<String> formFieldState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownSearch<String>(
                            popupProps: const PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  labelText: 'Search State',
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textDark,
                                  ),
                                  border: OutlineInputBorder(),
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            items: stateController.getStateNames(),
                            onChanged: (String? newValue) async {
                              formFieldState.didChange(newValue);
                              if (newValue != null) {
                                final stateId = stateController.getStateId(
                                  newValue,
                                );
                                setState(() {
                                  selectedState = stateId;
                                  selectedCity = null;
                                  cityController.cityList.clear();
                                });
                                if (stateId!.isNotEmpty) {
                                  await cityController.fetchCities(
                                    context: context,
                                    forceFetch: true,
                                    stateID: stateId,
                                  );
                                }
                              }
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: 'Select State',
                                labelStyle: TextStyle(color: AppColors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.textfieldBorderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorText: formFieldState.errorText,
                              ),
                            ),
                            selectedItem: formFieldState.value,
                          ),
                        ],
                      );
                    },
                  );
                }),
                SizedBox(height: screenHeight * 0.02),
                Obx(() {
                  if (cityController.isLoading.value) {
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Shimmer.fromColors(
                        baseColor: Colors.grey[300]!,
                        highlightColor: Colors.grey[100]!,
                        child: Container(
                          height: 50,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: AppColors.textfieldBorderColor,
                            ),
                          ),
                        ),
                      ),
                    );
                  }
                  if (cityController.errorMessage.value.isNotEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            cityController.errorMessage.value,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              if (selectedState != null &&
                                  selectedState!.isNotEmpty) {
                                cityController.fetchCities(
                                  context: context,
                                  forceFetch: true,
                                  stateID: selectedState!,
                                );
                              } else {
                                Get.snackbar(
                                  'Error',
                                  'Please select a state first',
                                  backgroundColor: Colors.red,
                                  colorText: Colors.white,
                                );
                              }
                            },
                            child: const Text('Retry'),
                          ),
                        ],
                      ),
                    );
                  }
                  return FormField<String>(
                    validator: (value) {
                      if (value == null ||
                          value.isEmpty ||
                          cityController.getCityId(value) == '') {
                        return 'Please select a city';
                      }
                      return null;
                    },
                    builder: (FormFieldState<String> formFieldState) {
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          DropdownSearch<String>(
                            popupProps: PopupProps.menu(
                              showSearchBox: true,
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  labelText: 'Search City',
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textDark,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(5),
                                    borderSide: BorderSide(
                                      color: Color(0xFFD0D0D0),
                                    ),
                                  ),
                                  prefixIcon: Icon(Icons.search),
                                ),
                              ),
                            ),
                            items: cityController.getCityNames(),
                            onChanged: (String? newValue) {
                              formFieldState.didChange(newValue);
                              if (newValue != null) {
                                final cityId = cityController.getCityId(
                                  newValue,
                                );
                                setState(() {
                                  selectedCity = cityId;
                                });
                              }
                            },
                            dropdownDecoratorProps: DropDownDecoratorProps(
                              dropdownSearchDecoration: InputDecoration(
                                labelText: 'Select City',
                                labelStyle: TextStyle(color: AppColors.grey),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.textfieldBorderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: AppColors.primary,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.red),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorText: formFieldState.errorText,
                              ),
                            ),
                            selectedItem: formFieldState.value,
                          ),
                        ],
                      );
                    },
                  );
                }),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  cursorColor: AppColors.primary,
                  controller: mobileController,
                  decoration: InputDecoration(
                    labelText: 'Mobile Number',
                    labelStyle: TextStyle(color: AppColors.grey),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.textfieldBorderColor,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(
                        color: AppColors.primary,
                        width: 2,
                      ),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    errorBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.red),
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
                  onSaved: (value) => mobileController.text = value!.trim(),
                ),
                SizedBox(height: screenHeight * 0.02),
                Row(
                  children: [
                    Checkbox(
                      value: _agreeToVerify,
                      onChanged: (value) {
                        setState(() => _agreeToVerify = value!);
                      },
                      activeColor: AppColors.primary,
                    ),
                    Expanded(
                      child: Text(
                        'A 6-digit code will be sent via SMS to verify your number.',
                        style: TextStyle(color: AppColors.grey, fontSize: 14),
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
                        if (!_agreeToVerify) {
                          Get.snackbar(
                            'Error',
                            'Please agree to receive the verification code via SMS',
                            backgroundColor: Colors.red,
                            colorText: Colors.white,
                          );
                          return;
                        }
                        _formKey.currentState!.save();

                        checkmobileController.checkRegisterMobile(
                          context: context,

                          argu: {
                            "name": nameController.text.toString(),
                            "state": selectedState,
                            "city": selectedCity,
                            "mobile": mobileController.text.toString(),
                            "fromRegistration": true,
                          },
                          mobileNumber: mobileController.text.toString(),
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
                      'Get OTP',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
