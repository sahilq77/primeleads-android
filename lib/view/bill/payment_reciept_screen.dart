import 'dart:io';
import 'package:device_info_plus/device_info_plus.dart';
import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:open_file/open_file.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:prime_leads/controller/payment_list/payment_receipt_controller.dart';
import 'package:prime_leads/utility/app_images.dart';
import 'package:prime_leads/utility/app_utility.dart';
// import 'package:share_plus/share_plus.dart';
import '../../controller/profile/profile_controller.dart';
import '../../model/payment_list/get_payment_list_response.dart';
import '../../utility/app_colors.dart';
import '../../utility/app_routes.dart';

class PaymentRecieptScreen extends StatefulWidget {
  const PaymentRecieptScreen({super.key});

  @override
  State<PaymentRecieptScreen> createState() => _PaymentRecieptScreenState();
}

class _PaymentRecieptScreenState extends State<PaymentRecieptScreen> {
  final controller = Get.put(PaymentReceiptController());
  late PaymentData? sub;

  @override
  void initState() {
    super.initState();
    final pay = Get.arguments as PaymentData;
    setState(() {
      sub = pay;
    });
    if (kDebugMode) {
      print(pay.toString());
    }
    controller.fetchReciptUrl(id: sub!.id);
  }

  // Helper method to check Android version (API 33+ for READ_MEDIA_IMAGES)
  Future<bool> _isAndroid13OrAbove() async {
    if (Platform.isAndroid) {
      try {
        var androidInfo = await DeviceInfoPlugin().androidInfo;
        return androidInfo.version.sdkInt >= 33;
      } catch (e) {
        if (kDebugMode) {
          print('Error checking Android version: $e');
        }
        return false;
      }
    }
    return false;
  }

  // Request storage-related permissions based on Android version
  Future<bool> _requestStoragePermissions() async {
    if (Platform.isAndroid) {
      bool isAndroid13OrAbove = await _isAndroid13OrAbove();
      PermissionStatus status;

      if (isAndroid13OrAbove) {
        // For Android 13+ (API 33+), request READ_MEDIA_IMAGES
        status = await Permission.photos.request();
      } else {
        // For older Android versions, request storage permission
        status = await Permission.storage.request();
      }

      if (status.isGranted) {
        return true;
      } else if (status.isPermanentlyDenied) {
        Fluttertoast.showToast(
          msg: "Please enable storage permission in settings",
          toastLength: Toast.LENGTH_LONG,
        );
        await openAppSettings();
        return false;
      } else {
        Fluttertoast.showToast(
          msg: "Storage permission denied",
          toastLength: Toast.LENGTH_LONG,
        );
        return false;
      }
    }
    return true; // No permission needed for iOS or other platforms
  }

  // Validate if the URL points to a PDF
  Future<bool> _isValidPdfUrl(String url) async {
    try {
      final response = await Dio().head(url);
      final contentType = response.headers.value('content-type');
      if (kDebugMode) {
        print('Content-Type: $contentType');
      }
      return contentType?.contains('application/pdf') ?? false;
    } catch (e) {
      if (kDebugMode) {
        print('Error validating URL: $e');
      }
      return false;
    }
  }

  Future<void> _downloadReceipt(String url) async {
    try {
      // Validate URL
      bool isValidPdf = await _isValidPdfUrl(url);
      if (!isValidPdf) {
        Fluttertoast.showToast(
          msg: "Invalid PDF URL or file type",
          toastLength: Toast.LENGTH_LONG,
        );
        return;
      }

      // Request storage permissions
      if (!await _requestStoragePermissions()) {
        return;
      }

      // Get download directory
      Directory? directory;
      if (Platform.isAndroid) {
        directory = Directory('/storage/emulated/0/Download');
        if (!await directory.exists()) {
          directory = await getExternalStorageDirectory();
        }
      } else {
        directory = await getApplicationDocumentsDirectory();
      }

      // Create a unique filename
      String fileName =
          'receipt_${sub!.id}_${DateTime.now().millisecondsSinceEpoch}.pdf';
      String filePath = '${directory!.path}/$fileName';

      // Download the file with binary response
      final dio = Dio();
      dio.options.connectTimeout = Duration(seconds: 10);
      dio.options.receiveTimeout = Duration(seconds: 30);
      await dio.download(
        url,
        filePath,
        options: Options(
          responseType: ResponseType.bytes, // Ensure binary response
        ),
        onReceiveProgress: (received, total) {
          if (total != -1) {
            double progress = (received / total * 100);
            Fluttertoast.showToast(
              msg: "Downloading: ${progress.toStringAsFixed(0)}%",
              toastLength: Toast.LENGTH_SHORT,
            );
          }
        },
      );

      // Verify file integrity
      File file = File(filePath);
      if (await file.exists() && await file.length() > 0) {
        if (kDebugMode) {
          print('Downloaded file size: ${await file.length()} bytes');
        }
        Fluttertoast.showToast(
          msg: "Receipt downloaded to Downloads folder",
          toastLength: Toast.LENGTH_LONG,
        );

        // Open the downloaded file
        final result = await OpenFile.open(filePath);
        if (result.type != ResultType.done) {
          Fluttertoast.showToast(
            msg: "Error opening file: ${result.message}",
            toastLength: Toast.LENGTH_LONG,
          );
        }

        // Share option
        // await Share.shareXFiles([XFile(filePath)], text: 'Payment Receipt');
      } else {
        Fluttertoast.showToast(
          msg: "Downloaded file is empty or corrupted",
          toastLength: Toast.LENGTH_LONG,
        );
      }
    } catch (e) {
      Fluttertoast.showToast(
        msg: "Error downloading receipt: $e",
        toastLength: Toast.LENGTH_LONG,
      );
      if (kDebugMode) {
        print('Download error: $e');
      }
    }
  }

  String formatDate(String inputDate) {
    DateTime dateTime = DateTime.parse(inputDate);
    DateFormat formatter = DateFormat('dd/MM/yyyy');
    return formatter.format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'Download Invoice',
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15.0),
                border: Border.all(color: const Color(0xFFE6DFDC), width: 1.0),
                color: AppColors.white,
                boxShadow: [
                  BoxShadow(
                    color: const Color(0x1FAA_AAAA),
                    offset: const Offset(0, 8),
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
                        child: SvgPicture.asset(AppImages.paymentSucces),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const SizedBox(height: 16),
                     Text(
                     sub!.payment == "1"?  'Payment Success!!':'Payment Failed!!',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w500,
                        color: Color(0xFF474747),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      "₹${sub!.amount}",
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

                    _buildDetailRow('Package', sub!.packageName),
                    const SizedBox(height: 12),
                    _buildDetailRow('Ref Number', sub!.refNo),
                    const SizedBox(height: 12),
                    _buildDetailRow('TXN Number', sub!.transactionNo),
                    const SizedBox(height: 12),
                    _buildDetailRow('Name', sub!.userName),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Date',
                      formatDate(sub!.buyDate.toString()),
                    ),
                    const SizedBox(height: 12),
                    _buildDetailRow(
                      'Pay Status',
                      sub!.payment == "1" ? "Completed" : "Failed",
                      isStatus: true,
                    ),
                    const SizedBox(height: 12),
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
                            "₹${sub!.amount}",
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
                    const SizedBox(height: 20),
                    const Divider(
                      color: Color(0xFFEDEDED),
                      thickness: 1,
                      height: 20,
                    ),
                    Obx(
                      () => SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed:
                              controller.url.value.isEmpty
                                  ? null
                                  : () =>
                                      _downloadReceipt(controller.url.value),
                          icon: SvgPicture.asset(
                            AppImages.downloadIcon,
                            width: 20,
                            height: 20,
                          ),
                          label: const Text(
                            'Download Payment Receipt',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: AppColors.textDark,
                            ),
                          ),
                          style: ElevatedButton.styleFrom(
                            foregroundColor: Colors.black,
                            backgroundColor: Colors.white,
                            side: const BorderSide(color: Color(0xFFE5E7EB)),
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
                    ),
                  ],
                ),
              ),
            ),
          ],
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
      } else if (status.toLowerCase() == 'failed') {
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
