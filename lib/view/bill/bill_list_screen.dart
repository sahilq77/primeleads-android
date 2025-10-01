import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:prime_leads/utility/app_routes.dart';
import 'package:shimmer/shimmer.dart';

import '../../controller/notification/notification_controller.dart';
import '../../controller/payment_list/payment_list_controller.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_images.dart';
import '../../utility/nodatascreen.dart';

class BillListScreen extends StatefulWidget {
  const BillListScreen({super.key});

  @override
  State<BillListScreen> createState() => _BillListScreenState();
}

class _BillListScreenState extends State<BillListScreen> {
  final TextEditingController _dateController = TextEditingController();
  DateTime _selectedDate = DateTime.now(); // Use today's date
  final controller = Get.put(PaymentListController());
  final ScrollController scrollController = ScrollController();
  Future<void> _selectDate(BuildContext context, StateSetter setState) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(), // Restrict future dates
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _dateController.text =
            "${_selectedDate.day}/${_selectedDate.month}/${_selectedDate.year}";
        print('Filter date updated: ${_dateController.text}'); // Debug print
      });
    }
  }

  String? selectedStatus;
  @override
  Widget build(BuildContext context) {
    scrollController.addListener(() {
      if (scrollController.position.pixels >=
              scrollController.position.maxScrollExtent - 200 &&
          !controller.isLoadingMore.value &&
          controller.hasMoreData.value) {
        controller.loadMoreResults(context: context);
      }
    });
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        // foregroundColor: AppColors.background,
        centerTitle: false,
        title: const Text(
          'Bill & Payments',
          style: TextStyle(
            color: AppColors.textDark,
            fontSize: 18,
            // fontWeight: FontWeight.bold,
          ),
        ),
        bottom: const PreferredSize(
          preferredSize: Size.fromHeight(10),
          child: Divider(color: Color(0xFFDADADA), thickness: 2, height: 0),
        ),
        actions: [
          GestureDetector(
            onTap: () {
              showModalBottomSheet<void>(
                context: context,
                builder: (BuildContext context) {
                  return StatefulBuilder(
                    builder: (BuildContext context, StateSetter setState) {
                      return Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Center(child: SvgPicture.asset(AppImages.dragIcon)),
                            const SizedBox(height: 10),
                            const Text(
                              'Filters by',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 16),
                            DropdownSearch<String>(
                              popupProps: const PopupProps.menu(
                                showSearchBox:
                                    false, // Removed search since it's a small static list
                                fit: FlexFit.loose,
                              ),
                              items: const ['Completed', 'Failed'],
                              onChanged: (String? newValue) async {
                                if (newValue != null) {
                                  // final statusId =
                                  //     newValue == 'Completed' ? '0' : '1';
                                  setState(() {
                                    selectedStatus = newValue;
                                  });
                                }
                              },
                              dropdownDecoratorProps: DropDownDecoratorProps(
                                dropdownSearchDecoration: InputDecoration(
                                  labelText: 'Select Status',
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
                                ),
                              ),
                              selectedItem: selectedStatus,
                            ),
                            SizedBox(height: 10),
                            TextField(
                              controller: _dateController,
                              decoration: InputDecoration(
                                labelText: 'Select Date',
                                suffixIcon: IconButton(
                                  icon: SvgPicture.asset(
                                    AppImages.calendarIcon,
                                  ),
                                  onPressed:
                                      () => _selectDate(context, setState),
                                ),
                                labelStyle: const TextStyle(
                                  color: AppColors.grey,
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.textfieldBorderColor,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderSide: const BorderSide(
                                    color: AppColors.grey,
                                  ),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              readOnly: true,
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: OutlinedButton(
                                      onPressed: () {
                                        setState(() {
                                          _dateController.clear();
                                          print(
                                            'Filter date cleared',
                                          ); // Debug print
                                        });

                                        controller.refreshleadsList(
                                          context: context,
                                        );
                                        selectedStatus = null;
                                        Navigator.pop(context);
                                      },
                                      style: OutlinedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        side: const BorderSide(
                                          color: AppColors.primary,
                                        ),
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text(
                                        'Clear Filter',
                                        style: TextStyle(
                                          color: AppColors.primary,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: SizedBox(
                                    height: 50,
                                    child: ElevatedButton(
                                      onPressed: () {
                                        String? formattedDate;
                                        if (_dateController.text.isNotEmpty) {
                                          try {
                                            final parts = _dateController.text
                                                .split('/');
                                            if (parts.length == 3) {
                                              final day = int.parse(parts[0]);
                                              final month = int.parse(parts[1]);
                                              final year = int.parse(parts[2]);
                                              formattedDate =
                                                  '$year-${month.toString().padLeft(2, '0')}-${day.toString().padLeft(2, '0')}';
                                            } else {
                                              print(
                                                'Invalid date format: ${_dateController.text}',
                                              );
                                              formattedDate = null;
                                            }
                                          } catch (e) {
                                            print('Error parsing date: $e');
                                            formattedDate = null;
                                          }
                                        } else {
                                          print('No date selected');
                                          formattedDate = null;
                                        }
                                        print(
                                          'Selected date: ${_dateController.text}',
                                        );
                                        print('Formatted date: $formattedDate');

                                        controller.fetchPaymentList(
                                          context: context,
                                          reset: true,
                                          date: formattedDate,
                                          payment:
                                              selectedStatus!.isNotEmpty &&
                                                      selectedStatus ==
                                                          "Completed"
                                                  ? '1'
                                                  : '0',
                                        );
                                        Navigator.pop(context);
                                      },
                                      style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            4,
                                          ),
                                        ),
                                        backgroundColor: AppColors.primary,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(
                                          vertical: 12,
                                        ),
                                      ),
                                      child: const Text('Apply'),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              );
            },
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: SvgPicture.asset(
                AppImages.filterIcon,
                color: Colors.black,
              ),
            ),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => controller.refreshleadsList(context: context),
        child: Obx(() {
          if (controller.isLoading.value) {
            return Center(child: ShimmerCard());
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16.0),
            physics: const AlwaysScrollableScrollPhysics(),
            controller: scrollController,
            itemCount:
                controller.paymentList.isEmpty
                    ? 1
                    : controller.paymentList.length +
                        (controller.hasMoreData.value ||
                                controller.isLoadingMore.value
                            ? 1
                            : 0),
            itemBuilder: (context, int index) {
              if (controller.paymentList.isEmpty) {
                return NoDataScreen();
              }

              if (index == controller.paymentList.length) {
                return controller.isLoadingMore.value
                    ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(child: CircularProgressIndicator()),
                    )
                    : const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: Center(
                        child: Text(
                          'No more data',
                          style: TextStyle(
                            fontSize: 16,
                            color: AppColors.defaultblack,
                          ),
                        ),
                      ),
                    );
              }

              var pay = controller.paymentList[index];
              return GestureDetector(
                onTap: () {
                  Get.toNamed(AppRoutes.paymentRecieptdownload, arguments: pay);
                },
                child: Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    side: const BorderSide(
                      color: Color(0xFFE5E7EB),
                      width: 1.0,
                    ),
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: const BoxDecoration(
                          border: Border(
                            bottom: BorderSide(
                              color: Color(0xFFE5E7EB),
                              width: 1.0,
                            ),
                          ),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 20,
                            right: 20,
                            top: 10,
                            bottom: 10,
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Expanded(
                                child: Text(
                                  'Payment Status',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                              ),
                              Text(
                                pay.payment == "1" ? "Completed" : "Failed",
                                style: TextStyle(
                                  color:
                                      pay.payment == "1"
                                          ? Colors.green
                                          : Colors.red,
                                  fontSize: 13,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      _buildDetailRow("Ref number", pay.refNo),
                      const SizedBox(height: 5),
                      _buildDetailRow("TXN ID", pay.transactionNo),
                      const SizedBox(height: 5),
                      _buildDetailRow("Name", pay.userName),
                      const SizedBox(height: 5),
                      _buildDetailRow("Contact No.", pay.mobileNumber),
                      const SizedBox(height: 5),
                      _buildDetailRow(
                        "Date",
                        "${formatDate(pay.buyDate.toString())}",
                      ),
                      const SizedBox(height: 5),
                      _buildDetailRow("Amount", pay.amount),
                      const SizedBox(height: 5),
                      Padding(
                        padding: EdgeInsets.only(left: 20, right: 20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: 100,
                              child: Text(
                                'Package',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  color: AppColors.primaryTeal,
                                ),
                              ),
                            ),
                            SizedBox(width: 8),
                            Text(
                              ':  ${pay.packageName}',
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: AppColors.primaryTeal,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                    ],
                  ),
                ),
              );
            },
          );
        }),
      ),
    );
  }

  String formatDate(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF39373C),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ':  $value',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF353B43),
            ),
          ),
        ],
      ),
    );
  }
}

class ShimmerCard extends StatelessWidget {
  const ShimmerCard({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Card(
            margin: const EdgeInsets.only(bottom: 16.0),
            elevation: 0,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: Colors.grey.shade100, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Shimmer.fromColors(
              baseColor: Colors.grey[300]!,
              highlightColor: Colors.grey[100]!,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    decoration: const BoxDecoration(
                      border: Border(
                        bottom: BorderSide(color: Colors.white, width: 1.0),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 20,
                        right: 20,
                        top: 10,
                        bottom: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Container(
                              height: 16,
                              width: 100,
                              color: Colors.white,
                            ),
                          ),
                          Container(height: 16, width: 60, color: Colors.white),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  _buildShimmerRow(),
                  const SizedBox(height: 5),
                  _buildShimmerRow(),
                  const SizedBox(height: 5),
                  _buildShimmerRow(),
                  const SizedBox(height: 5),
                  _buildShimmerRow(),
                  const SizedBox(height: 5),
                  _buildShimmerRow(),
                  const SizedBox(height: 5),
                  Padding(
                    padding: const EdgeInsets.only(left: 20, right: 20),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(width: 100, height: 16, color: Colors.white),
                        const SizedBox(width: 8),
                        Container(width: 120, height: 16, color: Colors.white),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildShimmerRow() {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(width: 100, height: 16, color: Colors.white),
          const SizedBox(width: 8),
          Container(width: 120, height: 16, color: Colors.white),
        ],
      ),
    );
  }
}

class PaymentReceiptCard extends StatelessWidget {
  final String status;
  final bool isPending;

  const PaymentReceiptCard({
    super.key,
    required this.status,
    required this.isPending,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 16.0),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: const BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
              border: Border(
                bottom: BorderSide(color: Color(0xFFE5E7EB), width: 1.0),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.only(
                left: 20,
                right: 20,
                top: 10,
                bottom: 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Expanded(
                    child: Text(
                      'Payment Status',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                  Text(
                    status,
                    style: TextStyle(
                      color: isPending ? Colors.red : Colors.green,
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),
          _buildDetailRow("Ref number", "0000085752257"),
          const SizedBox(height: 5),
          _buildDetailRow("Name", "Aishwarya Rai Singh"),
          const SizedBox(height: 5),
          _buildDetailRow("Contact No.", "+91 1234567952"),
          const SizedBox(height: 5),
          _buildDetailRow("Date", "20/05/2025"),
          const SizedBox(height: 5),
          _buildDetailRow("Amount", "₹2000.00"),
          const SizedBox(height: 5),
          const Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: 100,
                  child: Text(
                    'Package',
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.primaryTeal,
                    ),
                  ),
                ),
                SizedBox(width: 8),
                Text(
                  ':  Classic',
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: AppColors.primaryTeal,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(left: 20, right: 20),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: Color(0xFF39373C),
              ),
            ),
          ),
          const SizedBox(width: 8),
          Text(
            ':  $value',
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: Color(0xFF353B43),
            ),
          ),
        ],
      ),
    );
  }
}
