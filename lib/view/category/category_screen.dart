import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:prime_leads/controller/category/category_controller.dart';
import 'package:prime_leads/controller/register/register_controller.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:shimmer/shimmer.dart';
import '../../notification_services .dart';
import '../../utility/app_routes.dart';

class CategorySelectionScreen extends StatefulWidget {
  @override
  State<CategorySelectionScreen> createState() =>
      _CategorySelectionScreenState();
}

class _CategorySelectionScreenState extends State<CategorySelectionScreen> {
  String? selectedCategory;
  final categoryController = Get.put(CategoryController());
  final controller = Get.put(RegisterController());
  String? pushtoken;
  NotificationServices notificationServices = NotificationServices();
  @override
  void initState() {
    // TODO: implement initState
    super.initState();

    notificationServices.firebaseInit(context);
    notificationServices.setInteractMessage(context);
    notificationServices.getDevicetoken().then((value) {
      log('Device Token ${value}');
      pushtoken = value;
    });

    // Future.delayed(Duration(seconds: 3), () {
    //   Get.offNamed(AppRoutes.welcome);
    // });
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Choose What Matters To You'),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black,
      ),
      body: RefreshIndicator(
        onRefresh: () => categoryController.onRefresh(context),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Obx(() {
            if (categoryController.isLoading.value) {
              return GridView.builder(
                itemCount: 6, // Show 4 shimmer placeholders
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1,
                ),
                itemBuilder: (context, index) {
                  return Shimmer.fromColors(
                    baseColor: Colors.grey[300]!,
                    highlightColor: Colors.grey[100]!,
                    child: Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: Colors.grey.shade300,
                          width: 2,
                        ),
                        borderRadius: BorderRadius.circular(12),
                        color: Colors.white,
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: screenHeight * 0.05,
                            width: 48,
                            color: Colors.grey,
                          ),
                          const SizedBox(height: 10),
                          Container(width: 80, height: 16, color: Colors.grey),
                        ],
                      ),
                    ),
                  );
                },
              );
            }

            final categories = categoryController.categoryList.value;
            if (categories.isEmpty) {
              return const Center(child: Text("No categories found"));
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Please select category',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 20),
                Expanded(
                  child: GridView.builder(
                    itemCount: categories.length,
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 14,
                          mainAxisSpacing: 14,
                          childAspectRatio: 1,
                        ),
                    itemBuilder: (context, index) {
                      final item = categories[index];
                      final isSelected = selectedCategory == item.id;

                      return GestureDetector(
                        onTap: () {
                          setState(() => selectedCategory = item.id);
                          print("Categ $selectedCategory");
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            border: Border.all(
                              color:
                                  isSelected
                                      ? AppColors.primaryTeal
                                      : Colors.grey.shade300,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              // SizedBox(
                              //   height: screenHeight * 0.05,
                              //   width: 48,
                              //   child: Image.asset(
                              //     AppImages.healthcareCateg,
                              //     color:
                              //         isSelected
                              //             ? AppColors.primaryTeal
                              //             : Colors.grey,
                              //   ),
                              // ),
                              CachedNetworkImage(
                                imageUrl: item.icon,
                                fit: BoxFit.cover,
                                width: 30,
                                height: 30,
                                color:
                                    isSelected
                                        ? AppColors.primaryTeal
                                        : Colors.grey,
                                placeholder:
                                    (context, url) => const Center(
                                      child: CircularProgressIndicator(),
                                    ),
                                errorWidget:
                                    (context, url, error) => const Center(
                                      child: Icon(
                                        Icons.error,
                                        color: AppColors.error,
                                        size: 20,
                                      ),
                                    ),
                              ),
                              const SizedBox(height: 10),
                              Text(
                                item.sectorName,
                                style: TextStyle(
                                  fontSize: 16,
                                  color:
                                      isSelected
                                          ? AppColors.primaryTeal
                                          : Colors.grey,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      if (selectedCategory == null) {
                        Get.snackbar(
                          "Alert",
                          "Please select a category",
                          backgroundColor: Colors.red.shade100,
                        );
                      } else {
                        final args = Get.arguments;
                        final name = args['name'] as String?;
                        final state = args['state'] as String?;
                        final city = args['city'] as String?;
                        final mobile = args['mobile'] as String?;
                        print('Name: $name');
                        print('State: $state');
                        print('City: $city');

                        print('Mobile: $mobile');
                        print("Selected: $selectedCategory");
                        controller.register(
                          mobileNumber: mobile,
                          name: name,
                          state: state,
                          city: city,
                          sectorid: selectedCategory,
                          token: pushtoken,
                        );
                        // Get.toNamed(AppRoutes.home);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryTeal,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Submit',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
            );
          }),
        ),
      ),
    );
  }
}
