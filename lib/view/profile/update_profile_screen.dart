import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:prime_leads/controller/bottomnavigation/bottom_navigation_controller.dart';
import 'package:prime_leads/model/profile/get_profile_response.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:shimmer/shimmer.dart';
import '../../controller/global_controller.dart/city_controller.dart';
import '../../controller/global_controller.dart/state_controller.dart';
import '../../controller/profile/profile_controller.dart';
import '../../controller/profile/update_profile_controller.dart';
import '../../utility/app_colors.dart';

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({super.key});

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  final bottomController = Get.put(BottomNavigationController());
  final controller = Get.put(UpadteProfileController());
  final stateController = Get.put(StateController());
  final cityController = Get.put(CityController());
  final nameController = TextEditingController();
  final sectorController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  String fullname = "";
  String profileImage = "";
  String? selectedGender;
  String? selectedState;
  String? selectedCity;
  ProfileData profile = ProfileData(
    id: "",
    fullName: "",
    profileImage: "",
    mobileNumber: "",
    state: "",
    city: "",
    sectorId: "",
    sectorName: "",
    subscriptionId: "",
    subscriptionDetail: SubscriptionDetail(
      packageName: "",
      noOfLeads: "",
      validityDays: "",
      tags: "",
      bulletPoints: [],
    ),
  );

  String greetings() {
    final hour = TimeOfDay.now().hour;

    if (hour <= 12) {
      return 'Good Morning';
    } else if (hour <= 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  Future<void> _loadMaintenanceData() async {
    try {
      final ProfileController jobworkController = Get.find<ProfileController>();
      profile = jobworkController.selectedUser.value!;

      if (profile != null) {
        print('--- Jobwork Data ---');
        print('ID: ${profile!.id}');
        print('Name: ${profile!.fullName}');
        print('City: ${profile!.city}');
        print('-----------------------');

        setState(() {
          profileImage = nameController.text = profile!.profileImage!;
          nameController.text = profile!.fullName!;
          fullname = profile!.fullName!;
          sectorController.text = profile!.sectorName!;
          final stateId = profile!.state;
          final cityId = profile!.city;
          selectedState = stateId;
          selectedCity = cityId;
          print(cityId);
          print("Initializing with stateId: $stateId, cityId: $cityId");
          stateController.fetchStates(context: context).then((_) {
            stateController.getStateNameById(profile!.state!);
            print(
              "State name for stateId $stateId: ${stateController.getStateNameById(stateId!)}",
            );
          });
          cityController
              .fetchCities(context: context, forceFetch: true, stateID: stateId!)
              .then((_) {
                final cityName = cityController.getCityNameById(cityId!);
                print("City name for cityId $cityId: $cityName");
                print(
                  "City list: ${cityController.cityList.map((c) => '${c.id}: ${c.name}').toList()}",
                );
              });
        });
      } else {
        print('No Maintenance data found in MaintenanceController');
      }
    } catch (e) {
      print('Error loading Maintenance data: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading maintenance data: $e')),
      );
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadMaintenanceData();
    });
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        Get.back();
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Update Profile',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: PreferredSize(
            preferredSize: Size.fromHeight(10),
            child: Divider(
              color: const Color(0xFFDADADA),
              thickness: 2,
              height: 0,
            ),
          ),
        ),
        body: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(
              horizontal: 16.0,
              vertical: 10.0,
            ),
            child: Column(
              children: [
                SizedBox(height: screenHeight * 0.05),
                Center(
                  child: Stack(
                    alignment: Alignment.bottomRight,
                    children: [
                      Obx(
                        () => CircleAvatar(
                          radius: 60,
                          backgroundColor: Colors.grey[200],
                          child:
                              controller.imagePath.value.isNotEmpty
                                  ? AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: Image.file(
                                          File(controller.imagePath.value!),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    ),
                                  )
                                  : (profile == "" ||
                                      profile!.profileImage == "")
                                  ? ClipOval(
                                    child: Image.asset(
                                      AppImages.profile,
                                      fit: BoxFit.cover,
                                    ),
                                  )
                                  : AspectRatio(
                                    aspectRatio: 1,
                                    child: Container(
                                      decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                      ),
                                      child: ClipOval(
                                        child: CachedNetworkImage(
                                          imageUrl: profile.profileImage!,
                                          fit: BoxFit.cover,
                                          placeholder:
                                              (context, url) =>
                                                  Shimmer.fromColors(
                                                    baseColor:
                                                        Colors.grey[300]!,
                                                    highlightColor:
                                                        Colors.grey[100]!,
                                                    child: Container(
                                                      color: Colors.white,
                                                    ),
                                                  ),
                                          errorWidget:
                                              (context, url, error) =>
                                                  const Icon(
                                                    Icons.error,
                                                    size: 50,
                                                  ),
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                      ),
                      GestureDetector(
                        onTap:
                            () => showEditProfileImageBottomSheet(
                              context,
                              controller,
                            ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: const Color(0xFFE5E7EB),
                            shape: BoxShape.circle,
                            border: Border.all(color: Colors.white, width: 2),
                          ),
                          padding: const EdgeInsets.all(5),
                          child: ClipOval(
                            child: SvgPicture.asset(
                              AppImages.editIcon,
                              width: 15,
                              height: 15,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    "Hi, ${fullname}",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textDark,
                    ),
                  ),
                ),
                const SizedBox(height: 4),
                Center(
                  child: Text(
                    greetings(),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w400,
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
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
                      if (selectedState == null) {
                        return 'Please select a state';
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
                              isFilterOnline: true,
                              loadingBuilder:
                                  (context, _) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 50,
                                      color: Colors.white,
                                    ),
                                  ),
                              searchFieldProps: TextFieldProps(
                                decoration: InputDecoration(
                                  labelText: 'Search State',
                                  labelStyle: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w400,
                                    color: AppColors.textDark,
                                  ),
                                  border: const OutlineInputBorder(),
                                  prefixIcon: const Icon(Icons.search),
                                ),
                              ),
                              emptyBuilder:
                                  (context, _) => const Center(
                                    child: Text('No states found'),
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
                                if (stateId != null && stateId.isNotEmpty) {
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
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorText: formFieldState.errorText,
                              ),
                            ),
                            selectedItem: stateController.getStateNameById(
                              profile!.state!,
                            ),
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
                    return Container(
                      padding: const EdgeInsets.symmetric(vertical: 10),
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
                      if (selectedCity == null) {
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
                              isFilterOnline: true,
                              loadingBuilder:
                                  (context, _) => Shimmer.fromColors(
                                    baseColor: Colors.grey[300]!,
                                    highlightColor: Colors.grey[100]!,
                                    child: Container(
                                      height: 50,
                                      color: Colors.white,
                                    ),
                                  ),
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
                                    borderSide: const BorderSide(
                                      color: Color(0xFFD0D0D0),
                                    ),
                                  ),
                                  prefixIcon: const Icon(Icons.search),
                                ),
                              ),
                              emptyBuilder:
                                  (context, _) => const Center(
                                    child: Text('No cities found'),
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
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedErrorBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: Colors.red,
                                    width: 2,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                errorText: formFieldState.errorText,
                              ),
                            ),
                            selectedItem: cityController.getCityNameById(
                              profile!.city!,
                            ),
                            enabled:
                                selectedState != null &&
                                selectedState!.isNotEmpty,
                          ),
                        ],
                      );
                    },
                  );
                }),
                SizedBox(height: screenHeight * 0.02),
                TextFormField(
                  readOnly: true,
                  style: TextStyle(color: Colors.grey.shade600),
                  cursorColor: AppColors.primary,
                  controller: sectorController,
                  decoration: InputDecoration(
                    labelText: 'Sector Name',
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
                    LengthLimitingTextInputFormatter(10),
                  ],
                ),
                SizedBox(height: screenHeight * 0.02),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _formKey.currentState!.save();
                      print(selectedCity);
                      controller.updateProfile(
                        fullName: nameController.text.toString(),
                        state: selectedState,
                        city: selectedCity,
                      );
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryTeal,
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(5),
                    ),
                  ),
                  child: const Text(
                    "Save",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
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

  void showEditProfileImageBottomSheet(
    BuildContext context,
    UpadteProfileController controller,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter modalSetState) {
            return Stack(
              children: [
                Padding(
                  padding: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom,
                    left: 24,
                    right: 24,
                    top: 16,
                  ),
                  child: Wrap(
                    children: [
                      Center(
                        child: Column(
                          children: [
                            const Icon(
                              Icons.photo,
                              size: 40,
                              color: AppColors.primaryTeal,
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Edit Profile Photo',
                              style: const TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF36322E),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              'Choose a method to update your photo',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 25),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        controller.pickImage(
                                          ImageSource.camera,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: AppColors.primaryTeal
                                            .withOpacity(0.1),
                                        child: Icon(
                                          Icons.camera_alt,
                                          size: 28,
                                          color: AppColors.primaryTeal,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Camera',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryTeal,
                                      ),
                                    ),
                                  ],
                                ),
                                Column(
                                  children: [
                                    InkWell(
                                      onTap: () {
                                        controller.pickImage(
                                          ImageSource.gallery,
                                        );
                                        Navigator.pop(context);
                                      },
                                      child: CircleAvatar(
                                        radius: 30,
                                        backgroundColor: AppColors.primaryTeal
                                            .withOpacity(0.1),
                                        child: Icon(
                                          Icons.photo_library,
                                          size: 28,
                                          color: AppColors.primaryTeal,
                                        ),
                                      ),
                                    ),
                                    const SizedBox(height: 8),
                                    Text(
                                      'Gallery',
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: AppColors.primaryTeal,
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            TextButton(
                              onPressed: () => Navigator.pop(context),
                              child: Text(
                                'Cancel',
                                style: const TextStyle(
                                  fontSize: 14,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
