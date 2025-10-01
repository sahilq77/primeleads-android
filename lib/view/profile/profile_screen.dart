import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:prime_leads/controller/bottomnavigation/bottom_navigation_controller.dart';
import 'package:prime_leads/controller/profile/delete_user_controller.dart';
import 'package:prime_leads/controller/profile/profile_controller.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:prime_leads/utility/app_routes.dart';
import 'package:prime_leads/utility/app_utility.dart';
import 'package:shimmer/shimmer.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../utility/nodatascreen.dart';
import '../bottomnavgation/bottom_navigation.dart';

class ProfileScreen extends StatelessWidget {
  final controller = Get.put(ProfileController());
  final bottomController = Get.put(BottomNavigationController());
  String greetings() {
    final hour = TimeOfDay.now().hour;

    if (hour <= 12) {
      return 'Good Morning';
    } else if (hour <= 17) {
      return 'Good Afternoon';
    }
    return 'Good Evening';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return WillPopScope(
      onWillPop: () async {
        print(
          'Main: WillPopScope triggered, current route: ${Get.currentRoute}, selectedIndex: ${bottomController.selectedIndex.value}',
        );
        if (Get.currentRoute != AppRoutes.home &&
            Get.currentRoute != AppRoutes.splash) {
          print('Main: Navigating to home');
          bottomController.selectedIndex.value = 0;
          Get.offAllNamed(AppRoutes.home);
          return false; // Prevent app exit
        }
        print('Main: On home or splash, allowing app exit');
        return true; // Allow app exit
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          title: Text(
            'Profile',
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
        body: RefreshIndicator(
          onRefresh: () => controller.onRefresh(context),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  SizedBox(height: screenHeight * 0.05),
                  Obx(() {
                    if (controller.isLoading.value &&
                        controller.userProfileList.isEmpty) {
                      return ProfileShimmer();
                    }

                    if (controller.userProfileList.isEmpty) {
                      return NoDataScreen();
                    }

                    final user = controller.userProfileList[0];
                    print("Building with cityId: ${user.city}");

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Center(
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              CircleAvatar(
                                radius: 60,
                                backgroundColor: Colors.grey[200],
                                child:
                                    user.profileImage == ""
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
                                                imageUrl:
                                                    "${controller.imageLink.value}${user.profileImage}",
                                                fit: BoxFit.cover,
                                                placeholder:
                                                    (
                                                      context,
                                                      url,
                                                    ) => const Center(
                                                      child:
                                                          CircularProgressIndicator(),
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
                            ],
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.02),
                        Center(
                          child: Text(
                            "Hi, ${user.fullName}",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                              color: AppColors.defaultblack,
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
                              color: AppColors.defaultblack,
                            ),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.03),
                        ListTile(
                          leading: SvgPicture.asset(
                            AppImages.userIcon,
                            color: AppColors.grey,
                            height: 25,
                            width: 25,
                          ),
                          title: Text('Update Profile'),
                          trailing: Icon(Icons.chevron_right, size: 30),
                          onTap: () {
                            controller.setSelectedUser(user);
                            Get.toNamed(AppRoutes.updateprofile);
                          },
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 16),
                          height: 1,
                          width: double.infinity,
                          color: Color(0xFFEDEDED),
                        ),
                        ListTile(
                          leading: SvgPicture.asset(
                            AppImages.crownIcon,
                            color: AppColors.grey.withOpacity(0.8),
                            height: 25,
                            width: 25,
                          ),
                          title: Text('Subscription Detail'),
                          trailing: Icon(Icons.chevron_right, size: 30),
                          onTap: () {
                            print("sub${user.subscriptionDetail!.packageName}");
                            if (user
                                .subscriptionDetail!
                                .packageName!
                                .isNotEmpty) {
                              Get.toNamed(
                                AppRoutes.subdetail,
                                arguments: user.subscriptionDetail,
                              );
                            }
                          },
                        ),
                      ],
                    );
                  }),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    width: double.infinity,
                    color: Color(0xFFEDEDED),
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      AppImages.notificatioIcon,
                      color: AppColors.grey,
                      height: 25,
                      width: 25,
                    ),
                    title: Text('Notifications'),
                    trailing: Icon(Icons.chevron_right, size: 30),
                    onTap: () {
                      Get.toNamed(AppRoutes.notification);
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    width: double.infinity,
                    color: Color(0xFFEDEDED),
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      AppImages.documentIcon,
                      color: AppColors.grey,
                      height: 25,
                      width: 25,
                    ),
                    title: Text('Terms of Use'),
                    trailing: Icon(Icons.chevron_right, size: 30),
                    onTap: () {
                      Get.toNamed(AppRoutes.terms);
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    width: double.infinity,
                    color: Color(0xFFEDEDED),
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      AppImages.questionIcon,
                      color: AppColors.grey,
                      height: 25,
                      width: 25,
                    ),
                    title: Text('Help & Support'),
                    onTap: () {
                      _launchWhatsApp(context, "7558442157", "");
                    },
                    trailing: Icon(Icons.chevron_right, size: 30),
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    width: double.infinity,
                    color: Color(0xFFEDEDED),
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      AppImages.billIcon,
                      color: AppColors.grey,
                      height: 25,
                      width: 25,
                    ),
                    title: Text('Billing & Payments'),
                    trailing: Icon(Icons.chevron_right, size: 30),
                    onTap: () {
                      Get.toNamed(AppRoutes.bill);
                    },
                  ),
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 16),
                    height: 1,
                    width: double.infinity,
                    color: Color(0xFFEDEDED),
                  ),
                  ListTile(
                    leading: SvgPicture.asset(
                      AppImages.logoutIcon,
                      height: 25,
                      width: 25,
                    ),
                    title: Text('Logout', style: TextStyle(color: Colors.teal)),
                    trailing: Icon(Icons.chevron_right, size: 30),
                    onTap: () {
                      _logoutDialog(context, controller);
                    },
                  ),
                  GestureDetector(
                    onTap: () {
                      _deleteAccountDialog(context);
                    },
                    child: Container(
                      margin: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.25,
                        vertical: screenHeight * 0.02,
                      ),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.black),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.delete_outline,
                            color: Colors.black,
                            size: 15,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'Delete Your Account',
                            style: TextStyle(color: Colors.black, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: CustomBottomBar(),
      ),
    );
  }

  _logoutDialog(BuildContext context, ProfileController controller) {
    return showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  backgroundColor: Color(0xFFF8F8F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryTeal,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Center(
                                child: SvgPicture.asset(
                                  AppImages.logoutIcon,
                                  color: Colors.white,
                                  height: 40,
                                  width: 40,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Come back soon!',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Logging out will end your session.',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Do you wish to proceed?',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF7A7773),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Get.back();
                                    controller.logout();
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryTeal,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Logout',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }

  _deleteAccountDialog(BuildContext context) {
    return showDialog(
      context: context,
      builder:
          (ctx) => StatefulBuilder(
            builder:
                (context, setState) => Dialog(
                  backgroundColor: Color(0xFFF8F8F8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10.0),
                  ),
                  child: Container(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          CircleAvatar(
                            radius: 40,
                            backgroundColor: Colors.transparent,
                            child: Container(
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: LinearGradient(
                                  colors: [
                                    AppColors.primary,
                                    AppColors.primaryTeal,
                                  ],
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                ),
                              ),
                              child: Center(
                                child: Icon(
                                  Icons.delete_outline,
                                  color: Colors.white,
                                  size: 40,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Delete Account',
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),
                          Text(
                            'This will permanently delete your account.',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          Text(
                            'Are you sure you want to proceed?',
                            style: TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          ),
                          SizedBox(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Navigator.of(context).pop();
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      border: Border.all(color: Colors.grey),
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Cancel',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: const Color(0xFF7A7773),
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: GestureDetector(
                                  onTap: () {
                                    Get.back();
                                    final deleteController = Get.put(
                                      DeleteUserController(),
                                    );
                                    deleteController
                                        .delteUser(context: context)
                                        .then((value) {
                                          AppUtility.clearUserInfo().then((_) {
                                            Get.offAllNamed(AppRoutes.login);
                                          });
                                        })
                                        .catchError((error) {
                                          ScaffoldMessenger.of(
                                            context,
                                          ).showSnackBar(
                                            SnackBar(
                                              content: Text(
                                                'Error deleting user: $error',
                                              ),
                                            ),
                                          );
                                        });
                                  },
                                  child: Container(
                                    height: 50,
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 8,
                                    ),
                                    decoration: BoxDecoration(
                                      color: AppColors.primaryTeal,
                                      borderRadius: BorderRadius.circular(5),
                                    ),
                                    child: Center(
                                      child: Text(
                                        'Delete',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: Colors.white,
                                          fontSize: 16,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
          ),
    );
  }
}

Future<void> _launchWhatsApp(
  BuildContext context,
  String phoneNumber,
  String message,
) async {
  if (!phoneNumber.startsWith('+')) {
    phoneNumber = '+$phoneNumber';
  }
  phoneNumber = phoneNumber.replaceAll(RegExp(r'[^0-9+]'), '');
  final String encodedMessage = Uri.encodeComponent(message);
  final String whatsappUrl = 'https://wa.me/$phoneNumber?text=$encodedMessage';
  final Uri uri = Uri.parse(whatsappUrl);

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'WhatsApp is not installed or the phone number is invalid',
          ),
        ),
      );
    }
  } catch (e) {
    debugPrint('Error launching WhatsApp: $e');
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Could not open WhatsApp')));
  }
}

class ProfileShimmer extends StatelessWidget {
  const ProfileShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Column(
      children: [
        Center(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: CircleAvatar(radius: 50, backgroundColor: Colors.grey[300]),
          ),
        ),
        SizedBox(height: screenHeight * 0.02),
        Center(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(width: 120, height: 20, color: Colors.grey),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Shimmer.fromColors(
            baseColor: Colors.grey[300]!,
            highlightColor: Colors.grey[100]!,
            child: Container(width: 100, height: 16, color: Colors.grey),
          ),
        ),
      ],
    );
  }
}
