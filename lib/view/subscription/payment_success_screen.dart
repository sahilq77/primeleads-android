import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:prime_leads/utility/app_colors.dart';
import 'package:prime_leads/controller/profile/profile_controller.dart';
import 'package:prime_leads/utility/app_routes.dart';

import '../../controller/subscription/set_payment_controller.dart';

class PaymentReceiptDetailsScreen extends StatefulWidget {
  const PaymentReceiptDetailsScreen({super.key});

  @override
  State<PaymentReceiptDetailsScreen> createState() =>
      _PaymentReceiptDetailsScreenState();
}

class _PaymentReceiptDetailsScreenState
    extends State<PaymentReceiptDetailsScreen> {
  final ProfileController profileController = Get.put(ProfileController());
  final SetPaymentController _setPaymentController = Get.put(
    SetPaymentController(),
  );
  String? transactionId;
  String? subscriptionId;
  num? amount;

  @override
  void initState() {
    super.initState();
    debugPrint('[PaymentReceiptDetailsScreen] Initializing');
    debugPrint('[PaymentReceiptDetailsScreen] Get.arguments: ${Get.arguments}');

    // Extract arguments
    final args = Get.arguments;
    if (args != null) {
      transactionId = args['transactionId'] as String?;
      subscriptionId = args['subscriptionId'] as String?;
      amount = args['amount'] as num?;
      debugPrint('[PaymentReceiptDetailsScreen] transactionId: $transactionId');
      debugPrint(
        '[PaymentReceiptDetailsScreen] subscriptionId: $subscriptionId',
      );
      debugPrint('[PaymentReceiptDetailsScreen] amount: $amount');
    } else {
      debugPrint('[PaymentReceiptDetailsScreen] Error: Get.arguments is null');
    }

    // Fetch user profile
    WidgetsBinding.instance.addPostFrameCallback((_) {
      profileController.fetchUserProfile(context: context);
    });
  }

  String getName() {
    if (profileController.isLoading.value ||
        profileController.userProfileList.isEmpty) {
      debugPrint(
        '[PaymentReceiptDetailsScreen] getName: Returning empty string (loading or no profile)',
      );
      return "";
    }
    final user = profileController.userProfileList[0];
    debugPrint('[PaymentReceiptDetailsScreen] getName: ${user.fullName}');
    profileController.update();
    return user.fullName!;
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        debugPrint(
          '[PaymentReceiptDetailsScreen] Back button pressed - disabled',
        );
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: AppColors.background,
          elevation: 0,
          centerTitle: false,
          title: const Text(
            'Payment Details',
            style: TextStyle(
              color: AppColors.textDark,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          bottom: const PreferredSize(
            preferredSize: Size.fromHeight(10),
            child: Divider(color: Color(0xFFDADADA), thickness: 2, height: 0),
          ),
        ),
        body: Obx(
          () =>
              profileController.isLoading.value
                  ? const Center(child: CircularProgressIndicator())
                  : Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(15.0),
                            border: Border.all(
                              color: const Color(0xFFE6DFDC),
                              width: 1.0,
                            ),
                            color: AppColors.white,
                            boxShadow: const [
                              BoxShadow(
                                color: Color(0x1FAAAAAA),
                                offset: Offset(0, 8),
                                blurRadius: 24,
                                spreadRadius: 0,
                              ),
                            ],
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  height: 100,
                                  width: 100,
                                  child: ClipOval(
                                    child: SvgPicture.asset(
                                      AppImages.paymentSucces,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                const Text(
                                  'Payment Success!!',
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w500,
                                    color: Color(0xFF474747),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  amount != null ? "₹$amount" : "₹0",
                                  style: const TextStyle(
                                    fontSize: 24,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black87,
                                  ),
                                ),
                                const Divider(
                                  color: Color(0xFFEDEDED),
                                  thickness: 1,
                                  height: 20,
                                ),
                                _buildDetailRow(
                                  'Transaction Id',
                                  transactionId ?? "",
                                ),
                                const SizedBox(height: 12),
                                Obx(() => _buildDetailRow('Name', getName())),
                                const SizedBox(height: 12),
                                _buildDetailRow(
                                  'Date',
                                  DateFormat(
                                    'dd-MM-yyyy',
                                  ).format(DateTime.now()),
                                ),
                                const SizedBox(height: 12),
                                _buildDetailRow(
                                  'Pay Status',
                                  "Completed",
                                  isStatus: true,
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: Text(
                                        'Amount',
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w400,
                                          color: const Color(0xFF707070),
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      child: Text(
                                        amount != null ? "₹$amount" : "₹0",
                                        style: TextStyle(
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                          color: AppColors.grey,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                        textAlign: TextAlign.end,
                                      ),
                                    ),
                                  ],
                                ),
                                const Divider(
                                  color: Color(0xFFEDEDED),
                                  thickness: 1,
                                  height: 20,
                                ),
                                SizedBox(
                                  width: double.infinity,
                                  height: 50,
                                  child: ElevatedButton(
                                    onPressed: () async {
                                      //    print(_setPaymentController.subUId.value);
                                      // debugPrint(
                                      //   '[PaymentReceiptDetailsScreen] Download button pressed',
                                      // );

                                      // // Validate arguments
                                      if (subscriptionId == null ||
                                          transactionId == null) {
                                        debugPrint(
                                          '[PaymentReceiptDetailsScreen] Error: Missing subscriptionId or transactionId',
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                              'Error: Invalid payment details',
                                            ),
                                          ),
                                        );
                                        return;
                                      }

                                      debugPrint(
                                        '[PaymentReceiptDetailsScreen] Navigating to select_location with subscriptionId: $subscriptionId, transactionId: $transactionId',
                                      );

                                      // Navigate to LocationSelectionScreen
                                      await Get.toNamed(
                                        AppRoutes.selectLocation,
                                        arguments: {
                                          "subscribed_user_id":
                                              profileController
                                                  .userProfileList
                                                  .first
                                                  .subscribedUserId,
                                          'subscription_id': subscriptionId,
                                          'transaction': transactionId,
                                        },
                                      );
                                    },
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          'Go to City Selection',
                                          style: TextStyle(
                                            fontWeight: FontWeight.bold,
                                            color: AppColors.white,
                                          ),
                                        ),
                                        SizedBox(width: 5),
                                        Icon(
                                          Icons.arrow_forward,
                                          size: 20,
                                          color: AppColors.white,
                                        ),
                                      ],
                                    ),
                                    style: ElevatedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      backgroundColor: AppColors.primaryTeal,
                                      // side: const BorderSide(
                                      //   color: Color(0xFFE5E7EB),
                                      // ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 24,
                                        vertical: 12,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      elevation: 0,
                                    ),
                                  ),
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
    );
  }

  Widget _buildDetailRow(
    String label,
    String value, {
    bool isStatus = false,
    bool isExam = false,
  }) {
    Color getStatusColor(String status) {
      if (status.toLowerCase() == 'completed') {
        return Colors.green;
      } else if (status.toLowerCase() == 'pending') {
        return Colors.red;
      } else {
        return AppColors.grey;
      }
    }

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: isExam ? 14 : 13,
            fontWeight: isExam ? FontWeight.bold : FontWeight.w400,
            color: isExam ? Colors.black87 : const Color(0xFF707070),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: isExam ? 14 : 13,
            fontWeight: FontWeight.bold,
            color: isStatus ? getStatusColor(value) : Colors.grey.shade700,
          ),
        ),
      ],
    );
  }
}
